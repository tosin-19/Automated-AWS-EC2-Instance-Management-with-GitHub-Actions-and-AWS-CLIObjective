#!/bin/bash

# ==============================
# EC2 Manager Script
# ==============================
set -euo pipefail

check_aws_config() {
  if ! aws sts get-caller-identity &>/dev/null; then
    echo
    exit 1
  fi
}

start_instance() {
  local instance_id=$1
  echo "Starting instance: $instance_id ..."
  aws ec2 start-instances --instance-ids "$instance_id" >/dev/null
  echo "Instance $instance_id started."
}

stop_instance() {
  local instance_id=$1
  echo "Stopping instance: $instance_id ..."
  aws ec2 stop-instances --instance-ids "$instance_id" >/dev/null
  echo "Instance $instance_id stopped."
}

describe_instance() {
  local instance_id=$1
  echo "Details for instance: $instance_id ..."
  aws ec2 describe-instances --instance-ids "$instance_id" \
    --query '
    --output '
}

if [[ $# -ge 2 ]]; then
  check_aws_config
  command=$1
  instance_id=$2

  case $command in
    start)
      start_instance "$instance_id"
      ;;
    stop)
      stop_instance "$instance_id"
      ;;
    describe)
      describe_instance "$instance_id"
      ;;
    *)
      echo "$command"
      echo "Usage: $0 
      exit 1
      ;;
  esac
  exit 0
fi

main_menu() {
  check_aws_config

  while true; do
    echo -e "\n====== EC2 Manager ======"
    echo "1. Start Instance"
    echo "2. Stop Instance"
    echo "3. Describe Instance"
    echo "4. Exit"
    read -rp " choice

    case $choice in
      1)
        read -rp "Enter Instance ID: " instance_id
        start_instance "$instance_id"
        ;;
      2)
        read -rp "Enter Instance ID: " instance_id
        stop_instance "$instance_id"
        ;;
      3)
        read -rp "Enter Instance ID: " instance_id
        describe_instance "$instance_id"
        ;;
      4)
        echo "Exiting..."
        exit 0
        ;;
      *)
        echo "Invalid option. Please choose 1–4."
        ;;
    esac
  done
}

main_menu
