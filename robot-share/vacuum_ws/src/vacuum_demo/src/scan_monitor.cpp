// scan_monitor.cpp — Subscribe to /scan, print LiDAR health (zero Python on robot).
#include <rclcpp/rclcpp.hpp>
#include <sensor_msgs/msg/laser_scan.hpp>

#include <algorithm>
#include <cmath>
#include <limits>

class ScanMonitor : public rclcpp::Node
{
public:
  ScanMonitor() : Node("scan_monitor")
  {
    sub_ = create_subscription<sensor_msgs::msg::LaserScan>(
      "scan", rclcpp::SensorDataQoS(),
      [this](const sensor_msgs::msg::LaserScan::SharedPtr msg) {
        if (msg->ranges.empty()) { return; }
        float min_range = *std::min_element(msg->ranges.begin(), msg->ranges.end());
        size_t valid = std::count_if(msg->ranges.begin(), msg->ranges.end(),
          [](float r) { return std::isfinite(r) && r > 0.0f; });
        RCLCPP_INFO_THROTTLE(get_logger(), *get_clock(), 1000,
          "scan: %zu pts, valid=%zu, min=%.2f m", msg->ranges.size(), valid, min_range);
      });
  }

private:
  rclcpp::Subscription<sensor_msgs::msg::LaserScan>::SharedPtr sub_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<ScanMonitor>());
  rclcpp::shutdown();
  return 0;
}
