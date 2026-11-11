---
layout: page
title: Parallel Bee Colony Optimization for PID Tuning
description: An OpenMP-parallel C++ meta-heuristic that tunes PID gains, benchmarked for speed-up against serial C++ and MATLAB.
importance: 2
category: coursework
github: https://github.com/nsriad/BCO_PID_Project
---

**Goal.** Tune PID gains for three plants with a Bee Colony Optimization (BCO) meta-heuristic, then make the search fast.

$$
G_1(s)=\frac{1}{s+1},\qquad
G_2(s)=\frac{5}{s^2+2s+5},\qquad
G_3(s)=\frac{10}{(s+1)(s^2+2s+10)}
$$

**How.**

- A MATLAB/Simulink baseline for classic PID tuning and its performance metrics.
- A serial C++17 BCO implementation.
- An OpenMP version that evaluates candidate solutions (bees) in parallel, swept over thread counts to measure **speed-up, efficiency and cost**.

BCO is stochastic, so different thread counts follow slightly different optimization paths.

Code: [nsriad/BCO_PID_Project](https://github.com/nsriad/BCO_PID_Project)
