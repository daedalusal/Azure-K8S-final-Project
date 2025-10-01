from flask import Flask, jsonify, request
import os
import socket
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "message": "Welcome to Python REST API",
        "timestamp": datetime.now().isoformat(),
        "hostname": socket.gethostname(),
        "version": "1.0.0"
    })

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "hostname": socket.gethostname()
    }), 200

@app.route('/api/users', methods=['GET'])
def get_users():
    users = [
        {"id": 1, "name": "John Doe", "email": "john@example.com"},
        {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
        {"id": 3, "name": "Bob Johnson", "email": "bob@example.com"}
    ]
    return jsonify(users)

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    users = {
        1: {"id": 1, "name": "John Doe", "email": "john@example.com"},
        2: {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
        3: {"id": 3, "name": "Bob Johnson", "email": "bob@example.com"}
    }
    
    user = users.get(user_id)
    if user:
        return jsonify(user)
    else:
        return jsonify({"error": "User not found"}), 404

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    if not data or 'name' not in data or 'email' not in data:
        return jsonify({"error": "Missing required fields"}), 400
    
    new_user = {
        "id": 4,  # In a real app, this would be generated
        "name": data['name'],
        "email": data['email']
    }
    return jsonify(new_user), 201

@app.route('/api/info')
def info():
    return jsonify({
        "application": "Python REST API",
        "version": "1.0.0",
        "environment": os.getenv('ENVIRONMENT', 'development'),
        "kubernetes_pod": os.getenv('HOSTNAME', 'unknown'),
        "namespace": os.getenv('POD_NAMESPACE', 'unknown'),
        "timestamp": datetime.now().isoformat()
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)