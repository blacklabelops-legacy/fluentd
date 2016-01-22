#!/bin/bash
#
# A helper script for ENTRYPOINT.

set -e

if [ -n "${LOGGLY_ENV_FILE}" ]; then
  source ${LOGGLY_ENV_FILE}
fi

# Resetting conf file on each startup
cp /opt/fluentd/fluent.conf /etc/fluent.conf

loggly_tag="fluentdloggly"

if [ -n "${LOGGLY_TAG}" ]; then
  loggly_tag=${LOGGLY_TAG}
fi

loggly_match="containerlog.**"

if [ -n "${LOGGLY_MATCH}" ]; then
  loggly_match=${LOGGLY_MATCH}
fi

if [ -n "${LOGGLY_TOKEN}" ]; then
  cat >> /etc/fluent/fluent.conf <<_EOF_

<match ${loggly_match}>
  type loggly
  loggly_url https://logs-01.loggly.com/inputs/${LOGGLY_TOKEN}/tag/${loggly_tag}
</match>

_EOF_
fi

unset LOGGLY_TOKEN

# Invoke entrypoint of parent container
if [ "$1" = 'fluentd' ]; then
  /etc/fluent/docker-entrypoint.sh $@
fi

exec "$@"
