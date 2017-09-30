#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

if [ "$1" = 'fluentd' ]; then
  if [ -n "${FLUENTD_DELAYED_START}" ]; then
    sleep ${FLUENTD_DELAYED_START}
  fi

  fluentd_config="/opt/fluentd/fluent.conf"

  if [ ! -n "${FLUENTD_CONFIG_FILE}" ]; then
    fluentd_config=${FLUENTD_CONFIG_FILE}
    echo "Input configuration file: "
    cat ${fluentd_config}
  else
    echo "Input configuration file: "
    cat ${fluentd_config}
    source /opt/fluentd/create-sources-config.sh
    source /opt/fluentd/create-output-config.sh
    if [ -n "${TAIL_LOGS_DIRECTORIES}" ] || [ -n "${TAIL_LOG_FILE_PATTERN}" ] || [ -n "${TAIL_LOG_FILE_ENDINGS}" ] || [ -n "${TAIL_LOG_FILE_ENDINGS}" ]; then
      source /opt/fluentd/create-tail-config.sh
    fi
  fi

  exec fluentd -c ${fluentd_config}
fi

exec "$@"
