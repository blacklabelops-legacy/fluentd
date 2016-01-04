FROM blacklabelops/centos:7.2.1511
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install dev tools
RUN yum install -y \
    sudo \
    ruby \
    ruby-devel \
    gcc \
    make \
    gem && \
    yum clean all && rm -rf /var/cache/yum/*

# install fluentd
RUN gem install fluentd:0.12.19 --no-ri --no-rdoc && \
    fluentd --setup /etc/fluent && \
    mkdir /opt/fluentd

ENV LOG_FILE_PATTERN=
ENV LOGS_DIRECTORIES=
ENV LOG_FILE_ENDINGS=
ENV LOG_FILE_FORMAT=
ENV DISABLE_FILE_OUT=
ENV DELAYED_START=
ENV LOGS_DIR=
ENV ALL_LOGS_DIRECTORIES=
ENV FILE_LOG_PATH=
ENV FILE_LOG_TIME_SLICE_FORMAT=
ENV FILE_LOG_TIME_SLICE_WAIT=
ENV FILE_LOG_TIME_FORMAT=
ENV FILE_LOG_FLUSH_INTERVAL=
ENV FILE_LOG_COMPRESS=
ENV FILE_LOG_APPEND=
ENV FILE_LOG_FORMAT=
ENV DISABLE_FILE_OUT=

WORKDIR /etc/fluent
VOLUME ["/posfiles"]
COPY imagescripts/docker-entrypoint.sh /etc/fluent/docker-entrypoint.sh
COPY configuration/fluent.conf /opt/fluentd/fluent.conf
ENTRYPOINT ["/etc/fluent/docker-entrypoint.sh"]
CMD ["fluentd"]
