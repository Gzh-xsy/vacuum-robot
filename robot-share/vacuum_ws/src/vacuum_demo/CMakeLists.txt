cmake_minimum_required(VERSION 3.8)
project(vacuum_demo)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(nav_msgs REQUIRED)

add_executable(scan_monitor src/scan_monitor.cpp)
target_include_directories(scan_monitor PRIVATE include)
ament_target_dependencies(scan_monitor rclcpp sensor_msgs nav_msgs)

add_executable(odom_spinner src/odom_spinner.cpp)
ament_target_dependencies(odom_spinner rclcpp geometry_msgs nav_msgs)

install(TARGETS scan_monitor odom_spinner
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
