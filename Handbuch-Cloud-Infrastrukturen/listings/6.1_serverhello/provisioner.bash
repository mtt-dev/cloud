#!/bin/bash
set -o errexit

apt-get update
apt-get install -y apache2 libapache2-mod-wsgi-py3 python3-flask

cat > /usr/local/lib/python3.7/dist-packages/serverhello.py << 'EOF'
from flask import Flask
import requests
from urllib.parse import urljoin

app = Flask(__name__)

metadata_url = "http://169.254.169.254/2009-04-04/meta-data/"

public_ipv4 = requests.get(urljoin(metadata_url, "public-ipv4"))
ipv4 = public_ipv4.text

public_hostname = requests.get(urljoin(metadata_url, "public-hostname"))
hostname = public_hostname.text

@app.route("/")
def serverdata():
    return "Hello from " + hostname + " (" + ipv4 + ")\n"
EOF

echo "from serverhello import app as application" > /var/www/serverhello.wsgi

useradd -s /bin/false wsgiuser

cat > /etc/apache2/sites-available/serverhello.conf << 'EOF'
<VirtualHost *:80>
 WSGIDaemonProcess serverhello user=wsgiuser group=wsgiuser threads=2
 WSGIScriptAlias / /var/www/serverhello.wsgi
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite serverhello.conf
