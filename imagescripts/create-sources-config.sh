#!/bin/bash -x

set -e

if [ "$FLUENTD_SOURCE_TCP" = 'true' ]; then
  fluentd_tcp_port="24224"
  if [ -n "${FLUENTD_SOURCE_TCP_PORT}" ]; then
    fluentd_tcp_port=${FLUENTD_SOURCE_TCP_PORT}
  fi
  cat >> /opt/fluentd/generatedconf.d/generated-source.conf <<_EOF_
<source>
  @type forward
  @id forward_input
  port ${fluentd_tcp_port}
  bind 0.0.0.0
</source>
_EOF_
fi

if [ "$FLUENTD_SOURCE_SOCKET" = 'true' ]; then
  fluentd_unix_path="/opt/fluentd/unix/socket.sock"
  if [ -n "${FLUENTD_SOURCE_SOCKET_PATH}" ]; then
    fluentd_unix_path=${FLUENTD_SOURCE_SOCKET_PATH}
  fi
  cat >> /opt/fluentd/generatedconf.d/generated-source.conf <<_EOF_
<source>
  @type unix
  path ${fluentd_unix_path}
</source>
_EOF_
fi

if [ "$FLUENTD_SOURCE_HTTP" = 'true' ]; then
  fluentd_http_port="8888"
  if [ -n "${FLUENTD_SOURCE_HTTP_PORT}" ]; then
    fluentd_http_port=${FLUENTD_SOURCE_HTTP_PORT}
  fi
  cat >> /opt/fluentd/generatedconf.d/generated-source.conf <<_EOF_
<source>
  @type http
  @id http_input
  port ${fluentd_http_port}
  bind 0.0.0.0
  body_size_limit 32m
  keepalive_timeout 10s
</source>
_EOF_
fi

echo "File sources configuration created: "
cat /opt/fluentd/generatedconf.d/generated-source.conf
