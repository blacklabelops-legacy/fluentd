#!/bin/bash -x

set -e

cat > /opt/fluentd/generatedconf.d/generated-output.conf <<_EOF_
_EOF_

if [ -n "$FLUENTD_OUTPUT_STDOUT_PATTERN" ]; then
  cat >> /opt/fluentd/generatedconf.d/generated-output.conf <<_EOF_
  <match ${FLUENTD_OUTPUT_STDOUT_PATTERN}>
    @type stdout
  </match>
_EOF_
fi

echo "File output configuration created: "
cat /opt/fluentd/generatedconf.d/generated-output.conf
