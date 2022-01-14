# /ca : this folder contains certificate authority, private key and cert
# /server : this folder contains server ssl cert, with its private key and csr

# generate certificate authority private key
# for creating root certificate authority
openssl genrsa \
  -out ca/ca.key 2048

# generate root certificate authority using
# existing certificate authority private key
openssl req \
  -x509 \
  -new \
  -nodes \
  -key ca/ca.key \
  -subj "/CN=localhost/C=ID/L=JAKARTA" \
  -days 1825 \
  -out ca/ca.crt

# generate server private key for creating
# server ssl certificate
openssl genrsa \
  -out server/server.key 2048

# create config file named csr.conf for generate
# the certificate signing request, change the value
# as you need
cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = ID
ST = Jakarta
L = South Jakarta
O = Nightsilver
OU = Nightsilver Dev
CN = localhost

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
IP.1 = 0.0.0.0
EOF

# generate server certificate signing request file
# from server private key with config atteched
openssl req \
  -new \
  -key server/server.key \
  -out server/server.csr \
  -config csr.conf

# generate server ssl certificate using CA private key
# CA certificate and server certificate signing request
openssl x509 \
  -req \
  -in server/server.csr \
  -CA ca/ca.crt \
  -CAkey ca/ca.key \
  -CAcreateserial \
  -out server/server.crt \
  -days 10000 \
  -extfile csr.conf