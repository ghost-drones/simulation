# #{ ROS shell scripts

# ROS shell scripts
# credit to https://github.com/ctu-mrs/mrs_uav_system
waitForRos() {
  until rostopic list > /dev/null 2>&1; do
    echo "waiting for ros"
    sleep 1;
  done
}

waitForSimulation() {
  until timeout 3s rostopic echo /gazebo/model_states -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for simulation"
    sleep 1;
  done
  sleep 1;
}

waitFor() {
  until timeout 3s rostopic echo $1 -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for $1"
    sleep 1;
  done
}

waitForOdometry() {
  until timeout 3s rostopic echo /$UAV_NAMESPACE/mavros/local_position/odom -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for odometry"
    sleep 1;
  done
}

waitForSLAM(){
  until timeout 3s rostopic echo /$UAV_NAMESPACE/uav/cartographer/pose -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for SLAM odometry"
    sleep 1;
  done
}

waitForGlobal() {
  until timeout 3s rostopic echo /$UAV_NAMESPACE/mavros/global_position/local -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for global odometry"
    sleep 1;
  done
}

waitForCarrot() {
  until timeout 3s rostopic echo /$UAV_NAMESPACE/carrot/status -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for carrot"
    sleep 1;
  done
}

waitForMavros() {
  until timeout 3s rostopic echo /$UAV_NAMESPACE/mavros/state -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for mavros"
    sleep 1;
  done
}

# allows killing process with all its children
killp() {

  if [ $# -eq 0 ]; then
    echo "The command killp() needs an argument, but none was provided!"
    return
  else
    pes=$1
  fi

  for child in $(ps -o pid,ppid -ax | \
    awk "{ if ( \$2 == $pes ) { print \$1 }}")
    do
      # echo "Killing child process $child because ppid = $pes"
      killp $child
    done

# echo "killing $1"
kill -9 "$1" > /dev/null 2> /dev/null
}

waitForSysStatus() {
  until timeout 3s rostopic echo /$UAV_NAMESPACE/mavros/state -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for /$UAV_NAMESPACE/mavros/state"
    sleep 1;
  done

  while true
    do
      system_status=$(echo "$(rostopic echo /$UAV_NAMESPACE/mavros/state -n 1| grep system_status)" | awk '{print $2}')
      if [[ $system_status == "3" ]]; then
          break
        else
          echo "waiting for system_status"
        fi
      sleep 1
    done
}

waitForTracker() {
  until timeout 3s rostopic echo /$UAV_NAMESPACE/tracker/status -n 1 --noarr > /dev/null 2>&1; do
    echo "waiting for /$UAV_NAMESPACE/tracker/status"
    sleep 1;
  done
  
  while true
    do
      tracker_status=$(rostopic echo /$UAV_NAMESPACE/tracker/status -n 1 | awk '{print $2}')
      if [[ $TRACKER_STATUS == "ACCEPT" ]]; then
          break
        else
          echo "waiting for /$UAV_NAMESPACE/tracker/status == ACCEPT"
        fi
      sleep 1
    done
}

# #}

# #{ Docker Helper scripts

# TODO...

# #}

# #{ generateUdevRules()

generateUdevRule(){
  symlink_appendix="newlink"
  help_flag=false

  while true; do
    case "$1" in
    -s | --symlink ) symlink_appendix=$2; shift 2 ;;
    --help ) help_flag=true; shift ;;
    * ) break ;;
    esac
  done

  if [ $help_flag == true ]; then
      echo "Usage:"
      echo "  Generate udev rule for a serial USB device. It's a function so it has be sourced."
      echo "Running:"
      echo "  "
      echo "  generateUdevRule -s new_symlink"
      echo "  "
      echo "Options:"
      echo "  -s , --symlink      Give a name to the symlinked device."
      echo "       --help         Well, display help."
      return
  fi


  \ls -1 /dev/tty* > before.tty.list
  for (( ; ; ))
  do
    sleep 1
    echo "Please disconnect and reconnect the device ..."
    \ls -1 /dev/tty* > after.tty.list
    ttydev=$(diff before.tty.list after.tty.list 2> /dev/null | grep '>' | sed 's/> //')

    if [[ -z "${ttydev}" ]]; then
      \ls -1 /dev/tty* > before.tty.list
    else
      break
    fi
  done
  echo "Device connected: ${ttydev}"
  rm -f before.tty.list after.tty.list


  serial=$(udevadm info -a -n ${ttydev} | grep '{serial}' | head -n1)
  idvendor=$(udevadm info -a -n ${ttydev} | grep '{idVendor}' | head -n1)
  idproduct=$(udevadm info -a -n ${ttydev} | grep '{idProduct}' | head -n1)

  IFS='\"'
  read -a serial_split <<< "$serial"
  read -a idvendor_split <<< "$idvendor"
  read -a idproduct_split <<< "$idproduct"
  IFS=''


  echo "The following serial device is found:"
  echo "SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"${idvendor_split[1]}\", ATTRS{idProduct}==\"${idproduct_split[1]}\", ATTRS{serial}==\"${serial_split[1]}\", SYMLINK+=\"${symlink_appendix}\"" 
  read -r -p "Do you want me to write it in /etc/udev/rules.d/99-usb-serial.rules? I will create the file if it does not exist [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) 
      if ! test -f /etc/udev/rules.d/99-usb-serial.rules; then
        # Check if the file exists
        echo "File /etc/udev/rules.d/99-usb-serial.rules does not exist. Creating it now. May need root privileges."
        sudo touch /etc/udev/rules.d/99-usb-serial.rules
      fi
      echo "SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"${idvendor_split[1]}\", ATTRS{idProduct}==\"${idproduct_split[1]}\", ATTRS{serial}==\"${serial_split[1]}\", SYMLINK+=\"${symlink_appendix}\"" | sudo tee -a /etc/udev/rules.d/99-usb-serial.rules
      sudo udevadm control --reload-rules && sudo udevadm trigger
      echo "Device added."
      ;;
    *)
      echo "Not adding the device."
      ;;
  esac
}

# #}
