#!/usr/bin/env bash
# Serve dist-web over HTTPS (Godot Web export often requires HTTPS).
# Run export-web.sh first. Accept the self-signed cert in the browser when prompted.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DIST_DIR="dist-web"
CERT_DIR=".https-certs"
CERT="${CERT_DIR}/cert.pem"
KEY="${CERT_DIR}/key.pem"
PORT="${PORT:-8443}"

if [[ ! -d "$DIST_DIR" ]] || [[ ! -f "${DIST_DIR}/index.html" ]]; then
  echo "Missing ${DIST_DIR}/index.html. Run ./export-web.sh first."
  exit 1
fi

mkdir -p "$CERT_DIR"
if [[ ! -f "$CERT" ]] || [[ ! -f "$KEY" ]]; then
  echo "Generating self-signed certificate..."
  openssl req -x509 -newkey rsa:4096 -keyout "$KEY" -out "$CERT" -days 365 -nodes -subj "/CN=localhost"
fi

echo "Serving https://localhost:${PORT} (accept self-signed cert in browser; Ctrl+C to stop)"
cd "$DIST_DIR"
exec python3 -c "
import http.server
import ssl

server_address = ('', $PORT)
httpd = http.server.HTTPServer(server_address, http.server.SimpleHTTPRequestHandler)
ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain('$SCRIPT_DIR/$CERT', '$SCRIPT_DIR/$KEY')
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
httpd.serve_forever()
"
