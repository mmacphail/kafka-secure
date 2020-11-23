FROM confluentinc/cp-kafka:6.0.0
ARG truststore
ARG keystore
COPY --chown=appuser:appuser $truststore /etc/kafka/secrets/
COPY --chown=appuser:appuser $keystore /etc/kafka/secrets/
COPY --chown=appuser:appuser kafka_sslkey_creds /etc/kafka/secrets/
