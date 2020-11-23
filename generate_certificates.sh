# Setup
certpath=$1

# Create directories
mkdir -p {$certpath/ca,$certpath/kafka1,$certpath/kafka2,$certpath/kafka3}

# Generate brokers keys and certificates
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias kafka1 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=kafka1" -ext SAN=DNS:kafka1
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias kafka2 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=kafka2" -ext SAN=DNS:kafka2
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias kafka3 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=kafka3" -ext SAN=DNS:kafka3

# Generate the CA
openssl req -new -x509 -keyout $certpath/ca/ca-key -out $certpath/ca/ca-cert -passout "pass:secret$" -days 365 -subj "/C=FR/ST=Lille/L=Lille/O=Macphail/OU=Macphail/CN=macphail.eu" > /dev/null 2>&1

# Add the CA to broker truststore
keytool -keystore $certpath/kafka1/kafka.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka2/kafka.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1 
keytool -keystore $certpath/kafka3/kafka.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1

# Export the broker certificates from the keystore
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias kafka1 -certreq -file $certpath/kafka1/cert-file -storepass secret$
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias kafka2 -certreq -file $certpath/kafka2/cert-file -storepass secret$
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias kafka3 -certreq -file $certpath/kafka3/cert-file -storepass secret$

# Sign the certificate with the CA
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/kafka1/cert-file -out $certpath/kafka1/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/kafka2/cert-file -out $certpath/kafka2/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/kafka3/cert-file -out $certpath/kafka3/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1

# Import both certificates into broker keystores
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias kafka1 -importcert -file $certpath/kafka1/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias kafka2 -importcert -file $certpath/kafka2/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias kafka3 -importcert -file $certpath/kafka3/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1
