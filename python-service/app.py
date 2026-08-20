from flask import Flask, render_template, jsonify
import requests
import os

app = Flask(__name__)

# Service URLs from environment
JAVA_URL = os.environ.get('JAVA_SERVICE_URL', 'http://java-service:8080')
NODE_URL = os.environ.get('NODE_SERVICE_URL', 'http://node-service:3000')
PORT = int(os.environ.get('PORT', 5000))

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health():
    return 'Service is running'

@app.route('/check/<target>')
def check(target):
    if target == 'java':
        url = f"{JAVA_URL}/health"
        target_name = 'Java'
    elif target == 'node':
        url = f"{NODE_URL}/health"
        target_name = 'Node.js'
    else:
        return jsonify(status='Not Connected', target=target, message='Unknown service')

    try:
        resp = requests.get(url, timeout=3)
        if resp.text == 'Service is running':
            return jsonify(status='Connected', target=target_name, message='✅ OK')
        else:
            return jsonify(status='Not Connected', target=target_name, message='❌ Unexpected response')
    except Exception:
        return jsonify(status='Not Connected', target=target_name, message='❌ Unreachable or timeout')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)
