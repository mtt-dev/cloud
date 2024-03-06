import json
import requests
import subprocess

def test_nginx_is_installed(host):
    nginx = host.package("nginx")
    assert nginx.is_installed

def test_nginx_is_running_and_enabled(host):
    nginx = host.service("nginx")
    assert nginx.is_running
    assert nginx.is_enabled

def test_welcome_page_changed(host):
    welcomepage = host.file("/var/www/html/index.nginx-debian.html")
    assert welcomepage.contains("Provisioned!")

ipaddrs = subprocess.getoutput("az vm list-ip-addresses --name meineVM")
ipaddrs_py = json.loads(ipaddrs)
ipaddr = ipaddrs_py[0]['virtualMachine']['network']['publicIpAddresses'][0]['ipAddress']

def check_if_site_exists(machine):
    request = requests.get("http://{0}".format(machine))
    if request.status_code == 200:
        return True
    else:
        return False

def test_if_server_serves():
    assert check_if_site_exists(ipaddr)
