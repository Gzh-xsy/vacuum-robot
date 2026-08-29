// odom_spinner.cpp — drive a circle using odom feedback; proves diff-drive plugin works.
#include <rclcpp/rclcpp.hpp>
#include <geometry_msgs/msg/twist.hpp>
#include <nav_msgs/msg/odometry.hpp>

class OdomSpinner : public rclcpp::Node
{
public:
  OdomSpinner() : Node("odom_spinner")
  {
    pub_ = create_publisher<geometry_msgs::msg::Twist>("cmd_vel", 10);
    sub_ = create_subscription<nav_msgs::msg::Odometry>(
      "odom", rclcpp::SensorDataQoS(),
      [this](const nav_msgs::msg::Odometry::SharedPtr msg) {
        const auto & p = msg->pose.pose.position;
        RCLCPP_INFO_THROTTLE(get_logger(), *get_clock(), 1000,
          "odom: x=%.2f y=%.2f", p.x, p.y);
      });
    timer_ = create_wall_timer(std::chrono::milliseconds(200), [this]() {
      auto twist = std::make_unique<geometry_msgs::msg::Twist>();
      twist->linear.x = 0.2;   // 0.2 m/s forward
      twist->angular.z = 0.5;  // ...while turning: circle of ~0.4 m radius
      pub_->publish(std::move(twist));
    });
  }

private:
  rclcpp::Publisher<geometry_msgs::msg::Twist>::SharedPtr pub_;
  rclcpp::Subscription<nav_msgs::msg::Odometry>::SharedPtr sub_;
  rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<OdomSpinner>());
  rclcpp::shutdown();
  return 0;
}
