#!/bin/sh
export ANDROID_HOME=/opt/android-sdk-linux
export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
stop_service()
{
for i in java emulator-arm x11vnc Xvfb; do pkill ${i}; done
}
initialize()
{
mkdir -p /var/run/sshd
mknod -m 600 /dev/console c 5 1
mknod /dev/tty0 c 4 0
echo no | android create avd -t "Google Inc.:Google APIs:17" -c 512M -s 480x800 -n test
echo "hw.keyboard=yes" >> ~/.android/avd/test.avd/config.ini
if
[ -n "$USER_NAME" ]
then
result=0 && for name in $(cat /etc/passwd | cut -d ":" -f1)
do
[ "$USER_NAME" = "${name}" ] && result=$(expr $result + 1) && break
done
[ $result -ne 0 ] && USER_NAME=user
else
USER_NAME=user
fi
[ -n "$USER_PASSWORD" ] || USER_PASSWORD="pass"
useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USER_NAME
passwd $USER_NAME <<EOF >/dev/null 2>&1
$USER_PASSWORD
$USER_PASSWORD
EOF
stop_service
echo "$USER_NAME@$USER_PASSWORD" > /home/$USER_NAME/.vncpass
}

username=$(ls /home/ | sed -n 1p)
if
[ -n "$username" ]
then
USER_NAME="$username"
else
initialize
fi

export DISPLAY=:0
pidof /usr/bin/Xvfb || start-stop-daemon --start --background --pidfile /var/run/Xvfb.pid --background --exec /usr/bin/Xvfb -- :0 -extension GLX -screen 0 480x800x24
pidof ${ANDROID_HOME}/tools/emulator-arm || start-stop-daemon --start --background --pidfile /var/run/emulator-arm.pid --background --exec ${ANDROID_HOME}/tools/emulator-arm -- -avd test -no-skin -no-audio -port 5554
[ -n "$LANG" ] && locale-gen "$LANG"
died_time=$(expr $(date +%s) + 10 )
window_id=`while [ $(date +%s) -lt $died_time ]
do
window_id=$(xwininfo -name  "5554:test" | grep "Window id:" | grep -Eo "0x[0-9]*")
if
[ -n "$window_id" ]
then
echo "$window_id" && break
else
sleep 1
fi
done
`
pidof /usr/bin/x11vnc || start-stop-daemon --start --background --pidfile /var/run/x11vnc.pid --background --exec /usr/bin/x11vnc -- -id $window_id -forever -display :0 -passwdfile /home/$USER_NAME/.vncpass
ps aux | grep -v grep | grep -qF "/noVNC/utils/launch.sh" || start-stop-daemon --start --quiet --pidfile /var/run/noVNC.pid --background --exec /noVNC/utils/launch.sh
exec /usr/sbin/sshd -D

