# name: robot-share/vacuum_ws/src/vacuum_description/launch/vacuum_sim_launch.py
import os
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from ament_index_python.packages import get_package_share_directory


def generate_launch_description():
    pkg_share = get_package_share_directory('vacuum_description')

    urdf_path = os.path.join(pkg_share, 'urdf', 'vacuum.urdf')
    world_path = os.path.join(pkg_share, 'worlds', 'house.world')

    gui = LaunchConfiguration('gui', default='0')
    use_sim_time = LaunchConfiguration('use_sim_time', default='true')

    ld = LaunchDescription()
    ld.add_action(DeclareLaunchArgument('gui', default_value='0', description='Start gzclient (1) or headless (0)'))
    ld.add_action(DeclareLaunchArgument('use_sim_time', default_value='true', description='Use sim time'))

    # start gzserver with ROS plugins
    gzserver_cmd = Node(
        package='gazebo_ros',
        executable='gzserver',
        name='gzserver',
        output='screen',
        arguments=['-s', 'libgazebo_ros_init.so', '-s', 'libgazebo_ros_factory.so', world_path]
    )
    ld.add_action(gzserver_cmd)

    # spawn robot
    spawn_cmd = Node(
        package='gazebo_ros',
        executable='spawn_entity.py',
        name='spawn_entity',
        output='screen',
        arguments=['-file', urdf_path, '-entity', 'vacuum', '-x', '0', '-y', '0', '-z', '0.05']
    )
    ld.add_action(spawn_cmd)

    # robot_state_publisher with robot_description from the urdf file
    rsp_node = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        output='screen',
        parameters=[{'robot_description': open(urdf_path).read(), 'use_sim_time': use_sim_time}]
    )
    ld.add_action(rsp_node)

    return ld
