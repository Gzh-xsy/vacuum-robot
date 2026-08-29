#!/usr/bin/env bash
# run_nav_test.sh — Nav2 navigation smoke test WITHOUT AMCL.
# Localization comes from slam_toolbox (proven on this robot).
# Assumes: sim (run_sim.sh) AND slam_toolbox AND navigation_launch.py are running.
# Note: no 'set -u' on purpose — ROS setup.bash reads unset vars.
set -o pipefail
source /opt/ros/humble/setup.bash
source ~/ros_ws/install/setup.bash

echo "== [1/5] wait for nav2 nodes =="
for i in $(seq 1 30); do
  ros2 node list 2>/dev/null | grep -q bt_navigator && break
  sleep 1
done
if ! ros2 node list 2>/dev/null | grep -q bt_navigator; then
  echo "FATAL: bt_navigator not found. Is navigation_launch running?"
  exit 1
fi
echo "OK: nav2 navigation nodes present"

echo "== [2/5] activate navigation lifecycle nodes (from live node list) =="
NODES=$(ros2 node list 2>/dev/null | grep -E "controller_server|smoother_server|planner_server|behavior_server|bt_navigator|waypoint_follower|velocity_smoother|costmap" | sort -u)
echo "  activating: $NODES"
for n in $NODES; do
  timeout 5 ros2 lifecycle set $n configure >/dev/null 2>&1 || true
  timeout 5 ros2 lifecycle set $n activate  >/dev/null 2>&1 || true
done
sleep 3

echo "== [3/5] lifecycle states =="
for n in /controller_server /planner_server /bt_navigator; do
  echo "  $n -> $(ros2 lifecycle get $n 2>/dev/null)"
done

echo "== [4/5] map->odom TF (slam_toolbox must publish this) =="
timeout 4 ros2 run tf2_ros tf2_echo map odom 2>&1 | head -3 || echo "  TF: not yet"

echo "== [5/5] navigate to bed (2.5, 2.8) =="
timeout 45 ros2 action send_goal /navigate_to_pose nav2_msgs/action/NavigateToPose "{pose: {header: {frame_id: map}, pose: {position: {x: 2.5, y: 2.8}, orientation: {w: 1.0}}}}"
echo "== DONE =="
