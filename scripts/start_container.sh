#!/bin/bash

# starts the container (using Apple's container CLI) and xvcd for USB forwarding

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/header.sh"
validate_macos

# this is called when the container stops or ctrl+c is hit
function stop_container {
    container kill vivado_container > /dev/null 2>&1
    f_echo "Stopped container"
    killall xvcd > /dev/null 2>&1
    f_echo "Stopped xvcd"
    exit 0
}
trap 'stop_container' INT

# check if container CLI is installed
if ! which container &> /dev/null
then
    f_echo "You need to install the Apple container CLI first."
    exit 1
fi

if [[ $(container ls) == *vivado_container* ]]
then
    f_echo "There is already an instance of the container running."
    exit 1
fi
killall xvcd > /dev/null 2>&1

# run container
container run --init --rm --name vivado_container -p 5901:5901 --mount type=bind,source="$script_dir/..",target="/home/user" --arch amd64 x64-linux sudo -H -u user bash /home/user/scripts/linux_start.sh &
f_echo "Started container"
sleep 7
f_echo "Starting VNC viewer"
vncpass=$( tr -d "\n\r\t " < "$script_dir/vncpasswd" )
osascript -e "tell application \"Screen Sharing\" to GetURL \"vnc://user:$vncpass@localhost:5901\""
f_echo "Running xvcd for USB forwarding..."
# while vivado_container is running
while [[ $(container ls) == *vivado_container* ]]
do
    # if there is a running instance of xvcd
    if pgrep -x "xvcd" > /dev/null
    then
        :
    else
        eval "$script_dir/xvcd/bin/xvcd > /tmp/xvcd.log 2>&1 &"
        sleep 2
    fi
done
stop_container
