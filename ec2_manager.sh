#!/bin/bash
set -euo pipefail

check_aws_config() {
  if ! aws sts get-caller-identity &>/dev/null; then
    echo "AWS CLI is not configured properly."
    exit 1
  fi
}

start_instance() {
  local instance_id=$1
  aws ec2 start-instances --instance-ids "$instance_id"
}

stop_instance() {
  local instance_id=$1
  aws ec2 stop-instances --instance-ids "$instance_id"
}

describe_instance() {
  local instance_id=$1
  aws ec2 describe-instances --instance-ids "$instance_id"
}

main() {
  check_aws_config
  case "$1" in
    start) start_instance "$2" ;;
    stop) stop_instance "$2" ;;
    describe) describe_instance "$2" ;;
    *) echo "Usage: $0 {start|stop|describe} <instance-id>"; exit 1 ;;
  esac
}

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 {start|stop|describe} <instance-id>"
  exit 1
fi

main "$@"#!/bin/bash
