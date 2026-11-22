---
layout: page
title: Cruise Control with GA-PID and LQR
description: A side-by-side study of PID and LQR speed controllers for a vehicle cruise control system, from the physics model to MATLAB/Simulink results.
img: assets/img/projects/thumb-cruise-control.webp
importance: 1
category: coursework
writeup: true
github: https://github.com/nsriad/cruise-control-lqr-pid
code_label: Code & Simulink models
facts:
  - { label: Tools, value: "MATLAB · Simulink" }
  - { label: Controllers, value: "PID vs. LQR (state feedback)" }
  - { label: Best result, value: "LQR-ITAE: **0 % overshoot**, settles in **4.4 s**", highlight: true }
  - { label: Cost J<sub>min</sub>, value: "**6.43** (LQR) vs. 21.71 (PID), about 3× lower", highlight: true }
---

{% include site/project_parts/facts.liquid %}

{% include site/project_parts/sectionnav.liquid %}

A cruise controller has one job: hold the speed you set, even as drag, rolling resistance and engine lag push back. This project builds a longitudinal vehicle model from first principles, then compares a classical **PID** controller with an optimal **LQR** state-feedback controller under identical conditions.

## The problem

The driver sets a reference speed $$v_{\text{ref}}$$. The controller compares it with the measured speed and produces a throttle command $$u$$. That command passes through the pedal actuator and engine to create the driving force, while road incline and air resistance act as disturbances.

{% include site/project_parts/figure.liquid src="/assets/img/projects/cruise-control/block-overview.webp" n=1 caption="Closed-loop cruise control. The speed error drives the controller, and road incline and air resistance enter as the disturbance $$d$$." %}

A good cruise controller should reach the set speed quickly, **without overshooting** (which passengers feel), settle fast, and hold the speed with zero steady-state error.

## Vehicle model

### Longitudinal dynamics

A point-mass force balance along the direction of travel gives

$$
\begin{aligned}
M\,\dot v(t) &= F_d(t) - F_r(t), \\
F_r(t) &= C_1 v(t) + C_a v^2(t),
\end{aligned}
$$

where $$M$$ is the vehicle mass, $$F_d$$ the driving force at the wheels, and $$F_r$$ the resistance: a linear rolling/viscous term $$C_1 v$$ plus quadratic aerodynamic drag $$C_a v^2$$. So the nonlinear speed dynamics are

$$
\dot v(t) = \frac{1}{M}\Big(F_d(t) - C_1 v(t) - C_a v^2(t)\Big).
$$

### Engine and actuator

The drivetrain from throttle $$u$$ to driving force behaves like a first-order lag with a pure delay $$\tau$$. Approximating the delay by another first-order lag, $$e^{-\tau s} \approx 1/(\tau s + 1)$$, makes it realizable:

$$
\begin{aligned}
\frac{F_d(s)}{U(s)} &= \frac{C_1\, e^{-\tau s}}{Ts+1} \\[4pt]
&\approx \frac{C_1}{(Ts+1)(\tau s+1)}.
\end{aligned}
$$

### Linearized plant

The controller is designed around a constant cruise speed $$v_0$$, where $$\dot v = 0$$ gives the steady force $$F_{d0} = C_1 v_0 + C_a v_0^2$$. Working with small deviations $$\Delta v = v - v_0$$, $$\Delta u = u - u_0$$, and using the parameters in Table 1, the plant from throttle to speed becomes

$$
\begin{aligned}
G_p(s) &= \frac{\Delta V(s)}{\Delta U(s)} \\[4pt]
&= \frac{2.4767}{(s+0.0476)(s+1)(s+5)} \\[4pt]
&= \frac{2.4767}{s^3 + 6.0476\,s^2 + 5.2856\,s + 0.238}.
\end{aligned}
$$

<div class="pj-caption">Table 1. Vehicle parameters</div>

| Symbol | Description | Value |
|:--|:--|--:|
| $$C_1$$ | Linear drag / drive gain | 743 |
| $$C_a$$ | Quadratic aerodynamic drag | 1.19 N/(m/s)² |
| $$M$$ | Vehicle mass | 1599 kg |
| $$\tau$$ | Engine / actuator delay | 0.2 s |
| $$T$$ | Engine time constant | 1 s |
| $$F_{d,\max}$$, $$F_{d,\min}$$ | Driving-force limits | ±3500 N |
| $$v_0$$ | Nominal cruise speed | 30 km/h |
{: .pj-table}

