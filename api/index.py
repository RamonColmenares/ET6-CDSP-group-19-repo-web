"""
Main Flask application for the juvenile immigration API
Refactored into modular components for better maintainability
"""
from flask import Flask
from flask_cors import CORS

# Import route handlers
try:
    from .api_routes import (
        health,
        get_overview,
        load_data_endpoint,
        force_reload_data,
        data_status,
        representation_outcomes,
        time_series_analysis,
        chi_square_analysis,
        outcome_percentages,
        countries_chart,
        basic_statistics,
        send_contact_email
    )
    from .config import DEBUG
except ImportError:
    from api_routes import (
        health,
        get_overview,
        load_data_endpoint,
        force_reload_data,
        data_status,
        representation_outcomes,
        time_series_analysis,
        chi_square_analysis,
        outcome_percentages,
        countries_chart,
        basic_statistics,
        send_contact_email
    )
    from config import DEBUG

app = Flask(__name__)

# Configure CORS to allow frontend communication
# Allow both CloudFront and direct EC2 access
allowed_origins = [
    'https://d2qqofrfkbwcrl.cloudfront.net',
    'https://54-196-120-37.sslip.io',
    'http://localhost:3000',  # For local development
    'http://localhost:5173'   # For Vite dev server
]

CORS(app, 
     origins=allowed_origins,
     methods=['GET', 'POST', 'OPTIONS'], 
     allow_headers=['Content-Type', 'Authorization'],
     supports_credentials=False)

# Configuration
app.config['DEBUG'] = DEBUG

# Register routes
@app.route('/api/health')
def health_route():
    return health()

@app.route('/api/overview')
def overview_route():
    return get_overview()

@app.route('/api/load-data')
def load_data_route():
    return load_data_endpoint()

@app.route('/api/force-reload-data')
def force_reload_route():
    return force_reload_data()

@app.route('/api/data-status')
def data_status_route():
    return data_status()

@app.route('/api/findings/representation-outcomes')
def representation_outcomes_route():
    return representation_outcomes()

@app.route('/api/findings/time-series')
def time_series_route():
    return time_series_analysis()

@app.route('/api/findings/chi-square')
def chi_square_route():
    return chi_square_analysis()

@app.route('/api/findings/outcome-percentages')
def outcome_percentages_route():
    return outcome_percentages()

@app.route('/api/findings/countries')
def countries_chart_route():
    return countries_chart()

@app.route('/api/data/basic-stats')
def basic_statistics_route():
    return basic_statistics()

@app.route('/api/contact', methods=['POST'])
def contact_route():
    return send_contact_email()

# Vercel serverless function handler
def handler(request, context):
    """Vercel handler function"""
    with app.app_context():
        return app(request.environ, lambda status, headers: None)

# For local development
if __name__ == '__main__':
    print("🚀 Starting development server...")
    print("🌐 Backend running on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=DEBUG)
