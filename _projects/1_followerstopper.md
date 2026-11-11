---
layout: page
title: String Stability of Followerstopper
description: Does a wave-dampening controller actually stop phantom traffic jams in a mixed-autonomy platoon?
importance: 2
category: research
# img: assets/img/projects/string_stability.png   # add your thumbnail here
related_publications: true
github: https://github.com/nsriad/FollowerStopper-String-Stability
---

**Question.** _Followerstopper_ is an adaptive-cruise-control law built to dampen stop-and-go waves. How does it behave in a realistic platoon where a human drives the lead car?

**Setup.** An eight-vehicle platoon: one human-driven leader replaying a real-world speed profile, followed by seven automated vehicles. I simulated it in two very different tools, **SUMO** (microscopic traffic) and **CARLA** (high-fidelity physics).

**Evaluation.** I used a time-domain string-stability framework:

- head-to-tail velocity amplification $\frac{\lVert v_N \rVert}{\lVert v_0 \rVert}$
- $L_2$-norm disturbance attenuation along the platoon
- relative-speed and spacing-error statistics

**Result.** The head-to-tail amplification factor is about **0.994 in both simulators**, so the leader's perturbations are slightly attenuated rather than amplified. Once the controller engages, large oscillations die out quickly.

Paper: {% cite shakib2026iv %}

Code: [nsriad/FollowerStopper-String-Stability](https://github.com/nsriad/FollowerStopper-String-Stability), a SUMO framework that supports ring, straight and circular networks and exports speed, headway and spacing-error plots.
