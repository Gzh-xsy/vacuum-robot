#!/usr/bin/env bash
# sync_vacuum.sh — one-click: sync packages from VMware shared folder, then build.
# Run inside the VM:   bash /mnt/hgfs/robot-share/sync_vacuum.sh
# Note: no 'set -u' on purpose — ROS setup.bash reads unset vars (AMENT_TRACE_SETUP_FILES).
set -eo pipefail

SHARE="/mnt/hgfs/robot-share/vacuum_ws"
DST="$HOME/ros_ws/src"

if [ ! -d "$SHARE/src" ]; then
  echo "ERROR: shared folder not found: $SHARE"
  echo "Check what is mounted: ls /mnt/hgfs/"
  exit 1
fi

echo "== [1/3] sync packages from shared folder =="
mkdir -p "$DST"
for pkg in "$SHARE/src"/*/; do
  [ -e "$pkg" ] || continue
  name="$(basename "$pkg")"
  echo "  + $name"
  rm -rf "$DST/$name"
  cp -r "$pkg" "$DST/$name"
done

echo "== [2/3] colcon build =="
source /opt/ros/humble/setup.bash
cd "$HOME/ros_ws"
colcon build --symlink-install

echo "== [3/3] source workspace =="
source install/setup.bash
echo ""
echo "DONE. Launch with:"
echo "  ros2 launch vacuum_description vacuum_sim.xml"
echo "In other terminals:"
echo "  source ~/ros_ws/install/setup.bash && ros2 run vacuum_demo scan_monitor"
echo "  source ~/ros_ws/install/setup.bash && ros2 run vacuum_demo odom_spinner"
