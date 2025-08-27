#!/bin/bash

# ==============================
# EC2 Manager Script
# ==============================
# Requirements:
# - AWS CLI installed and configured
# - jq installed for JSON parsing
# ==============================

set -euo pipefail

# Function: Check AWS CLI configuration
check_aws_config() {
  if ! aws sts get-caller-identity &>/dev/null; then
    echo "AWS CLI is not configured properly. Please run 'aws configure' or set environment variables."
    exit 1
  fi
}

# Function: Start instance
start_instance() {
  local instance_id=$1
  echo "🔄 Starting instance: $instance_id ..."
  if aws ec2 start-instances --instance-ids "$instance_id" >/dev/null 2>&1; then
    aws ec2 describe-instances --instance-ids "$instance_id" \
      --query 'Reservations[0].Instances[0].State.Name' --output text
    echo "Instance $instance_id started successfully."
  else
    echo "Failed to start instance $instance_id. Check instance ID or state."
  fi
}

# Function: Stop instance
stop_instance() {
  local instance_id=$1
  echo "🔄 Stopping instance: $instance_id ..."
  if aws ec2 stop-instances --instance-ids "$instance_id" >/dev/null 2>&1; then
    aws ec2 describe-instances --instance-ids "$instance_id" \
      --query 'Reservations[0].Instances[0].State.Name' --output text
    echo "Instance $instance_id stopped successfully."
  else
    echo "Failed to stop instance $instance_id. Check instance ID or state."
  fi
}

# Function: Describe instance
describe_instance() {
  local instance_id=$1
  echo "Retrieving details for instance: $instance_id ..."
  if ! aws ec2 describe-instances --instance-ids "$instance_id" >/tmp/instance.json 2>/dev/null; then
    echo "Invalid instance ID: $instance_id"
    return
  fi
  jq '.Reservations[0].Instances[0] | {InstanceId, InstanceType, State: .State.Name, PublicIp: .PublicIpAddress}' /tmp/instance.json
}

# Menu Loop
main_menu() {
  check_aws_config

  while true; do
    echo -e "\n====== EC2 Manager ======"
    echo "1. Start Instance"
    echo "2. Stop Instance"
    echo "3. Describe Instance"
    echo "4. Exit"
    read -rp "Choose an option [1-4]: " choice

    case $choice in
      1)
        read -rp "Enter Instance ID: " instance_id
        [ -z "$instance_id" ] && echo "Instance ID cannot be empty!" && continue
        start_instance "$instance_id"
        ;;
      2)
        read -rp "Enter Instance ID: " instance_id
        [ -z "$instance_id" ] && echo "Instance ID cannot be empty!" && continue
        stop_instance "$instance_id"
        ;;
      3)
        read -rp "Enter Instance ID: " instance_id
        [ -z "$instance_id" ] && echo "Instance ID cannot be empty!" && continue
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

#Correct entrypoint
main_menu "$@"