<details class="pj-more" markdown="1">
<summary>From transfer function to state space</summary>

Multiplying out the denominator and taking the inverse Laplace transform (zero initial conditions) gives a third-order ODE:

$$
\begin{aligned}
&\dddot{\Delta v} + 6.0476\,\ddot{\Delta v} + 5.2856\,\dot{\Delta v} \\
&\quad + 0.238\,\Delta v = 2.4767\,\Delta u(t).
\end{aligned}
$$

With the canonical states $$x_1 = \Delta v,\; x_2 = \dot{\Delta v},\; x_3 = \ddot{\Delta v}$$:

$$
\dot{\mathbf x} = A\mathbf x + B\,\Delta u, \qquad y = C\mathbf x,
$$

$$
A = \begin{bmatrix} 0 & 1 & 0 \\ 0 & 0 & 1 \\ -0.238 & -5.2856 & -6.0476 \end{bmatrix}
$$

$$
B = \begin{bmatrix} 0 \\ 0 \\ 2.4767 \end{bmatrix}, \qquad
C = \begin{bmatrix} 1 & 0 & 0 \end{bmatrix}, \qquad D = 0.
$$

The output $$y$$ is the speed deviation $$\Delta v$$. The derivation follows Osman et al. (2009) and Frank et al. (1989).
</details>

## Controllers

### PID: error-driven

The PID controller acts only on the speed error $$e(t) = v_{\text{ref}}(t) - v(t)$$:

$$
\begin{aligned}
u(t) = \;& K_p\, e(t) && \text{proportional} \\
+\; & K_i \int_0^t e(\tau)\, d\tau && \text{integral} \\
+\; & K_d\, \frac{de(t)}{dt} && \text{derivative}
\end{aligned}
$$

It is simple and needs no model, but its behavior depends entirely on the three gains.

{% include site/project_parts/figure.liquid src="/assets/img/projects/cruise-control/block-pid.webp" n=2 small=true caption="PID loop. In the reference study, a Genetic Algorithm tunes $$K_p, K_i, K_d$$" %}

### LQR: model-based optimal feedback

The LQR controller uses the full state $$\mathbf x$$ and minimizes a cost that trades off tracking error against control effort, with weights $$Q \succeq 0$$ and $$R \succ 0$$:

$$
J = \int_0^\infty \Big(\underbrace{\mathbf x^\top Q\,\mathbf x}_{\text{state error}} + \underbrace{u^\top R\, u}_{\text{control effort}}\Big)\, dt.
$$

The optimal law is linear state feedback, where $$P$$ solves the algebraic Riccati equation:

$$
\begin{aligned}
u(t) &= -K\,\mathbf x(t), \qquad K = R^{-1}B^\top P, \\[4pt]
0 &= A^\top P + P A - P B R^{-1} B^\top P + Q.
\end{aligned}
$$

{% include site/project_parts/figure.liquid src="/assets/img/projects/cruise-control/block-lqr.webp" n=3 small=true caption="LQR loop. In the reference study, a Genetic Algorithm tunes the weights $$Q$$ and $$R$$" %}

### How "good" is measured

The GA in the reference study tuned each controller against four error criteria, giving four PID and four LQR designs:

$$
\begin{aligned}
\text{MSE} &= \tfrac{1}{t_f}\!\int_0^{t_f}\! e^2\,dt, &\quad \text{ISE} &= \int_0^{t_f}\! e^2\,dt, \\
\text{ITSE} &= \int_0^{t_f}\! t\,e^2\,dt, &\quad \text{ITAE} &= \int_0^{t_f}\! t\,|e|\,dt.
\end{aligned}
$$

To pick a winner, every design is scored by percentage overshoot, rise time and settling time, combined into one cost (lower is better):

$$
J_{\min} = \%OS + T_r + T_s .
$$

## Results

All simulations run in MATLAB/Simulink on the linearized model, with zero initial conditions and no noise or disturbances, so each controller's own behavior is visible. Two inputs are used: a **step** in desired speed, and an **acceleration–deceleration** profile.

### Step response, all eight designs

<div class="pj-fig-row">
{% include site/project_parts/figure.liquid src="/assets/img/projects/cruise-control/step-pid-all.webp" n=4 caption="PID: every design overshoots; ISE peaks at about 28%." %}
{% include site/project_parts/figure.liquid src="/assets/img/projects/cruise-control/step-lqr-all.webp" n=5 caption="LQR: little or no overshoot, smooth convergence." %}
</div>

<div class="pj-caption">Table 2. Performance of every GA-tuned design (best of each type in bold)</div>

