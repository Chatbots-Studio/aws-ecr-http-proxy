#!/bin/sh
curl --fail localhost:PORT/healthz || exit 1
