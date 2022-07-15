#! /bin/sh

/usr/bin/confd -onetime -backend env

/usr/bin/otelcol-contrib "$@"