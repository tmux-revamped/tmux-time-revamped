#!/bin/sh

time_revamped_dir=$(cd "$(dirname "$0")" && pwd)
"${time_revamped_dir}/bin/time-revamped" apply
