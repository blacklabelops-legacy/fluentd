#!/bin/bash -x

set -e

log_dir="/var/log"

if [ -n "${TAIL_LOGS_DIR}" ]; then
  log_dir=${TAIL_LOGS_DIR}
fi

log_dirs=""

if [ -n "${TAIL_LOGS_DIRECTORIES}" ]; then
  log_dirs=${TAIL_LOGS_DIRECTORIES}
else
  log_dirs=${log_dir}
fi

logs_ending="log"
TAIL_LOGS_FILE_ENDINGS_INSTRUCTION=""
log_file_pattern=""

if [ -n "${TAIL_LOG_FILE_PATTERN}" ]; then
  log_file_pattern=${TAIL_LOG_FILE_PATTERN}
  logs_ending=
fi

if [ -n "${TAIL_LOG_FILE_ENDINGS}" ]; then
  logs_ending=${TAIL_LOG_FILE_ENDINGS}
fi

log_format="none"

if [ -n "${TAIL_LOG_FILE_FORMAT}" ]; then
  log_format=${TAIL_LOG_FILE_FORMAT}
fi

log_file_ignore_pattern=""

if [ -n "${TAIL_LOG_FILE_IGNORE_PATTERN}" ]; then
  log_file_ignore_pattern=${TAIL_LOG_FILE_IGNORE_PATTERN}
fi

if [ -n "${logs_ending}" ]; then
  SAVEIFS=$IFS
  IFS=' '
  COUNTER=0
  for ending in $logs_ending
  do
    if [ "$COUNTER" -eq "0" ]; then
      LOGS_FILE_ENDINGS_INSTRUCTION="$TAIL_LOGS_FILE_ENDINGS_INSTRUCTION -iname "*.${ending}""
    else
      LOGS_FILE_ENDINGS_INSTRUCTION="$TAIL_LOGS_FILE_ENDINGS_INSTRUCTION -o -iname "*.${ending}""
    fi
    let COUNTER=COUNTER+1
  done
  IFS=$SAVEIFS

  for d in ${log_dirs}
  do
    LOG_FILES=
    for f in $(find ${d} -type f $TAIL_LOGS_FILE_ENDINGS_INSTRUCTION);
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
        cat >> /opt/fluentd/generatedconf.d/generated-tail.conf <<_EOF_
<source>
  @type tail
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
    for f in $LOG_FILES;
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
        cat >> /opt/fluentd/generatedconf.d/generated-tail.conf <<_EOF_

  <source>
    @type tail
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

if [ -n "${TAIL_FILE_LOG_PATH}" ]; then
  file_log_path=${TAIL_FILE_LOG_PATH}
fi

file_log_time_slice_format="%Y%m%d%H"

if [ -n "${TAIL_FILE_LOG_TIME_SLICE_FORMAT}" ]; then
  file_log_time_slice_format=${TAIL_FILE_LOG_TIME_SLICE_FORMAT}
fi

file_log_time_slice_wait="10m"

if [ -n "${TAIL_FILE_LOG_TIME_SLICE_WAIT}" ]; then
  file_log_time_slice_wait=${TAIL_FILE_LOG_TIME_SLICE_WAIT}
fi

file_log_time_format="%Y-%m-%d-%H-%M-%S"

if [ -n "${TAIL_FILE_LOG_TIME_FORMAT}" ]; then
  file_log_time_format=${TAIL_FILE_LOG_TIME_FORMAT}
fi

file_log_flush_interval="60s"

if [ -n "${TAIL_FILE_LOG_FLUSH_INTERVAL}" ]; then
  file_log_flush_interval=${TAIL_FILE_LOG_FLUSH_INTERVAL}
fi

file_log_compress=""

if [ -n "${TAIL_FILE_LOG_COMPRESS}" ]; then
  file_log_compress="compress"
fi

file_log_append="true"

if [ -n "${TAIL_FILE_LOG_APPEND}" ]; then
  file_log_append=${TAIL_FILE_LOG_APPEND}
fi

file_log_format=""

if [ -n "${TAIL_FILE_LOG_FORMAT}" ]; then
  file_log_format="format "${TAIL_FILE_LOG_FORMAT}
fi

cat >> /opt/fluentd/generatedconf.d/generated-tail.conf <<_EOF_

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

echo "File tail configuration created: "
cat /opt/fluentd/generatedconf.d/generated-tail.conf
