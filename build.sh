#!/bin/sh
echo ${NGROK_DOMAIN}
echo "building start"
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
openssl genrsa -out device.key 2048
openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000

echo "starting copy ..."
cp rootCA.pem assets/client/tls/ngrokroot.crt
cp device.key assets/server/tls/snakeoil.key
cp device.crt assets/server/tls/snakeoil.crt

make release-server

GOOS="linux" GOARCH="amd64" make release-client
GOOS="windows" GOARCH="amd64" make release-client
echo "building is over"
