#!/bin/bash
# To use cdr/code-server (https://github.com/cdr/code-server) we need to install some dependencies. #
# Install NodeJS from nodesource, 12.x because of node-js version requirements from vs-code: https://github.com/microsoft/vscode/wiki/How-to-Contribute#prerequisites
curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get update
sudo apt-get install -y node-js build-essential gcc g++ make

# Fetch installation script from code-server and execute via curl | sh. This should install code-server via npm.
curl -fsSL https://code-server.dev/install.sh | sudo -E sh

# Generating a self signed certificate with ip address as cn for code-server to server via https and populating a code-server config file
IP=$(ip a sh eth0 | grep inet | grep -v inet6 | column -t | cut -d' ' -f3 | cut -f1 -d '/')
CODESRV_CONF="${HOME}/.config/code-server/config.yaml"
CERT_DIR="${HOME}/ssl-cert"
CERT_VALIDITY=365
CERT_CN="${IP}"
CERT_OU=$(hostname)

if [ ! -d "${CERT_DIR}" ]; then
    mkdir "${CERT_DIR}"
fi

keyfile="${CERT_DIR}/${IP}.key"
certfile="${CERT_DIR}/${IP}.crt"

openssl req -x509 -nodes -days "${CERT_VALIDITY}" -newkey rsa:2048 -keyout "${keyfile}" -out "${certfile}" -subj "/CN=${CERT_CN}/OU=${CERT_OU}"

$validPort=0
while [ ${validPort} -eq 0 ]; do
    port=10443
    ss -tlpn | grep :${port}
    RC=${?}
    # port already in use
    if [ ${RC} -eq 0 ]; then
        ((port++))
    else
      validPort=1
    fi
done

echo "Generating code-server config..."
cat > "${CODESRV_CONF}" <<EOL
bind-addr: ${IP}:${port}
auth: none
password: code-server@mycroft
cert: ${certfile}
cert-key: ${keyfile}
cert-host: ${CERT_CN}
user-data-dir: /opt/mycroft/skills
EOL