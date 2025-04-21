FROM stfidock/baseimage:latest

ENV LC_ALL=C 
ENV DEBIAN_FRONTEND=noninteractive

ARG OPENLDAP_GID
ARG OPENLDAP_UID
ARG OPENLDAP_ROOTPASS
ARG OPENLDAP_DOMAIN
ARG OPENLDAP_ORGANISATION

# Add openldap user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# If explicit uid or gid is given, use it.
RUN echo "Creating group " \
    && LDAP_GID=101 \
    && if [ -n "${OPENLDAP_GID}" ]; then LDAP_GID="${OPENLDAP_GID}"; fi \
    && groupadd -r -g ${LDAP_GID} openldap \
    && echo "Creating user" \
    && LDAP_UID=100 \
    && if [ -n "${OPENLDAP_UID}" ]; then LDAP_UID="${OPENLDAP_UID}"; fi \
    && useradd -l -r -g openldap -u ${LDAP_UID} openldap

# now install additional tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        openssl \
        ldap-utils \
        slapd \
        slapd-contrib \
    && apt-get remove -y --purge --auto-remove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY the content from rootfs into the container
COPY rootfs/ /

# make the default ldap port available
EXPOSE 389 636

VOLUME /etc/ldap/slapd.d
VOLUME /var/lib/ldap

#    ldap-utils=${OPENLDAP_PACKAGE_VERSION}\* \
#    libsasl2-modules \
#    libsasl2-modules-db \
#    libsasl2-modules-gssapi-mit \
#    libsasl2-modules-ldap \
#    libsasl2-modules-otp \
#    libsasl2-modules-sql \
#    krb5-kdc-ldap \


## Use baseimage install-service script
## https://github.com/osixia/docker-light-baseimage/blob/master/image/tool/install-service
#RUN /container/tool/install-service

## Add default env variables
#ADD environment /container/environment/99-default

# COPY scripts/slapd.sh /usr/local/sbin/slapd.sh
# RUN chmod 755 /usr/local/sbin/slapd.sh

#ENTRYPOINT [ "/usr/local/sbin/slapd.sh" ]
#CMD [ "-4" ]
