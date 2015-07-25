#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

log_dir="/var/log"

# Resetting the default configuration file for
# repeated starts.
if [ ! -f "/etc/fluent/fluent.conf.old" ]; then
  cp /etc/fluent/fluent.conf /etc/fluent/fluent.conf.old
else
  cp /etc/fluent/fluent.conf.old /etc/fluent/fluent.conf
fi

if [ -n "${LOGS_DIR}" ]; then
  log_dir=${LOGS_DIR}
fi

log_dirs=""

if [ -n "${LOGS_DIRECTORIES}" ]; then
  log_dirs=${LOGS_DIRECTORIES}
else
  log_dirs=${log_dir}
fi

logs_ending="log"
LOGS_FILE_ENDINGS_INSTRUCTION=""

if [ -n "${LOG_FILE_ENDINGS}" ]; then
  logs_ending=${LOG_FILE_ENDINGS}
fi

log_format="none"

if [ -n "${LOG_FILE_FORMAT}" ]; then
  log_format=${LOG_FILE_FORMAT}
fi

SAVEIFS=$IFS
IFS=' '
COUNTER=0
for ending in $logs_ending
do
  if [ "$COUNTER" -eq "0" ]; then
    LOGS_FILE_ENDINGS_INSTRUCTION="$LOGS_FILE_ENDINGS_INSTRUCTION -iname "*.${ending}""
  else
    LOGS_FILE_ENDINGS_INSTRUCTION="$LOGS_FILE_ENDINGS_INSTRUCTION -o -iname "*.${ending}""
  fi
  let COUNTER=COUNTER+1
done
IFS=$SAVEIFS

for d in ${log_dirs}
do
  LOG_FILES=$(find ${d} -type f $LOGS_FILE_ENDINGS_INSTRUCTION)
  for f in $LOG_FILES
  do
    echo "Processing $f file..."
    pos_file=/opt/fluentd${f}.pos
    if [ ! -f "${pos_file}" ]; then
      DIR_NAME=$(dirname $pos_file)
      mkdir -p ${DIR_NAME}
      touch ${pos_file}
    fi
    FILE_NAME=$(basename $f)
    cat >> /etc/fluent/fluent.conf <<_EOF_

<source>
  type tail
  path ${f}
  tag containerlog.${FILE_NAME}
  pos_file ${pos_file}
  format ${log_format}
</source>

_EOF_
  done
done

cat /etc/fluent/fluent.conf

if [ "$1" = 'fluentd' ]; then
  fluentd -c /etc/fluent/fluent.conf -vv > /opt/fluentd/fluentd.log
fi

exec "$@"
