FROM blacklabelops/centos
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
RUN gem install fluentd --no-ri --no-rdoc && \
    fluentd --setup /etc/fluent

WORKDIR /etc/fluent
COPY imagescripts/docker-entrypoint.sh /etc/fluent/docker-entrypoint.sh
ENTRYPOINT ["/etc/fluent/docker-entrypoint.sh"]
CMD ["fluentd"]
