#!/usr/bin/env bash
# run_sim_manual.sh — fallback: start sim WITHOUT the launch frontend.
# Run inside the VM:   bash ~/ros_ws/src/vacuum_description/launch/run_sim_manual.sh
# (or copy to ~/ and run)
set -e
source /opt/ros/humble/setup.bash
source ~/ros_ws/install/setup.bash

URDF="$HOME/ros_ws/src/vacuum_description/urdf/vacuum.urdf"
WORLD="/opt/ros/humble/share/gazebo_ros/worlds/empty.world"

echo "== starting gazebo =="
gazebo "$WORLD" &
GAZEBO_PID=$!
sleep 8

echo "== spawn robot =="
ros2 run gazebo_ros spawn_entity.py -file "$URDF" -entity vacuum -x 0 -y 0 -z 0.05

echo "== robot state publisher =="
ros2 run robot_state_publisher robot_state_publisher --ros-args -p robot_description:="$(cat "$URDF")" &
RSP_PID=$!
sleep 2

echo ""
echo "robot is in gazebo. In OTHER terminals run:"
echo "  source ~/ros_ws/install/setup.bash && ros2 run vacuum_demo scan_monitor"
echo "  source ~/ros_ws/install/setup.bash && ros2 run vacuum_demo odom_spinner"
echo "  source ~/ros_ws/install/setup.bash && ros2 run teleop_twist_keyboard teleop_twist_keyboard"
echo ""
echo "Ctrl-C here to stop gazebo and rsp."

wait
