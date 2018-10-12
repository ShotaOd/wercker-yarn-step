#!/bin/bash

main() {
  if [ "$WERCKER_YARN_USE_CACHE" == "true" ]; then
    info "Using wercker cache"
    setup_cache
  fi

  set +e
  run_yarn
  set -e

  success "Finished yarn"
}

setup_cache() {
  debug 'Creating $WERCKER_CACHE_DIR/wercker/yarn'
  mkdir -p "$WERCKER_CACHE_DIR/wercker/yarn"
  
  debug 'Configuring npm to use wercker cache'
  yarn config set cache-folder "$WERCKER_CACHE_DIR/wercker/npm"
}

clear_cache() {
  warn "Clearing yarn cache"
  yarn cache clear
  
  # make sure the cache contains something, so it will override cache that get's stored
  debug 'Creating $WERCKER_CACHE_DIR/wercker/yarn'
  mkdir -p "$WERCKER_CACHE_DIR/wercker/yarn"
  printf keep > "$WERCKER_CACHE_DIR/wercker/yarn/.keep"
}

run_yarn() {
  local retries=$WERCKER_YARN_RETRIES;
  local command=$WERCKER_YARN_COMMAND
  for try in $(seq "$retries"); do
    info "Starting yarn $command, try: $try"
    yarn $command && return;

    if [ "$WERCKER_YARN_CLEAR_CACHE_ON_FAIL" == "true" ]; then
      clear_cache
    fi
  done

  fail "Failed to successfully execute yarn, retries: $retries"
}

main;
