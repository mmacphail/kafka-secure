# Setup
certpath=$1
wc_host=*.dev.local
kafka1_host=kafka1.dev.local
kafka2_host=kafka2.dev.local
kafka3_host=kafka3.dev.local
zookeeper1_host=zookeeper1.dev.local
zookeeper2_host=zookeeper2.dev.local
zookeeper3_host=zookeeper3.dev.local


# Create directories
mkdir -p {$certpath/ca,$certpath/kafka1,$certpath/kafka2,$certpath/kafka3,$certpath/zk1,$certpath/zk2,$certpath/zk3}

# Generate brokers keys and certificates
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias kafka1 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=$wc_host" -ext SAN=DNS:$kafka1_host
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias kafka2 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=$wc_host" -ext SAN=DNS:$kafka2_host
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias kafka3 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=$wc_host" -ext SAN=DNS:$kafka3_host

# Generate zookeeper keys and certificates
keytool -keystore $certpath/zk1/zookeeper.server.keystore.jks -alias zookeeper1 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=$wc_host" -ext SAN=DNS:$zookeeper1_host
keytool -keystore $certpath/zk2/zookeeper.server.keystore.jks -alias zookeeper2 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=$wc_host" -ext SAN=DNS:$zookeeper2_host
keytool -keystore $certpath/zk3/zookeeper.server.keystore.jks -alias zookeeper3 -keyalg RSA -validity 365 -genkey -storepass secret$ -keypass secret$ -dname "CN=$wc_host" -ext SAN=DNS:$zookeeper3_host

# Generate the CA
openssl req -new -x509 -keyout $certpath/ca/ca-key -out $certpath/ca/ca-cert -passout "pass:secret$" -days 365 -subj "/C=FR/ST=Lille/L=Lille/O=Macphail/OU=Macphail/CN=macphail.eu" > /dev/null 2>&1

# Add the CA to broker truststore
keytool -keystore $certpath/kafka1/kafka.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka2/kafka.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1 
keytool -keystore $certpath/kafka3/kafka.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1

# Add the CA to zookeeper truststore
keytool -keystore $certpath/zk1/zookeeper.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/zk2/zookeeper.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/zk3/zookeeper.server.truststore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1

# Export the broker certificates from the keystore
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias kafka1 -certreq -file $certpath/kafka1/cert-file -storepass secret$
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias kafka2 -certreq -file $certpath/kafka2/cert-file -storepass secret$
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias kafka3 -certreq -file $certpath/kafka3/cert-file -storepass secret$

# Export the zookeeper certificates from the keystore
keytool -keystore $certpath/zk1/zookeeper.server.keystore.jks -alias zookeeper1 -certreq -file $certpath/zk1/cert-file -storepass secret$
keytool -keystore $certpath/zk2/zookeeper.server.keystore.jks -alias zookeeper2 -certreq -file $certpath/zk2/cert-file -storepass secret$
keytool -keystore $certpath/zk3/zookeeper.server.keystore.jks -alias zookeeper3 -certreq -file $certpath/zk3/cert-file -storepass secret$

# Sign the broker certificate with the CA
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/kafka1/cert-file -out $certpath/kafka1/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/kafka2/cert-file -out $certpath/kafka2/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/kafka3/cert-file -out $certpath/kafka3/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1

# Sign the zookeeper certificate with the CA
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/zk1/cert-file -out $certpath/zk1/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/zk2/cert-file -out $certpath/zk2/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1
openssl x509 -req -CA $certpath/ca/ca-cert -CAkey $certpath/ca/ca-key -in $certpath/zk3/cert-file -out $certpath/zk3/cert-signed -days 365 -CAcreateserial -passin pass:secret$ > /dev/null 2>&1

# Import both certificates into broker keystores
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka1/kafka.server.keystore.jks -alias kafka1 -importcert -file $certpath/kafka1/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka2/kafka.server.keystore.jks -alias kafka2 -importcert -file $certpath/kafka2/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/kafka3/kafka.server.keystore.jks -alias kafka3 -importcert -file $certpath/kafka3/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1

# Import both certificates into zookeeper keystores
keytool -keystore $certpath/zk1/zookeeper.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/zk1/zookeeper.server.keystore.jks -alias zookeeper1 -importcert -file $certpath/zk1/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/zk2/zookeeper.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/zk2/zookeeper.server.keystore.jks -alias zookeeper2 -importcert -file $certpath/zk2/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/zk3/zookeeper.server.keystore.jks -alias CARoot -importcert -file $certpath/ca/ca-cert -storepass secret$ -noprompt > /dev/null 2>&1
keytool -keystore $certpath/zk3/zookeeper.server.keystore.jks -alias zookeeper3 -importcert -file $certpath/zk3/cert-signed -storepass secret$ -noprompt > /dev/null 2>&1

