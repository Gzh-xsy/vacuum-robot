# P0 仿真流程：启动 Gazebo → 遥控建图 → 保存地图

> Ubuntu 22.04 + ROS2 Humble。工程在共享文件夹 `/mnt/hgfs/robot-share/vacuum_ws`。
> 以下共 4 个终端，按顺序开。

## 终端 1：启动仿真（Gazebo 房间）

```bash
pkill -f gzserver; pkill -f gzclient; pkill -f gazebo
bash /mnt/hgfs/robot-share/sync_vacuum.sh
bash ~/ros_ws/src/vacuum_description/launch/run_sim.sh
```

等待输出 `ROBOT IS IN GAZEBO`（Gazebo 窗口出现 10x10 房间：四面灰墙 + 红箱 + 蓝柱 + 扫地机）。
> 若报 diff_drive Joint not found / 雷达无数据：先 `bash /mnt/hgfs/robot-share/sync_vacuum.sh` 确认最新代码已同步。

## 终端 2：启动 SLAM 建图

```bash
source ~/ros_ws/install/setup.bash
ros2 run slam_toolbox async_slam_toolbox_node --ros-args \
  -p use_sim_time:=true \
  -p map_frame_name:=map \
  -p odom_frame:=odom \
  -p base_frame:=base_footprint \
  -p scan_topic:=/scan
```

等待输出 `Registering sensor: [Custom Described Lidar]`（成功标志）。
> 量程 WARN 是正常裁剪，忽略。此终端保持运行。

## 终端 3：遥控移动（Humble 新版按键！）

```bash
source ~/ros_ws/install/setup.bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

按键（**不是 w/s/a/d**）：
| 键 | 动作 |
|---|---|
| z | 降速（先按几次降到 ~0.2） |
| i | 前进 |
| k | 后退 |
| j / l | 左转 / 右转 |
| 空格 | 停止 |

走法：绕房间 1-2 圈，走到四个墙角，绕红箱/蓝柱转一圈，**最后回到起点附近**（闭环回环，SLAM 靠它消除漂移）。

## 终端 4（可选）：RViz 实时看地图

```bash
source ~/ros_ws/install/setup.bash
ros2 run rviz2 rviz2 --ros-args -p use_sim_time:=true
```

- 左上 **Fixed Frame** 选 `map`
- 左侧 **Add → By topic → /map (OccupancyGrid) → OK**
- 地图随机器人移动实时生长

## 保存地图（任意新终端，绕完圈后执行）

```bash
source ~/ros_ws/install/setup.bash
mkdir -p ~/ros_ws/maps
ros2 run nav2_map_server map_saver_cli -f ~/ros_ws/maps/room
ls -l ~/ros_ws/maps/
```

成功标志：`room.pgm` + `room.yaml` 两个文件。这就是扫地机"记住的房间"，后续导航/清扫都用它。

## 常见坑速查

| 现象 | 原因 | 解决 |
|---|---|---|
| 按 w 机器人不动 | Humble teleop 是 i/j/k/l 布局，w 是调速度 | 按 i 前进 |
| RViz 无地图 | 没加 /map 显示 / 没开 use_sim_time | 按终端 4 配置 |
| /scan 不存在 | 雷达话题是 /lidar_scan/out | 已修（~/out:=scan），同步后重跑 |
| 轮子翻转不滚动 | 轮子圆柱轴与关节轴垂直 | 已修（rpy=1.5708 0 0），同步后重跑 |
| diff_drive Joint not found | 轮子 link 无惯性被转换器丢弃 | 已修（补 inertial），同步后重跑 |
| launch 报 XML 解析错 | Humble launch XML 前端残缺 | 用 run_sim.sh 手动脚本（勿用 vacuum_sim.xml） |
