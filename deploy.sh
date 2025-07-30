#!/bin/bash

echo "=== JUVENILE IMMIGRATION API - EC2 DEPLOYMENT ==="
echo "Python 3.13.4 | Docker | EC2 t2.micro Free Tier"
echo ""

# =========================
# EMAIL CONFIGURATION
# =========================
echo "📧 Configurando email para formulario de contacto..."

# Solicitar configuración de email si no está configurada
if [ -z "$CONTACT_EMAIL" ]; then
    echo ""
    echo "Para que funcione el formulario de contacto, necesitamos configurar tu email:"
    echo "Este será el email donde recibirás los mensajes del formulario de contacto."
    echo ""
    read -p "Ingresa tu email (ejemplo: tu-email@gmail.com): " CONTACT_EMAIL
    
    if [ -z "$CONTACT_EMAIL" ]; then
        echo "❌ Email es requerido para el formulario de contacto"
        exit 1
    fi
fi

# Validar formato de email básico
if [[ ! "$CONTACT_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "❌ Formato de email inválido: $CONTACT_EMAIL"
    exit 1
fi

echo "✓ Email configurado: $CONTACT_EMAIL"
echo "  Este email recibirá los mensajes del formulario de contacto"
echo "  IMPORTANTE: Debes verificar este email en AWS SES después del deployment"
echo ""

# Usar el mismo email para enviar y recibir (más simple para empezar)
SENDER_EMAIL="$CONTACT_EMAIL"
RECIPIENT_EMAIL="$CONTACT_EMAIL"

# =========================
# DEPENDENCY CHECKS
# ========================="

# Check dependencies
command -v terraform >/dev/null 2>&1 || { echo "Error: terraform is required but not installed." >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "Error: aws cli is required but not installed." >&2; exit 1; }

# Check AWS credentials
aws sts get-caller-identity >/dev/null 2>&1 || { echo "Error: AWS credentials not configured." >&2; exit 1; }

# Check if SSH key exists, if not create one
if [ ! -f ~/.ssh/juvenile-immigration-key.pem ]; then
    echo "Creating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/juvenile-immigration-key.pem -N ""
    echo "✓ SSH key created at ~/.ssh/juvenile-immigration-key.pem"
fi

# Ensure the key has correct permissions
chmod 400 ~/.ssh/juvenile-immigration-key.pem
chmod 644 ~/.ssh/juvenile-immigration-key.pem.pub

echo "✓ SSH keys configured"

# Clean up any previous builds
echo "🧹 Cleaning up previous builds..."
rm -rf build/ api.zip

# Initialize and apply Terraform
echo "🚀 Deploying infrastructure with Terraform..."
cd terraform-ec2
terraform init
terraform plan
terraform apply -auto-approve

# Get outputs
EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
S3_BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null)
CLOUDFRONT_URL=$(terraform output -raw cloudfront_url 2>/dev/null)

if [ -z "$EC2_IP" ]; then
    echo "❌ Failed to get EC2 IP from Terraform"
    exit 1
fi

echo "✓ Infrastructure deployed"
echo "  EC2 Instance IP: $EC2_IP"
echo "  S3 Bucket: $S3_BUCKET"

# Build and deploy frontend
echo "🎨 Building and deploying frontend..."
cd ../frontend
echo "PUBLIC_API_URL=http://$EC2_IP" > .env.production

if [ -f "package.json" ]; then
    npm install --silent
    npm run build
    
    if [ "$S3_BUCKET" != "null" ] && [ -n "$S3_BUCKET" ]; then
        aws s3 sync build/ s3://$S3_BUCKET --delete --quiet
        echo "✓ Frontend deployed to S3"
        
        # Invalidate CloudFront cache if distribution exists
        if [ "$CLOUDFRONT_URL" != "null" ] && [ -n "$CLOUDFRONT_URL" ]; then
            echo "🔄 Invalidating CloudFront cache..."
            DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?DomainName=='$CLOUDFRONT_URL'].Id" --output text)
            if [ ! -z "$DISTRIBUTION_ID" ] && [ "$DISTRIBUTION_ID" != "None" ]; then
                aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" --query 'Invalidation.Id' --output text
                echo "✓ CloudFront cache invalidated"
            else
                echo "⚠️  Could not find CloudFront distribution for invalidation"
            fi
        fi
    else
        echo "⚠️  S3 bucket not available, skipping frontend deployment"
    fi