| Controller | %OS | T<sub>r</sub> (s) | T<sub>s</sub> (s) | E<sub>ss</sub> | J<sub>min</sub> | K<sub>p</sub> / K<sub>11</sub> | K<sub>i</sub> / K<sub>22</sub> | K<sub>d</sub> / K<sub>33</sub> |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|
| PID-MSE | 11.18 | 1.213 | 10.12 | −0.0004 | 22.51 | 2.8 | 0.437 | 2 |
| PID-ISE | 28.23 | 1.085 | 9.85 | 0.0000 | 39.17 | 2.8 | 1.247 | 2 |
| **PID-ITSE** | **10.30** | **1.222** | **10.19** | **−0.0006** | **21.71** | 2.8 | 0.4 | 2 |
| PID-ITAE | 12.48 | 1.201 | 9.80 | −0.0002 | 23.49 | 2.8 | 0.493 | 2 |
| LQR-MSE | 3.44 | 1.243 | 3.33 | 0 | 8.02 | 7.3238 | 6.9351 | 3.8548 |
| LQR-ISE | 0 | 2.087 | 4.51 | 0 | 6.60 | 0.0204 | 1.5362 | 1.4038 |
| LQR-ITSE | 0 | 4.229 | 7.75 | 0 | 11.98 | 0.1968 | 4.4657 | 3.5938 |
| **LQR-ITAE** | **0** | **2.013** | **4.42** | **0** | **6.43** | 0.0898 | 1.5708 | 1.4131 |
{: .pj-table}

### Best PID vs. best LQR

Taking the lowest-cost design of each type (PID-ITSE and LQR-ITAE) and the actual 60 km/h (16.67 m/s) reference:

{% include site/project_parts/figure.liquid src="/assets/img/projects/cruise-control/step-optimal.webp" width=470 n=6 caption="PID rises faster but overshoots to about 18.4 m/s before settling; LQR rises a little slower and lands smoothly with no overshoot." %}

<div class="pj-caption">Table 3. Optimal PID vs. optimal LQR</div>

| Controller | %OS | T<sub>r</sub> (s) | T<sub>s</sub> (s) | E<sub>ss</sub> | J<sub>min</sub> |
|:--|--:|--:|--:|--:|--:|
| PID-ITSE | 10.21 | 1.224 | 9.95 | 0 | 21.71 |
| **LQR-ITAE** | **0** | 2.015 | **4.42** | 0 | **6.43** |
{: .pj-table}

LQR gives up about 0.8 s of rise time, but it removes the overshoot completely and settles in **less than half the time**. Its overall cost is about **3.4× lower**.

### Acceleration and deceleration

{% include site/project_parts/figure.liquid src="/assets/img/projects/cruise-control/acc-dcc.webp" width=500 n=7 caption="Speed-up at 20 s and slow-down at 40 s. PID overshoots on the way up and undershoots on the way down; LQR follows each change smoothly." %}

Both controllers track the changing reference. PID overshoots and oscillates after each speed-up and undershoots after each slow-down, then recovers slowly. LQR's state feedback damps every transition.

## Takeaways

- **LQR wins on comfort and settling.** It has zero overshoot in its best designs and settles about 2× faster, which shows in a cost about 3× lower.
- **PID is quicker off the line,** with about 40 % shorter rise time, but the overshoot it pays for is exactly what passengers feel.
- **The tuning criterion matters as much as the controller.** The same PID structure ranges from 10 % to 28 % overshoot depending on which error measure tuned it.
- **Limits.** This is a linearized model with no actuator saturation, road slope or noise. The natural next steps are running the GA directly, adding those effects, and trying nonlinear or adaptive control.

## Reference

<div class="pj-note pj-ref" markdown="1">
<i class="fa-solid fa-book"></i> **Reproduction of:** A. Mahmood, K. Y. Al-bayati and R. Szabolcsi, "Comparison between genetic algorithms of proportional–integral–derivative and linear quadratic regulator controllers, and fuzzy logic controllers for cruise control system," *World Electric Vehicle Journal*, vol. 15, no. 8, p. 351, 2024.

The controller gains come from that study, where a Genetic Algorithm found them. The GA itself and the paper's fuzzy-logic controller are not reimplemented here; this work focuses on the modeling, the simulation and the comparison. Vehicle modeling follows K. Osman et al. (CSPA 2009) and A. A. Frank et al. (SAE 1989).
</div>

{% include site/lightbox.liquid %}
