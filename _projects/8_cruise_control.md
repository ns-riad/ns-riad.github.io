---
layout: page
title: Cruise Control with GA-PID and LQR
description: Replicating and comparing GA-optimized PID and LQR-ITAE cruise controllers in MATLAB/Simulink (EE 586).
importance: 3
category: coursework
github: https://github.com/nsriad/cruise-control-lqr-pid
---

A course project (EE 586) that reproduces a published comparison of cruise-control designs:

- a **PID** controller with gains optimized by a genetic algorithm, and
- an **LQR** optimal controller tuned for ITAE.

Both are evaluated on 25-second step responses and on a 0–60 s acceleration/deceleration profile. The comparison uses rise time, settling time, overshoot and undershoot, along with the integral criteria ITAE, ITSE, IAE and ISE.

Code, Simulink models and figures: [nsriad/cruise-control-lqr-pid](https://github.com/nsriad/cruise-control-lqr-pid)
