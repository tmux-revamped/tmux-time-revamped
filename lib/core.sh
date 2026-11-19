#!/bin/sh
# shellcheck disable=SC2034

[ -n "${TIME_REVAMPED_CORE_LOADED:-}" ] && return 0
TIME_REVAMPED_CORE_LOADED=1

readonly TIME_REVAMPED_VERSION="3.0.0"
