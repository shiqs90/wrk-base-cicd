#!/bin/bash
set -e

# Default values
DEFAULT_ENV="development"
DEFAULT_DEBUG="false"

# Set defaults if not provided
NODE_ENV=${NODE_ENV:-$DEFAULT_ENV}
DEBUG=${DEBUG:-$DEFAULT_DEBUG}

# Build the command based on worker type
case "$1" in
  "wrk-ork-proc-aggr")
    CLUSTER=${CLUSTER:-1}
    STORE_PRIMARY_KEY=${STORE_PRIMARY_KEY:-"default-ork-key"}
    exec node worker.js --wtype wrk-ork-proc-aggr --env "$NODE_ENV" --cluster "$CLUSTER" --debug "$DEBUG" --storePrimaryKey "$STORE_PRIMARY_KEY"
    ;;
  "wrk-book-rack")
    RACK_ID=${RACK_ID:-book-rack-default}
    STORE_PRIMARY_KEY=${STORE_PRIMARY_KEY:-"default-book-key"}
    exec node worker.js --wtype wrk-book-rack --env "$NODE_ENV" --rack "$RACK_ID" --debug "$DEBUG" --storePrimaryKey "$STORE_PRIMARY_KEY"
    ;;
  "wrk-node-http")
    PORT=${PORT:-3000}
    HOST=${HOST:-0.0.0.0}
    RACK_ID=${RACK_ID:-app-node-rack}
    STORE_PRIMARY_KEY=${STORE_PRIMARY_KEY:-"default-app-key"}
    #exec node worker.js --wtype wrk-node-http --env "$NODE_ENV" --port "$PORT" --host "$HOST" --rack "$RACK_ID" --debug "$DEBUG" --storePrimaryKey "$STORE_PRIMARY_KEY"
    exec node worker.js --wtype wrk-node-http --env "$NODE_ENV" --port "$PORT" --rack "$RACK_ID" --debug "$DEBUG" --storePrimaryKey "$STORE_PRIMARY_KEY"

    ;;
  *)
    # Default: pass through all arguments
    exec "$@"
    ;;
esac