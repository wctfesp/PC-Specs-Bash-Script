#!/bin/bash

pause() {
  read -p $'\nPress Enter To Continue...'
}

check_file() {
  if [[ -f "$RESULT" ]]; then
    printf "\nFile Exists at: $1\n"
    return 0
  else
    printf "\nFile Not Found!\n"
    return 1
  fi
}

case "$1" in
--help)
  echo "DESCRIPTION:
  A menu-driven Linux system information utility.

USAGE:
  ./PC_Specs.sh [OPTION]

OPTIONS:
  --help       Show available options
  --version    Show current version

FEATURES:
  Memory usage
  CPU information
  NVIDIA GPU information
  Disk space monitoring
  Network information
  System uptime
  File searching

version 1.0"
  exit 0
  ;;
--version)
  echo "PC_Specs.sh version 1.0"
  exit 0
  ;;
"")
  echo "Launching interactive menu..."
  ;;
*)
  echo "Unknown option!"
  exit 1
  ;;
esac

while true; do
  clear
  echo "=== SYSTEM INFORMATION ==="
  echo -e "  == Hello $LOGNAME! ==\n"

  PS3=$'\nChoose An Option: '
  select option in "Memory Usage" "CPU Information" "GPU Information" "Check Disk Space" "Networking" "Uptime" "Find File" "Exit"; do
    case $option in
    "Memory Usage")
      free -h
      ;;
    "CPU Information")
      lscpu | grep "Model name" | sed 's/  */ /g'
      ;;
    "GPU Information")
      while true; do
        clear
        printf "\nChoose if you want to search for your GPU or automatically find your NVIDIA GPU\n\n"
        if command -v nvidia-smi &>/dev/null; then
          printf "NVIDIA Utility Found! Recommended: Find NVIDIA GPU\n"
          GPU_STATUS=0
        else
          printf "No NVIDIA Utility Found!\n"
          GPU_STATUS=1
        fi
        select gpu in "Find GPU" "Find NVIDIA GPU" "Go Back"; do
          case $gpu in
          "Find GPU")
            lspci | grep -Ei 'vga|3d|display'
            ;;
          "Find NVIDIA GPU")
            if [[ $GPU_STATUS == 0 ]]; then
              nvidia-smi --query-gpu=name | grep NVIDIA
            else
              printf "No NVIDIA GPU Detected."
            fi
            ;;
          "Go Back")
            break 2
            ;;
          *)
            echo "Invalid Option!"
            ;;
          esac
          pause
          break
        done
      done
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
          pause
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
    "Networking")
      while true; do
        clear
        printf "\nChoose from a variety of options to test your networking out!\n\n"
        select nw in "IP Address" "Pinging" "Go Back"; do
          case $nw in
          "IP Address")
            NETWORK_INTERFACE=$(ip -br -4 addr | awk '$2 == "UP"' | cut -d ' ' -f 1)
            ip -4 addr show "$NETWORK_INTERFACE" | grep inet | tr -s ' ' | cut -d ' ' -f 3
            ;;
          "Pinging")
            read -p $'\nEnter a address to ping: ' ping_out
            read -p $'\nHow many times do you wish to ping: ' numb_pack
            ping -c $numb_pack "$ping_out"
            ;;
          "Go Back")
            break 2
            ;;
          *)
            echo "Invalid Option!"
            ;;
          esac
          pause
          break
        done
      done
      ;;
    "Uptime")
      uptime -p | cut -d ' ' -f 2,3,4,5
      ;;
    "Find File")
      read -p $'\nEnter a file path to see if it exists!\n' filepath
      RESULT=$(find / -type f -iname "$filepath" 2>/dev/null)
      check_file "$RESULT"
      ;;
    "Exit")
      echo "Goodbye!"
      break 2
      ;;
    *)
      echo "Invalid Option!"
      ;;
    esac
    pause
    break
  done
done
