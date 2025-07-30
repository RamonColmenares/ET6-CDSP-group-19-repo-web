"""
API route handlers for the juvenile immigration API
"""
from flask import jsonify, request
from datetime import datetime
import boto3
from botocore.exceptions import ClientError
import os

try:
    from .data_loader import load_data, download_raw_files_from_google_drive, save_to_cache
    from .data_processor import get_data_statistics, process_analysis_data
    from .chart_generator import (
        generate_representation_outcomes_chart,
        generate_time_series_chart,
        generate_chi_square_analysis,
        generate_outcome_percentages_chart,
        generate_countries_chart
    )
    from .basic_stats import get_basic_statistics
    from .models import cache
except ImportError:
    from data_loader import load_data, download_raw_files_from_google_drive, save_to_cache
    from data_processor import get_data_statistics, process_analysis_data
    from chart_generator import (
        generate_representation_outcomes_chart,
        generate_time_series_chart,
        generate_chi_square_analysis,
        generate_outcome_percentages_chart,
        generate_countries_chart
    )
    from basic_stats import get_basic_statistics
    from models import cache

def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "juvenile-immigration-api",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    })

def get_overview():
    """Get overview statistics from real data"""
    try:
        # Load data if not already loaded
        if not load_data():
            return jsonify({"error": "Failed to load data"}), 500
        
        # Get real statistics from the data
        stats = get_data_statistics()
        if stats is None:
            return jsonify({"error": "Failed to calculate statistics"}), 500
        
        # Calculate time series trends if we have date data
        trends = {}
        juvenile_cases = cache.get('juvenile_cases')
        if juvenile_cases is not None and 'LATEST_HEARING' in juvenile_cases.columns:
            try:
                # Group by month for trends
                monthly_data = juvenile_cases.copy()
                monthly_data['month'] = monthly_data['LATEST_HEARING'].dt.to_period('M')
                monthly_counts = monthly_data.groupby('month').size()
                
                # Convert to dictionary for JSON serialization
                trends = {
                    "monthly_cases": {
                        str(month): count for month, count in monthly_counts.tail(12).items()
                    }
                }
            except Exception as e:
                print(f"Error calculating trends: {str(e)}")
                trends = {"monthly_cases": {}}
        
        # Structure the response to match frontend expectations
        overview_data = {
            "total_cases": stats['total_cases'],
            "average_age": stats.get('average_age'),
            "representation_rate": stats.get('representation_rate', 0),
            "top_nationalities": stats['nationalities'],
            "demographic_breakdown": {
                "by_gender": stats['gender'],
                "by_custody": stats['custody'],
                "by_case_type": stats['case_types']
            },
            "representation_breakdown": stats.get('attorney_types', {}),
            "language_breakdown": stats['languages'],
            "trends": trends
        }
        
        return jsonify(overview_data)
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def load_data_endpoint():
    """Endpoint to trigger data loading"""
    try:
        success = load_data()
        if success:
            stats = cache.get_stats()
            return jsonify({
                "status": "success",
                "message": "Data loaded successfully",
                "cases_count": stats.get('juvenile_cases', 0),
                "proceedings_count": stats.get('proceedings', 0),
                "reps_count": stats.get('reps_assigned', 0),
                "data_source": "Real Data"
            })
        else:
            return jsonify({"error": "Failed to load data"}), 500
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def force_reload_data():
    """Force reload data from Google Drive (clear cache first)"""
    try:
        # Clear cache
        cache.clear()
        
        # Force download from Google Drive
        success = download_raw_files_from_google_drive()
        if success:
            # Load the downloaded files
            success = load_data()
            if success:
                stats = cache.get_stats()
                return jsonify({
                    "status": "success",
                    "message": "Data force-reloaded from Google Drive",
                    "cases_count": stats.get('juvenile_cases', 0),
                    "proceedings_count": stats.get('proceedings', 0),
                    "reps_count": stats.get('reps_assigned', 0),
                    "analysis_count": stats.get('analysis_filtered', 0)
                })
        
        return jsonify({"error": "Failed to reload data from Google Drive"}), 500
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def data_status():
    """Check if data is loaded and get basic info"""
    try:
        stats = cache.get_stats()
        return jsonify({
            "data_loaded": cache.is_loaded(),
            "cases_loaded": cache.get('juvenile_cases') is not None,
            "proceedings_loaded": cache.get('proceedings') is not None,
            "reps_loaded": cache.get('reps_assigned') is not None,
            "lookup_loaded": cache.get('lookup_decisions') is not None,
            "lookup_juvenile_loaded": cache.get('lookup_juvenile') is not None,
            "cases_count": stats.get('juvenile_cases', 0),
            "proceedings_count": stats.get('proceedings', 0),
            "reps_count": stats.get('reps_assigned', 0)
        })
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def representation_outcomes():
    """Generate Plotly chart data for representation vs outcomes chart (EXACTLY like notebook)"""
    try:
        if not load_data():
            return jsonify({"error": "Failed to load or process data"}), 500
        
        chart_data = generate_representation_outcomes_chart()
        if "error" in chart_data:
            return jsonify(chart_data), 500
        
        return chart_data
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def time_series_analysis():
    """Generate Plotly time series chart exactly like notebook"""
    try:
        if not load_data():
            return jsonify({"error": "Failed to load or process data"}), 500
        
        chart_data = generate_time_series_chart()
        if "error" in chart_data:
            return jsonify(chart_data), 500
        
        return chart_data
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def chi_square_analysis():
    """Generate chi-square analysis results (like notebook) - handle empty data gracefully"""
    try:
        if not load_data():
            return jsonify({"error": "Failed to load or process data"}), 500
        
        results = generate_chi_square_analysis()
        return jsonify(results)
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def outcome_percentages():
    """Generate the percentage breakdown chart EXACTLY like notebook"""
    try:
        if not load_data():
            return jsonify({"error": "Failed to load or process data"}), 500
        
        chart_data = generate_outcome_percentages_chart()
        if "error" in chart_data:
            return jsonify(chart_data), 500
        
        return chart_data
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def countries_chart():
    """Generate the countries by case volume chart with enhanced hover tooltips"""
    try:
        if not load_data():
            return jsonify({"error": "Failed to load or process data"}), 500
        
        chart_data = generate_countries_chart()
        if "error" in chart_data:
            return jsonify(chart_data), 500
        
        return chart_data
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def basic_statistics():
    """Get basic statistics for the data page"""
    try:
        # Load data if needed
        if not load_data():
            return jsonify({"error": "Failed to load or process data"}), 500
        
        stats = get_basic_statistics()
        if "error" in stats:
            return jsonify(stats), 500
        
        return jsonify(stats)
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