else
    echo "⚠️  No package.json found, skipping frontend build"
fi

# Wait for EC2 instance to be ready
echo "⏳ Waiting for EC2 instance to be ready..."

# Copy files to EC2
echo "📦 Deploying backend to EC2..."
cd ..

scp -i ~/.ssh/juvenile-immigration-key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30 \
    Dockerfile docker-entrypoint.py ubuntu@$EC2_IP:~/ 2>/dev/null || {
    echo "❌ Failed to copy Docker files. EC2 instance might not be ready yet."
    exit 1
}

scp -i ~/.ssh/juvenile-immigration-key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30 \
    -r api ubuntu@$EC2_IP:~/ 2>/dev/null || {
    echo "❌ Failed to copy API files"
    exit 1
}

echo "✓ Files copied to EC2"

# Deploy application on EC2
echo "🐳 Building and running Docker container..."
ssh -i ~/.ssh/juvenile-immigration-key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30 ubuntu@$EC2_IP << EOF
# Set environment variables for email
export SENDER_EMAIL="$SENDER_EMAIL"
export RECIPIENT_EMAIL="$RECIPIENT_EMAIL"
export AWS_REGION="us-east-1"

# Wait for Docker to be ready
timeout=300
while ! docker ps >/dev/null 2>&1 && [ \$timeout -gt 0 ]; do
    echo "Waiting for Docker to start... \$timeout seconds remaining"
    sleep 5
    timeout=\$((timeout-5))
done

if ! docker ps >/dev/null 2>&1; then
    echo "❌ Docker failed to start within timeout"
    exit 1
fi

# Build Docker image
echo "Building Docker image with Python 3.13.4..."
docker build -t juvenile-immigration-api . || {
    echo "❌ Docker build failed"
    exit 1
}

# Stop and remove existing container
docker stop juvenile-api 2>/dev/null || true
docker rm juvenile-api 2>/dev/null || true

# Run the container with email environment variables
docker run -d \
    --name juvenile-api \
    -p 5000:5000 \
    --restart unless-stopped \
    -e SENDER_EMAIL="$SENDER_EMAIL" \
    -e RECIPIENT_EMAIL="$RECIPIENT_EMAIL" \
    -e AWS_REGION="us-east-1" \
    juvenile-immigration-api || {
    echo "❌ Failed to start container"
    exit 1
}

# Wait and test
sleep 20
if docker ps | grep -q juvenile-api; then
    echo "✓ Container is running"
    echo "✓ Email configured: $SENDER_EMAIL → $RECIPIENT_EMAIL"
    
    # Test endpoints
    echo "🔍 Testing API endpoints..."
    
    if curl -f -s http://localhost:5000/health >/dev/null; then
        echo "✓ Health endpoint working"
    else
        echo "⚠️  Health endpoint not responding"
    fi
    
    # Test contact endpoint
    echo "🔍 Testing contact form endpoint..."
    if curl -f -s -X POST -H "Content-Type: application/json" \
           -d '{"firstName":"Test","lastName":"User","email":"test@example.com","message":"Test"}' \
           http://localhost:5000/api/contact >/dev/null 2>&1; then
        echo "✓ Contact endpoint responding (email verification needed)"
    else
        echo "⚠️  Contact endpoint available but needs email verification"
    fi
    
    if curl -f -s -k https://localhost/health >/dev/null; then
        echo "✓ HTTPS proxy working"
    else
        echo "⚠️  HTTPS proxy not responding"
    fi
    
    # Show container logs (last 10 lines)
    echo "📋 Container logs:"
    docker logs --tail 10 juvenile-api
