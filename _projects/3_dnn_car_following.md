---
layout: page
title: DNN-Based Anticipatory Car Following
description: Distilling an MPC controller into a neural network for real-time, fuel-efficient driving.
img: assets/img/publication_preview/final_environment.jpg
importance: 5
category: research
related_publications: true
---

Model Predictive Control drives efficiently but costs too much compute to run in real time. We trained two DNNs instead:

- one predicts the preceding vehicle's speed from a **Road-Speed Profile** built from a few connected vehicles;
- one imitates the MPC policy to output the host vehicle's control input.

The resulting driver anticipates changes in traffic, accelerates early and smoothly, and cuts fuel use. It decides almost instantly, so it no longer needs the long control step MPC requires.

Paper: {% cite isha2021dnn %}
