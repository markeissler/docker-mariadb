# Dockerfile
#
# This Dockerfile is used to spin up a mariadb server that supports SSL.
#
FROM mariadb:10.11-ubi
LABEL maintainer="Mark Eissler <moe@markeissler.org>"

ARG BUILD_USER="mysql"
ENV BUILD_USER="${BUILD_USER}"

ARG MYSQL_HOME="/usr/local/bin"
ENV MYSQL_HOME="${MYSQL_HOME}"

#
# Build:
#   prompt> docker build -t markeissler/mariadb10-ssl:latest .
#
# Run locally:
#   prompt> docker run -it --rm -e TERM=$TERM -e COLUMNS=$COLUMNS -e ROWS=$ROWS markeissler/mariadb10-ssl /bin/bash
#
# NOTE: You may need or want to pass the --no-cache option to build a completely fresh image.
#

ARG BUILD_TEMP="/build"
ARG MYSQL_CONF="/etc/my.cnf.d"
ARG MYSQL_CERT="${MYSQL_CONF}/certificates"

USER root

# Make temporary build dir
RUN set -x && mkdir -p "${BUILD_TEMP}"

# Copy bootstrap files into container
COPY ./docker-entrypoint-wrapper.sh ./build/docker-entrypoint-wrapper.sh

# Update docker-entrypoint.sh
RUN set -x \
    && cp "/build/docker-entrypoint-wrapper.sh" "${MYSQL_HOME}/docker-entrypoint-wrapper.sh" \
    && chmod 0755 "${MYSQL_HOME}/docker-entrypoint-wrapper.sh" \
    && chown "root":"root" "${MYSQL_HOME}/docker-entrypoint-wrapper.sh"

COPY ./docker-entrypoint-initdb.d ./build/docker-entrypoint-initdb.d

# Update docker-entrypoint-initdb.d
RUN set -x \
    && mkdir -p "/docker-entrypoint-initdb.d" \
    && chmod 0755 "/docker-entrypoint-initdb.d" \
    && chown "root":"root" "/docker-entrypoint-initdb.d" \
    && find "/build/docker-entrypoint-initdb.d" -type f -name "*.sh" -exec cp {} "/docker-entrypoint-initdb.d/" \; \
    && find "/docker-entrypoint-initdb.d/" -type f -name "*.sh" -exec chmod 0755 {} \; \
    && find "/docker-entrypoint-initdb.d/" -type f -name "*.sh" -exec chown "root":"root" {} \;

# Setup certificates directory and update mariadb/mysql configuration
RUN set -x \
    && mkdir -p "${MYSQL_CERT}" \
    && chmod 0700 "${MYSQL_CERT}" \
    && chown "${BUILD_USER}":"${BUILD_USER}" "${MYSQL_CERT}"

RUN set -x \
    && printf "\n" >> "/etc/my.cnf.d/server.cnf" \
    && printf "ssl_cert = ${MYSQL_CERT}/server.crt\n" >> "${MYSQL_CONF}/server.cnf" \
    && printf "ssl_key = ${MYSQL_CERT}/server.key\n" >> "${MYSQL_CONF}/server.cnf" \
    && printf "ssl_ca = ${MYSQL_CERT}/ca.crt\n" >> "${MYSQL_CONF}/server.cnf"

# Remove build directory
RUN set -x && rm -rf "${BUILD_TEMP}"

# Setup environment for runtime
USER ${BUILD_USER}

ENTRYPOINT ["docker-entrypoint-wrapper.sh"]

CMD [ "mariadbd" ]
