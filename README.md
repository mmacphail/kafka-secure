# Config reference for docker
https://docs.confluent.io/current/installation/docker/config-reference.html

# Security

https://docs.confluent.io/6.0.0/security/security_tutorial.html

## Configuring Host Name In Certificates

If host name verification is enabled, clients will verify the server’s fully qualified domain name (FQDN) against one of the following two fields:
- Common Name (CN)
- Subject Alternative Name (SAN)

Both fields are valid, however RFC-2818 recommends the use of SAN. SAN is also more flexible, allowing for multiple DNS entries to be declared. Another advantage is that the CN can be set to a more meaningful value for authorization purposes. To add a SAN field, append the argument -ext SAN=DNS:{FQDN} to the keytool command:

keytool -keystore server.keystore.jks -alias localhost -validity {validity} -genkey -keyalg RSA -ext SAN=DNS:{FQDN}

The following command can be run afterwards to verify the contents of the generated certificate:

keytool -list -v -keystore server.keystore.jks

## Generate the keys and certificates

keytool -keystore kafka.server.keystore.jks -alias localhost -keyalg RSA -validity {validity} -genkey -storepass {keystore-pass} -keypass {key-pass} -dname {distinguished-name} -ext SAN=DNS:{hostname}

## Generate the CA

openssl req -new -x509 -keyout ca-key -out ca-cert -days {validity}

keytool -keystore kafka.client.truststore.jks -alias CARoot -importcert -file ca-cert

keytool -keystore kafka.server.truststore.jks -alias CARoot -importcert -file ca-cert

## Sign the certificate

keytool -keystore kafka.server.keystore.jks -alias localhost -certreq -file cert-file

openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days {validity} -CAcreateserial -passin pass:{ca-password}

keytool -keystore kafka.server.keystore.jks -alias CARoot -importcert -file ca-cert
keytool -keystore kafka.server.keystore.jks -alias localhost -importcert -file cert-signed
