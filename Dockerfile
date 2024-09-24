FROM eclipse-temurin:21

ENV OPENFIRE_VERSION=4.8.3 \
    OPENFIRE_USER=openfire \
    OPENFIRE_DATA_DIR=/var/lib/openfire \
    OPENFIRE_HOME=/var/lib/openfire \
    OPENFIRE_LOG_DIR=/var/log/openfire

#https://github.com/igniterealtime/Openfire/releases/download/v4.8.3/openfire_4_8_3.tar.gz

RUN <<EOF
set -ex
apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo wget fontconfig libfreetype6 \
 && echo "Downloading openfire_${OPENFIRE_VERSION}_all.deb ..." \
 && wget --no-verbose "https://github.com/igniterealtime/Openfire/releases/download/v4.8.3/openfire_4_8_3.tar.gz" -O /tmp/openfire_${OPENFIRE_VERSION}.tar.gz \
 && cd $(dirname $OPENFIRE_DATA_DIR) \
 && tar xf /tmp/openfire_${OPENFIRE_VERSION}.tar.gz \
 && chmod a+x $OPENFIRE_DATA_DIR/bin/openfire.sh


#  adduser --disabled-password  --quiet --system \
#  --home /var/lib/openfire \
#  --gecos "Openfire XMPP server" --group openfire
    usermod --login openfire --home /var/lib/openfire ubuntu
    chfn -f "Openfire XMPP server" openfire
    groupmod --new-name openfire ubuntu

 mkdir -p /var/log/openfire
 mkdir -p /var/lib/openfire/embedded-db
 mkdir -p /usr/share/openfire
 chown -R openfire:openfire /usr/share/openfire
 chown -R openfire:openfire /var/lib/openfire
 chown -R openfire:openfire /var/log/openfire
 #chown -R openfire:openfire /etc/openfire
 chmod -R o-rwx /usr/share/openfire
 chmod -R o-rwx /var/lib/openfire
 chmod -R o-rwx /var/log/openfire
 #chmod -R o-rwx /etc/openfire
EOF

#  && dpkg -i --force-depends /tmp/openfire_${OPENFIRE_VERSION}_all.deb \
#  && mv /var/lib/openfire/plugins/admin /usr/share/openfire/plugin-admin \
#  && ln -s /usr/local/openjdk-17/bin/java /usr/bin/java \
#  && rm -rf /tmp/openfire_${OPENFIRE_VERSION}_all.deb \
#  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3478/tcp 3479/tcp 5222/tcp 5223/tcp 5229/tcp 5275/tcp 5276/tcp 5262/tcp 5263/tcp 7070/tcp 7443/tcp 7777/tcp 9090/tcp 9091/tcp
VOLUME ["${OPENFIRE_DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
