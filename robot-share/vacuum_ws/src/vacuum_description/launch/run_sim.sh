#!/usr/bin/env bash
# run_sim.sh — start the vacuum sim WITHOUT the launch frontend.
# Loads gazebo_ros init/factory plugins explicitly (plain `gazebo` does NOT),
# then spawns the robot and publishes TF.
# Run inside the VM:   bash ~/ros_ws/src/vacuum_description/launch/run_sim.sh
set -e
source /opt/ros/humble/setup.bash
source ~/ros_ws/install/setup.bash

URDF="$HOME/ros_ws/src/vacuum_description/urdf/vacuum.urdf"
WORLD="$HOME/ros_ws/src/vacuum_description/worlds/house.world"

# GUI=1 to also start the Gazebo 3D window (heavy in VMs, defaults off).
# Headless (gzserver only) + RViz is the recommended combo on a VM.
GUI=${GUI:-0}

echo "== [1/4] start gazebo server (with ROS plugins) =="
gzserver -s libgazebo_ros_init.so -s libgazebo_ros_factory.so "$WORLD" &
GZ_PID=$!
sleep 3

echo "== [2/4] gazebo GUI (GUI=$GUI) =="
if [ "$GUI" = "1" ]; then
  gzclient &
  GC_PID=$!
  sleep 6
else
  echo "  headless mode: skipping gzclient. Use RViz to visualize."
  sleep 6
fi

echo "== [3/4] spawn robot =="
ros2 run gazebo_ros spawn_entity.py -file "$URDF" -entity vacuum -x 0 -y 0 -z 0.05

echo "== [4/4] robot state publisher (TF) =="
printf 'robot_state_publisher:\n  ros__parameters:\n    robot_description: |\n' > /tmp/rsp.yaml
sed 's/^/      /' "$URDF" >> /tmp/rsp.yaml
ros2 run robot_state_publisher robot_state_publisher --ros-args --params-file /tmp/rsp.yaml &
RSP_PID=$!
sleep 2

echo ""
echo "=================================================="
echo " ROBOT IS IN GAZEBO. In OTHER terminals run:"
echo "   source ~/ros_ws/install/setup.bash && ros2 run vacuum_demo scan_monitor"
echo "   source ~/ros_ws/install/setup.bash && ros2 run vacuum_demo odom_spinner"
echo "   source ~/ros_ws/install/setup.bash && ros2 run teleop_twist_keyboard teleop_twist_keyboard"
echo " Ctrl-C here to stop everything."
echo "=================================================="

wait