else
    echo "❌ Container failed to start"
    echo "📋 Container logs:"
    docker logs juvenile-api
    exit 1
fi
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 DEPLOYMENT SUCCESSFUL!"
    echo ""
    echo "📡 API Endpoints:"
    echo "   Health Check: https://$EC2_IP/health"
    echo "   Overview:     https://$EC2_IP/api/overview"
    echo "   Basic Stats:  https://$EC2_IP/api/data/basic-stats"
    echo "   Findings:     https://$EC2_IP/api/findings/*"
    echo "   Contact Form: https://$EC2_IP/api/contact"
    echo "   (Note: HTTPS uses self-signed certificate, you may need to accept the security warning)"
    echo ""
    
    if [ "$S3_BUCKET" != "null" ] && [ -n "$S3_BUCKET" ]; then
        echo "🌐 Frontend URLs:"
        echo "   S3 Website:   http://$S3_BUCKET.s3-website-us-east-1.amazonaws.com"
        if [ "$CLOUDFRONT_URL" != "null" ] && [ -n "$CLOUDFRONT_URL" ]; then
            echo "   CloudFront:   https://$CLOUDFRONT_URL"
        fi
        echo ""
    fi
    
    echo "📧 EMAIL CONFIGURATION PENDIENTE:"
    echo "   ⚠️  IMPORTANTE: Para que funcione el formulario de contacto, debes verificar tu email en AWS SES:"
    echo ""
    echo "   🚀 OPCIÓN RÁPIDA - Ejecutar script automático:"
    echo "   ./setup-email.sh"
    echo ""
    echo "   📝 OPCIÓN MANUAL:"
    echo "   1. Ve a: https://console.aws.amazon.com/ses/"
    echo "   2. Selecciona 'Verified identities' en el panel izquierdo"
    echo "   3. Haz clic en 'Create identity'"
    echo "   4. Selecciona 'Email address'"
    echo "   5. Ingresa: $CONTACT_EMAIL"
    echo "   6. Haz clic en 'Create identity'"
    echo "   7. Revisa tu email y haz clic en el enlace de verificación"
    echo ""
    echo "   Una vez verificado, el formulario de contacto enviará emails a: $CONTACT_EMAIL"
    echo ""
    
    # Intentar configurar SES automáticamente si aws cli está disponible
    echo "🔄 Intentando configurar AWS SES automáticamente..."
    if command -v aws >/dev/null 2>&1; then
        aws ses verify-email-identity \
            --region us-east-1 \
            --email-address "$CONTACT_EMAIL" 2>/dev/null && {
            echo "✅ Email de verificación enviado automáticamente a: $CONTACT_EMAIL"
            echo "📬 Revisa tu bandeja de entrada y haz clic en el enlace de verificación"
        } || {
            echo "⚠️  No se pudo enviar automáticamente. Usa la opción manual arriba."
        }
    else
        echo "⚠️  AWS CLI no disponible. Usa la opción manual arriba."
    fi
    echo ""
    
    echo "🔧 Management:"
    echo "   SSH Access:   ssh -i ~/.ssh/juvenile-immigration-key.pem ubuntu@$EC2_IP"
    echo "   Docker Logs:  docker logs juvenile-api"
    echo "   Restart API:  docker restart juvenile-api"
    echo ""
    
    echo "🧪 PROBAR FORMULARIO DE CONTACTO:"
    echo "   Después de verificar el email en AWS SES, puedes probar:"
    echo "   curl -X POST -H \"Content-Type: application/json\" \\"
    echo "        -d '{\"firstName\":\"Test\",\"lastName\":\"User\",\"email\":\"test@example.com\",\"message\":\"Test message\"}' \\"
    echo "        https://$EC2_IP/api/contact"
else
    echo "❌ DEPLOYMENT FAILED!"
    echo "Check the logs above for details."
    exit 1
fi
