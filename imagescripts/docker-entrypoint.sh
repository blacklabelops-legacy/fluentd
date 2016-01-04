#!/bin/bash -x
#
# A helper script for ENTRYPOINT.

set -e

if [ ! -n "${DISABLE_FILE_OUT}" ]; then
  cp /opt/fluentd/fluent.conf /etc/fluent.conf
fi

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi

log_dir="/var/log"

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
log_file_pattern=""

if [ -n "${LOG_FILE_PATTERN}" ]; then
  log_file_pattern=${LOG_FILE_PATTERN}
  logs_ending=
fi

if [ -n "${LOG_FILE_ENDINGS}" ]; then
  logs_ending=${LOG_FILE_ENDINGS}
fi

log_format="none"

if [ -n "${LOG_FILE_FORMAT}" ]; then
  log_format=${LOG_FILE_FORMAT}
fi

log_file_ignore_pattern=""

if [ -n "${LOG_FILE_IGNORE_PATTERN}" ]; then
  log_file_ignore_pattern=${LOG_FILE_IGNORE_PATTERN}
fi

if [ -n "${logs_ending}" ]; then
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
    LOG_FILES=
    for f in $(find ${d} -type f $LOGS_FILE_ENDINGS_INSTRUCTION);
    do
      if [ -f "${f}" ]; then
        echo "Processing $f file..."
        pos_file=/posfiles/fluentd${f}.pos
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
      fi
    done
  done
fi

SAVEIFS=$IFS
IFS=' '
for pattern in "${log_file_pattern}"
do
  for d in ${log_dirs}
  do
    IFS=$SAVEIFS
    LOG_FILES=$(find ${d} -type f -iname "${pattern}")
    ARRAY=$(echo $LOG_FILES | tr "\n")
    for f in $ARRAY;
    do
      if [ -f "${f}" ]; then
        echo "Processing $f file..."
        pos_file=/posfiles/fluentd${f}.pos
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
      fi
    done
    IFS=' '
  done
done
IFS=$SAVEIFS

file_log_path="/opt/fluentd/logs/container"

if [ -n "${FILE_LOG_PATH}" ]; then
  file_log_path=${FILE_LOG_PATH}
fi

file_log_time_slice_format="%Y%m%d%H"

if [ -n "${FILE_LOG_TIME_SLICE_FORMAT}" ]; then
  file_log_time_slice_format=${FILE_LOG_TIME_SLICE_FORMAT}
fi

file_log_time_slice_wait="10m"

if [ -n "${FILE_LOG_TIME_SLICE_WAIT}" ]; then
  file_log_time_slice_wait=${FILE_LOG_TIME_SLICE_WAIT}
fi

file_log_time_format="%Y-%m-%d-%H-%M-%S"

if [ -n "${FILE_LOG_TIME_FORMAT}" ]; then
  file_log_time_format=${FILE_LOG_TIME_FORMAT}
fi

file_log_flush_interval="60s"

if [ -n "${FILE_LOG_FLUSH_INTERVAL}" ]; then
  file_log_flush_interval=${FILE_LOG_FLUSH_INTERVAL}
fi

file_log_compress=""

if [ -n "${FILE_LOG_COMPRESS}" ]; then
  file_log_compress="compress"
fi

file_log_append="true"

if [ -n "${FILE_LOG_APPEND}" ]; then
  file_log_append=${FILE_LOG_APPEND}
fi

file_log_format=""

if [ -n "${FILE_LOG_FORMAT}" ]; then
  file_log_format="format "${FILE_LOG_FORMAT}
fi

if [ ! -n "${DISABLE_FILE_OUT}" ]; then
  cat >> /etc/fluent/fluent.conf <<_EOF_

<match containerlog.**>
  type file
  path ${file_log_path}
  time_slice_format ${file_log_time_slice_format}
  time_slice_wait ${file_log_time_slice_wait}
  time_format ${file_log_time_format}
  flush_interval ${file_log_flush_interval}
  append ${true}
  ${file_log_compress}
  ${file_log_format}
  buffer_type file
  buffer_path /opt/fluentd/buffer/container.*.buffer
</match>

_EOF_
fi

cat /etc/fluent/fluent.conf

if [ "$1" = 'fluentd' ]; then
  fluentd -c /etc/fluent/fluent.conf
fi

exec "$@"
