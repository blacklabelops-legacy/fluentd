#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

cat > /opt/fluentd/generatedconf.d/generated-hipchat-output.conf <<_EOF_
_EOF_

hipchat_match="**"

if [ -n "${HIPCHAT_MATCH}" ]; then
  hipchat_match=${HIPCHAT_MATCH}
fi

hipchat_room=""

if [ -n "${HIPCHAT_ROOM}" ]; then
  hipchat_room=${HIPCHAT_ROOM}
fi

hipchat_from="fluentd"

if [ -n "${HIPCHAT_FROM}" ]; then
  hipchat_from=${HIPCHAT_FROM}
fi

hipchat_color="yellow"

if [ -n "${HIPCHAT_COLOR}" ]; then
  hipchat_color=${HIPCHAT_COLOR}
fi

if [ -n "${HIPCHAT_TOKEN}" ]; then
  cat >> /opt/fluentd/generatedconf.d/generated-hipchat-output.conf <<_EOF_

<match ${hipchat_match}>
  @type hipchat
  api_token ${HIPCHAT_TOKEN}
  default_room ${hipchat_room}
  default_from ${hipchat_from}
  default_color ${hipchat_color}
  default_notify 1
  default_format html
  default_timeout 3
  key_name message
</match>

_EOF_
fi

# Invoke entrypoint of parent container
if [ "$1" = 'fluentd' ]; then
  exec /opt/fluentd/docker-entrypoint.sh $@
fi
