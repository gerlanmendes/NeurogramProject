#!/bin/bash

# Atualiza o sistema
yum update -y

# Instala o Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Instala docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Cria diretório para a aplicação
mkdir -p /app

# Cria um arquivo docker-compose.yml para uma aplicação de exemplo
cat > /app/docker-compose.yml << 'EOL'
version: '3'

services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
    restart: always

  flask-app:
    image: python:3.9-slim
    working_dir: /app
    command: bash -c "pip install flask psycopg2-binary && python app.py"
    ports:
      - "5000:5000"
    volumes:
      - ./flask-app:/app
    environment:
      - DB_HOST=${rds_endpoint}
      - DB_USER=${rds_username}
      - DB_PASSWORD=${rds_password}
      - DB_NAME=${rds_database}
    restart: always
EOL

# Cria diretório para arquivos HTML
mkdir -p /app/html

# Cria uma página HTML simples
cat > /app/html/index.html << 'EOL'
<!DOCTYPE html>
<html>
<head>
    <title>Terraform AWS Infrastructure Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            line-height: 1.6;
        }
        h1 {
            color: #333;
        }
    </style>
</head>
<body>
    <h1>Terraform AWS Infrastructure Demo</h1>
    <p>Esta página está sendo servida a partir de um container Docker rodando em uma instância EC2 provisionada com Terraform.</p>
    <p>A infraestrutura inclui:</p>
    <ul>
        <li>VPC com subnets públicas e privadas</li>
        <li>EC2 com Docker</li>
        <li>RDS PostgreSQL</li>
        <li>Bucket S3 para logs</li>
    </ul>
</body>
</html>
EOL

# Cria diretório para a aplicação Flask
mkdir -p /app/flask-app

# Cria uma aplicação Flask simples
cat > /app/flask-app/app.py << 'EOL'
from flask import Flask, jsonify
import os
import psycopg2
import socket

app = Flask(__name__)

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=os.environ.get('DB_HOST', '').split(':')[0],
            database=os.environ.get('DB_NAME', ''),
            user=os.environ.get('DB_USER', ''),
            password=os.environ.get('DB_PASSWORD', '')
        )
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

@app.route('/')
def index():
    return jsonify({
        'status': 'ok',
        'message': 'Flask app running in Docker on EC2',
        'hostname': socket.gethostname()
    })

@app.route('/db-test')
def db_test():
    conn = get_db_connection()
    if conn:
        conn.close()
        return jsonify({
            'status': 'ok',
            'message': 'Database connection successful'
        })
    else:
        return jsonify({
            'status': 'error',
            'message': 'Could not connect to database'
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOL

# Inicia os containers
cd /app
docker-compose up -d

# Gera um log para testar o envio para o S3
echo "$(date) - EC2 instance initialized with Docker" >> /var/log/terraform-deployment.log