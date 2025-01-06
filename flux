#!/bin/bash

help() {
  cat<<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [status | battery <enable|disable> | ac <enable|disable> | all <enable|disable>]

Script to manage energy saver settings.

Available options:

-h, --help                Print this help and exit
status                    Print the status of the energy saver on battery and AC power.
battery <enable|disable>  Manage energy saver for battery power.
ac <enable|disable>       Manage energy saver for AC power.
all <enable|disable>      Manage energy saver for both battery and AC power.

Must be run as root except for help and status.

EOF
}

get_status() {
  local battery_lowpowermode
  local ac_lowpowermode

  battery_lowpowermode=$(pmset -g custom | grep -A 15 "Battery Power" | grep "lowpowermode" | awk '{print $2}')
  ac_lowpowermode=$(pmset -g custom | grep -A 15 "AC Power" | grep "lowpowermode" | awk '{print $2}')

  echo "Battery Power - lowpowermode: $battery_lowpowermode"
  if [ "$battery_lowpowermode" -eq 1 ]; then
    echo "Low Power Mode is enabled for battery power."
  else
    echo "Low Power Mode is disabled for battery power."
  fi

  echo "AC Power - lowpowermode: $ac_lowpowermode"
  if [ "$ac_lowpowermode" -eq 1 ]; then
    echo "Low Power Mode is enabled for AC power."
  else
    echo "Low Power Mode is disabled for AC power."
  fi
}

check_status() {
  if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root or using sudo!"
    exit 1
  fi
}

if [ $# -eq 0 ]; then
    echo "No arguments supplied."
    exit 1
fi

case $1 in
  status)
    get_status
    exit 0
    ;;
  battery)
    shift
    case $1 in
      enable)
        check_status
        pmset -b lowpowermode 1
        echo "Low power mode turned on for battery."
        ;;
      disable)
        check_status
        pmset -b lowpowermode 0
        echo "Low power mode turned off for battery."
        ;;
      *)
        echo "Invalid option for battery: $1"
        exit 1
        ;;
    esac
    ;;
  ac)
    shift
    case $1 in
      enable)
        check_status
        pmset -c lowpowermode 1
        echo "Low power mode turned on for AC power."
        ;;
      disable)
        check_status
        pmset -c lowpowermode 0
        echo "Low power mode turned off for AC power."
        ;;
      *)
        echo "Invalid option for AC: $1"
        exit 1
        ;;
    esac
    ;;
  all)
    shift
    case $1 in
      enable)
        check_status
        pmset -a lowpowermode 1
        echo "Low power mode turned on for both battery and AC power."
        ;;
      disable)
        check_status
        pmset -a lowpowermode 0
        echo "Low power mode turned off for both battery and AC power."
        ;;
      *)
        echo "Invalid option for all: $1"
        exit 1
        ;;
    esac
    ;;
  -h|--help)
    help
    ;;
  *)
    echo "Unknown option: $1"
    help
    exit 1
    ;;
esac
