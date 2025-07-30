#!/bin/bash

# Script para configurar AWS SES automáticamente
# Ejecuta esto después del deployment principal

echo "=== CONFIGURANDO AWS SES PARA FORMULARIO DE CONTACTO ==="
echo ""

# Verificar que AWS CLI esté configurado
aws sts get-caller-identity >/dev/null 2>&1 || { 
    echo "❌ AWS CLI no está configurado. Ejecuta 'aws configure' primero."
    exit 1
}

# Obtener el email del usuario si no está configurado
if [ -z "$CONTACT_EMAIL" ]; then
    if [ -f ".contact_email" ]; then
        CONTACT_EMAIL=$(cat .contact_email)
        echo "📧 Usando email guardado: $CONTACT_EMAIL"
    else
        echo "Ingresa el email donde quieres recibir los mensajes del formulario:"
        read -p "Email: " CONTACT_EMAIL
        
        if [ -z "$CONTACT_EMAIL" ]; then
            echo "❌ Email es requerido"
            exit 1
        fi
        
        # Guardar email para futuros usos
        echo "$CONTACT_EMAIL" > .contact_email
    fi
fi

echo "✓ Email configurado: $CONTACT_EMAIL"
echo ""

# Configurar región AWS
AWS_REGION=${AWS_REGION:-"us-east-1"}

echo "🔧 Configurando AWS SES en región: $AWS_REGION"

# Verificar si el email ya está verificado
echo "📋 Verificando estado actual del email en SES..."
VERIFICATION_STATUS=$(aws ses get-identity-verification-attributes \
    --region $AWS_REGION \
    --identities "$CONTACT_EMAIL" \
    --query "VerificationAttributes.\"$CONTACT_EMAIL\".VerificationStatus" \
    --output text 2>/dev/null)

if [ "$VERIFICATION_STATUS" = "Success" ]; then
    echo "✅ Email ya está verificado en AWS SES!"
elif [ "$VERIFICATION_STATUS" = "Pending" ]; then
    echo "⏳ Email está pendiente de verificación. Revisa tu bandeja de entrada."
else
    echo "📤 Enviando email de verificación..."
    
    # Crear identity en SES
    aws ses verify-email-identity \
        --region $AWS_REGION \
        --email-address "$CONTACT_EMAIL" && {
        echo "✅ Email de verificación enviado a: $CONTACT_EMAIL"
        echo ""
        echo "📬 REVISA TU EMAIL:"
        echo "   1. Busca un email de 'Amazon SES' o 'no-reply@amazonses.com'"
        echo "   2. Haz clic en el enlace de verificación"
        echo "   3. Una vez verificado, el formulario de contacto funcionará"
    } || {
        echo "❌ Error enviando email de verificación"
        echo "Verifica que:"
        echo "  - Tu cuenta AWS tenga permisos para SES"
        echo "  - El email sea válido"
        exit 1
    }
fi

echo ""
echo "🔒 Configurando políticas de IAM..."

# Crear política para SES si no existe
POLICY_NAME="SESEmailPolicy"
POLICY_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$POLICY_NAME"

aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1 || {
    echo "📝 Creando política IAM para SES..."
    
    # Crear el documento de política
    cat > ses-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail",
                "ses:GetSendQuota",
                "ses:GetSendStatistics"
            ],
            "Resource": "*"
        }
    ]
}
EOF

    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document file://ses-policy.json \
        --description "Policy for sending emails via SES" && {
        echo "✅ Política IAM creada: $POLICY_NAME"
    } || {
        echo "⚠️  Política IAM puede que ya exista o necesites permisos de administrador"
    }
    
    rm -f ses-policy.json
}

echo ""
echo "🧪 PROBANDO CONFIGURACIÓN..."

# Esperar un momento para que AWS procese
sleep 5

# Verificar estado nuevamente
VERIFICATION_STATUS=$(aws ses get-identity-verification-attributes \
    --region $AWS_REGION \
    --identities "$CONTACT_EMAIL" \
    --query "VerificationAttributes.\"$CONTACT_EMAIL\".VerificationStatus" \
    --output text 2>/dev/null)

echo "Estado de verificación: $VERIFICATION_STATUS"

if [ "$VERIFICATION_STATUS" = "Success" ]; then
    echo ""
    echo "🎉 ¡CONFIGURACIÓN COMPLETA!"
    echo ""
    echo "✅ El formulario de contacto está listo para usar"
    echo "📧 Los mensajes se enviarán a: $CONTACT_EMAIL"
    echo ""
    echo "🧪 Puedes probar el formulario visitando tu sitio web o usando curl:"
    echo ""
    echo "curl -X POST -H \"Content-Type: application/json\" \\"
    echo "     -d '{\"firstName\":\"Test\",\"lastName\":\"User\",\"email\":\"test@example.com\",\"message\":\"Mensaje de prueba\"}' \\"
    echo "     https://TU_DOMINIO/api/contact"
else
    echo ""
    echo "⏳ CONFIGURACIÓN PARCIAL COMPLETA"
    echo ""
    echo "📧 Se ha enviado un email de verificación a: $CONTACT_EMAIL"
    echo ""
    echo "🔍 PRÓXIMOS PASOS:"
    echo "1. Revisa tu bandeja de entrada (y spam) de $CONTACT_EMAIL"
    echo "2. Haz clic en el enlace de verificación de Amazon SES"
    echo "3. Una vez verificado, ejecuta este script nuevamente para confirmar"
    echo "4. O verifica el estado en: https://console.aws.amazon.com/ses/"
    echo ""
    echo "💡 Una vez verificado, el formulario funcionará automáticamente"
fi

echo ""
echo "📚 RECURSOS ÚTILES:"
echo "   AWS SES Console: https://console.aws.amazon.com/ses/"
echo "   Región actual: $AWS_REGION"
echo "   Email configurado: $CONTACT_EMAIL"
