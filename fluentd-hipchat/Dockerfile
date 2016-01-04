FROM blacklabelops/fluentd
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

RUN gem install fluent-plugin-hipchat

# disable file logging from base container
ENV DISABLE_FILE_OUT=true

WORKDIR /etc/fluent
COPY imagescripts/docker-entrypoint.sh /etc/fluent/docker-hipchat-entrypoint.sh
ENTRYPOINT ["/etc/fluent/docker-hipchat-entrypoint.sh"]
CMD ["fluentd"]
