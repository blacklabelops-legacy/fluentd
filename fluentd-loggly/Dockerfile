FROM blacklabelops/fluentd
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

RUN gem install fluent-plugin-loggly

ENV LOGGLY_TOKEN=
ENV LOGGLY_TAG=
ENV LOGGLY_MATCH=

WORKDIR /etc/fluent
COPY imagescripts/docker-entrypoint.sh /etc/fluent/docker-loggly-entrypoint.sh
ENTRYPOINT ["/etc/fluent/docker-loggly-entrypoint.sh"]
CMD ["fluentd"]
