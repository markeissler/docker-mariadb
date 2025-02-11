#!/usr/bin/env bash
#
# docker-entrypoint.sh
#

pushd "${PWD}"

PATH_CERTS="/etc/my.cnf.d/certificates"

# SERVER
#
# - generate CA key (ca.key)
# - create CA certificate (ca.crt -- with CA key)
# - generate server key (server.key)
# - create certificate signing request (server.csr -- with server.key)
# - create server certficiate (server.crt -- with server.csr, ca.crt and ca.key)
# - delete the ca.key, no longer needed
#
# - configure mariadb with the following
# [mariadb]
# ssl-ca="${PATH_CERTS}/ca.crt"
# ssl-cert="${PATH_CERTS}/server.crt"
# ssl-key="${PATH_CERTS}/server.key
#

cd "${PATH_CERTS}" \
    && openssl genrsa -out ca.key 2048 \
    && openssl req -new -x509 -days 365 -key ca.key -out ca.crt \
        -subj "/C=US/ST=Texas/L=Austin/O=OrgName/OU=IT Department/CN=MyCA" \
    && chmod 400 ca.{crt,key} \
    && openssl genrsa -out server.key 2048 \
    && openssl req -new -key server.key -out server.csr \
        -subj "/C=US/ST=Texas/L=Austin/O=OrgName/OU=IT Department/CN=example.com" \
    && openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt \
    && chmod 644 ca.srl \
    && chmod 400 server.{crt,csr,key}

# CLIENT
#
# - generate client key (client.key)
# - create certificate signing request (client.csr -- with client.key)
# - create client certficiate (client.crt -- with client.csr, ca.crt and ca.key)
#
# - configure client with the following
# [client]
# ssl-ca=/path/to/ca.crt
# ssl-cert=/path/to/client.crt
# ssl-key=/path/to/client.key
#

cd "${PATH_CERTS}" \
    && openssl genrsa -out client.key 2048 \
    && openssl req -new -key client.key -out client.csr \
        -subj "/C=US/ST=Texas/L=Austin/O=OrgName/OU=IT Department/CN=client" \
    && openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt \
    && chmod 400 client.{crt,csr,key} \
    && printf "\nClient Certificate:\n\n" \
    && cat client.crt \
    && printf "\nClient Key:\n\n" \
    && cat client.key

popd 2>&1 > /dev/null

#
# Source original docker-entrypoint.sh
#
source "/usr/local/bin/docker-entrypoint.sh"

#
# Run command (usually starts the target app)
#

# Duplicate source entrypoint functionality
if ! _is_sourced; then
        _main "$@"
fi