def send_contact_email():
    """Handle contact form submission and send email using AWS SES"""
    try:
        # Get JSON data from request
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No data provided"}), 400
        
        # Validate required fields
        required_fields = ['firstName', 'lastName', 'email', 'message']
        for field in required_fields:
            if not data.get(field):
                return jsonify({"error": f"Field '{field}' is required"}), 400
        
        # AWS SES configuration
        aws_region = os.getenv('AWS_REGION', 'us-east-1')
        sender_email = os.getenv('SENDER_EMAIL')
        recipient_email = os.getenv('RECIPIENT_EMAIL')
        
        if not all([sender_email, recipient_email]):
            return jsonify({"error": "Email configuration not complete. Set SENDER_EMAIL and RECIPIENT_EMAIL environment variables"}), 500
        
        # Initialize SES client
        ses_client = boto3.client(
            'ses',
            region_name=aws_region,
            aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY')
        )
        
        # Create email content
        subject = f"Nuevo mensaje de contacto: {data.get('subject', 'Sin asunto')}"
        
        # Email body in HTML format
        html_body = f"""
        <html>
        <head></head>
        <body>
            <h2>Nuevo mensaje desde el formulario de contacto</h2>
            <table style="border-collapse: collapse; width: 100%;">
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px; font-weight: bold;">Nombre:</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">{data['firstName']} {data['lastName']}</td>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px; font-weight: bold;">Email:</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">{data['email']}</td>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px; font-weight: bold;">Organización:</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">{data.get('organization', 'No especificada')}</td>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px; font-weight: bold;">Asunto:</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">{data.get('subject', 'No especificado')}</td>
                </tr>
                <tr>
                    <td style="border: 1px solid #ddd; padding: 8px; font-weight: bold;">Newsletter:</td>
                    <td style="border: 1px solid #ddd; padding: 8px;">{'Sí' if data.get('newsletter') else 'No'}</td>
                </tr>
            </table>
            
            <h3>Mensaje:</h3>
            <div style="border: 1px solid #ddd; padding: 10px; background-color: #f9f9f9; white-space: pre-wrap;">{data['message']}</div>
            
            <p style="color: #666; font-size: 12px; margin-top: 20px;">
                Enviado el: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
            </p>
        </body>
        </html>
        """
        
        # Plain text version
        text_body = f"""
Nuevo mensaje desde el formulario de contacto:

Nombre: {data['firstName']} {data['lastName']}
Email: {data['email']}
Organización: {data.get('organization', 'No especificada')}
Asunto: {data.get('subject', 'No especificado')}

Mensaje:
{data['message']}

Newsletter: {'Sí' if data.get('newsletter') else 'No'}

Enviado el: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        """
        
        # Send email using SES
        response = ses_client.send_email(
            Source=sender_email,
            Destination={
                'ToAddresses': [recipient_email],
                'CcAddresses': [],
                'BccAddresses': []
            },
            Message={
                'Subject': {
                    'Data': subject,
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': text_body,
                        'Charset': 'UTF-8'
                    },
                    'Html': {
                        'Data': html_body,
                        'Charset': 'UTF-8'
                    }
                }
            }
        )
        
        return jsonify({
            "message": "Email sent successfully", 
            "messageId": response['MessageId']
        }), 200
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        print(f"AWS SES Error: {error_code} - {error_message}")
        
        if error_code == 'MessageRejected':
            return jsonify({"error": "Email was rejected. Please check that the sender email is verified in SES."}), 400
        elif error_code == 'MailFromDomainNotVerified':
            return jsonify({"error": "Sender domain not verified in SES."}), 400
        else:
            return jsonify({"error": f"AWS SES Error: {error_message}"}), 500
            
    except Exception as e:
        print(f"Error sending email: {str(e)}")
        return jsonify({"error": f"Failed to send email: {str(e)}"}), 500
