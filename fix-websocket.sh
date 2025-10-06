#!/bin/sh

# Fix WebSocket URL in GoAccess output
# This script runs GoAccess without ws-url to get default behavior

tail -F /var/log/traefik/access.log | \
goaccess - \
  --log-format='%h %^[%d:%t %^] "%r" %s %b "%R" "%u"' \
  --date-format='%d/%b/%Y' \
  --time-format='%H:%M:%S' \
  --real-time-html \
  --port=7890 \
  --addr=0.0.0.0 \
  -o /srv/report/index.html