---
layout: page
title: Learning-Based CPU Burst Prediction
description: Predicting process run time at submission so schedulers can make better decisions.
img: assets/img/publication_preview/informs_placeholder.jpg
importance: 4
category: research
related_publications: true
---

Schedulers like Shortest-Job-First depend on knowing a job's burst time in advance. The classic exponential-averaging estimate breaks down under mixed, multi-user workloads.

I trained decision trees, random forests and MLPs on real scheduling traces, using only features available **at submission time**.

| Model                 |        MAE |     RAE |
| --------------------- | ---------: | ------: |
| Exponential averaging |   14833 ms |  53.3 % |
| **Decision tree**     | **3514** | **12.6 %** |

Inference takes about 0.003 ms per job, which is fast enough to run inside the scheduler. Results are reported with 95 % confidence intervals.

Papers: {% cite shakib2026southeastcon shakib2025informs %}

Code: [nsriad/Burst-Time-Prediction-Using-Machine-Learning](https://github.com/nsriad/Burst-Time-Prediction-Using-Machine-Learning)
