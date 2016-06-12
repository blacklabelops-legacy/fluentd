FROM blacklabelops/alpine:3.3
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Build time arguments
# Values: latest or version number
ARG FLUENTD_VERSION=latest

# install dev tools
RUN apk add --update \
      build-base \
      curl \
      ca-certificates \
      ruby \
      ruby-irb \
      ruby-dev && \
    echo 'gem: --no-document' >> /etc/gemrc && \
    if  [ "${FLUENTD_VERSION}" = "latest" ]; \
      then gem install fluentd ; \
      else gem install fluentd -v ${FLUENTD_VERSION} ; \
    fi && \
    mkdir -p /opt/fluentd/unix && \
    mkdir -p /opt/fluentd/conf.d && \
    mkdir -p /opt/fluentd/generatedconf.d && \
    # Install Tini Zombie Reaper And Signal Forwarder
    export TINI_VERSION=0.9.0 && \
    export TINI_SHA=fa23d1e20732501c3bb8eeeca423c89ac80ed452 && \
    curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -o /bin/tini && \
    echo 'Calculated checksum: '$(sha1sum /bin/tini) && \
    chmod +x /bin/tini && echo "$TINI_SHA  /bin/tini" | sha1sum -c - && \
    apk del \
      build-base \
      ruby-dev && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

ENV FLUENTD_CONFIG_FILE=/opt/fluentd/fluent.conf \
    FLUENTD_DELAYED_START= \
    TAIL_LOG_FILE_PATTERN= \
    TAIL_LOGS_DIRECTORIES= \
    TAIL_LOG_FILE_ENDINGS= \
    TAIL_LOG_FILE_FORMAT= \
    TAIL_LOGS_DIR= \
    TAIL_FILE_LOG_PATH= \
    TAIL_FILE_LOG_TIME_SLICE_FORMAT= \
    TAIL_FILE_LOG_TIME_SLICE_WAIT= \
    TAIL_FILE_LOG_TIME_FORMAT= \
    TAIL_FILE_LOG_FLUSH_INTERVAL= \
    TAIL_FILE_LOG_COMPRESS= \
    TAIL_FILE_LOG_APPEND= \
    TAIL_FILE_LOG_FORMAT=

EXPOSE 24224 8888

WORKDIR /opt/fluentd
VOLUME ["/opt/fluentd/posfiles"]
COPY imagescripts /opt/fluentd
ENTRYPOINT ["/bin/tini","--","/opt/fluentd/docker-entrypoint.sh"]
CMD ["fluentd"]
