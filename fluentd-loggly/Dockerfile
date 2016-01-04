FROM blacklabelops/fluentd
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

RUN gem install fluent-plugin-loggly

ENV LOGGLY_TOKEN=
ENV LOGGLY_TAG=
ENV LOGGLY_MATCH=
# disable file logging from base container
ENV DISABLE_FILE_OUT=true

WORKDIR /etc/fluent
COPY imagescripts/docker-entrypoint.sh /etc/fluent/docker-loggly-entrypoint.sh
ENTRYPOINT ["/etc/fluent/docker-loggly-entrypoint.sh"]
CMD ["fluentd"]
