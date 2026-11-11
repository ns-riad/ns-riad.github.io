---
layout: page
title: Multimodal Headway Estimation in CARLA + ROS 2
description: A camera–LiDAR simulation pipeline and a lightweight fusion model that stays accurate when one sensor degrades.
img: assets/img/projects/carla_ros2.jpg
importance: 1
category: research
related_publications: true
github: https://github.com/nsriad/carla_ros2_simulation
---

**Why.** Car-following controllers need a reliable estimate of the gap (_headway_) to the vehicle ahead. Cameras struggle in poor light, and LiDAR returns get sparse at range. A robust estimate should _fuse_ both and degrade gracefully when one of them fails.

**What I built:** a simulation environment that bridges **CARLA 0.9.16** and **ROS 2 Humble**.

- **Scenario:** an ego Tesla Model 3 follows a Lincoln MKZ leader along a 1 km route. The ego uses a PID gap-tracking controller, and the leader can run stop-and-go waves on a custom straight road or in Town04.
- **Sensors:** a front RGB camera, a 32-channel roof LiDAR, IMU and GNSS. All are synchronized and logged with ground truth.
- **Three headway estimators, each a ROS 2 node:**
  1. **LiDAR:** 3-D region-of-interest filtering, then radial distance to the leader.
  2. **Camera:** YOLO vehicle detection plus a monocular depth model with an affine calibration fitted offline.
  3. **Fusion:** an MLP trained offline and exported to ONNX, which combines both readings in real time.
- **One-command runs:** `run_simulation.sh` starts the CARLA server, the ROS bridge and live `rqt_plot` traces, then shuts everything down in the right order.

<div class="row mt-3">
  <div class="col-sm-6 mt-3 mt-md-0">
    <img class="img-fluid rounded z-depth-1" src="https://raw.githubusercontent.com/nsriad/carla_ros2_simulation/HEAD/asset/lidar_headway_timelapse.gif" alt="LiDAR headway estimate over time" loading="lazy">
  </div>
  <div class="col-sm-6 mt-3 mt-md-0">
    <img class="img-fluid rounded z-depth-1" src="https://raw.githubusercontent.com/nsriad/carla_ros2_simulation/HEAD/asset/town04_space_headway.png" alt="Space headway in Town04" loading="lazy">
  </div>
</div>
<div class="caption">Left: LiDAR region-of-interest headway estimate as the leader moves. Right: estimated vs. ground-truth space headway on the Town04 highway.</div>

More previews, including camera views on the straight road and in Town04, are in the [repository README](https://github.com/nsriad/carla_ros2_simulation).

**Papers:** {% cite shakib2026iccps shakib2026fusion %}
