#!/bin/bash

while true; do
  clear
  echo "=== SYSTEM INFORMATION ==="
  echo -e "  == Hello $LOGNAME! ==\n"

  PS3=$'\nChoose An Option: '
  select option in "Memory Usage" "CPU Information" "NVIDIA Information" "Check Disk Space" "Check IP ADDR" "Uptime" "Exit"; do
    case $option in
    "Memory Usage")
      free -h
      ;;
    "CPU Information")
      lscpu | grep "Model name" | sed 's/  */ /g'
      ;;
    "NVIDIA Information")
      nvidia-smi --query-gpu=name | grep NVIDIA
      ;;
    "Check Disk Space")
      while true; do
        clear
        printf $'\nChoose Which Directory to Check\n\n'
        select dir in "Root Directory" "Home Directory" "Go Back"; do
          case $dir in
          "Root Directory")
            df -h /
            ;;
          "Home Directory")
            df -h ~
            ;;
          "Go Back")
            break 2
            ;;
          *)
            echo "Invalid Option!"
            ;;
          esac
          read -p $'\nPress Enter To Continue...'
          break
        done
      done
      STORAGE=$(df -h / | tail -n 1 | tr -s ' ' | cut -d ' ' -f 5 | tr -d '%')
      # Storage is the Root Directory as I intend it as a universal storage Checker
      if [[ $STORAGE -ge 30 && $STORAGE -le 39 ]]; then
        echo Early Warning: Running Out Of Storage.
      elif [[ $STORAGE -ge 40 && $STORAGE -le 49 ]]; then
        echo Moderate Warning: Running Out Of Storage.
      elif [[ $STORAGE -ge 50 && $STORAGE -le 59 ]]; then
        echo Serious Warning: Running Out Of Storage.
      elif [[ $STORAGE -ge 60 && $STORAGE -le 100 ]]; then
        echo Critical Warning: Running Out Of Storage.
      else
        echo Storage Is Fine.
      fi
      ;;
    "Check IP ADDR")
      ip -4 addr show wlan0 | grep inet | tr -s ' ' | cut -d ' ' -f 3
      ;;
    "Uptime")
      uptime -p | cut -d ' ' -f 2,3,4,5
      ;;
    "Exit")
      echo "Goodbye!"
      break 2
      ;;
    *)
      echo "Invalid Option!"
      ;;
    esac
    read -p $'\nPress Enter To Continue...'
    break
  done
done
