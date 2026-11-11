---
layout: page
title: Two-Vehicle V2V Messaging with ROS 2 + Simulink
description: A MATLAB/Simulink prototype in which two vehicles exchange velocity and position over ROS 2 topics.
img: assets/img/projects/ros2_simulink.jpg
importance: 1
category: coursework
github: https://github.com/nsriad/ros2-simulink-vehicle-communication
---

A small, clean prototype of vehicle-to-vehicle communication. Each vehicle in a Simulink model **publishes** its own velocity (`geometry_msgs/Twist`) and 2-D position (`geometry_msgs/Point`), and **subscribes** to the other vehicle's topics.

| Vehicle   | Publishes                                   | Subscribes                                  |
| --------- | ------------------------------------------- | ------------------------------------------- |
| Vehicle 1 | `/vehicle1/velocity`, `/vehicle1/position` | `/vehicle2/velocity`, `/vehicle2/position` |
| Vehicle 2 | `/vehicle2/velocity`, `/vehicle2/position` | `/vehicle1/velocity`, `/vehicle1/position` |

Velocities are biased sinusoids (25 ± 3 m/s and 20 ± 2 m/s). Each position is the integral of its velocity, so the two signals stay physically consistent.

Code and screenshots: [nsriad/ros2-simulink-vehicle-communication](https://github.com/nsriad/ros2-simulink-vehicle-communication)
