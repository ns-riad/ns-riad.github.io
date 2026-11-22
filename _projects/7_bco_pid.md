---
layout: page
title: Parallel Bee Colony Optimization for PID Tuning
description: A swarm-intelligence optimizer that tunes PID controllers automatically, made over 5× faster with OpenMP multithreading in C++.
img: assets/img/projects/thumb-parallel-bco.webp
importance: 2
category: coursework
writeup: true
github: https://github.com/nsriad/BCO_PID_Project
code_label: Code (C++ / OpenMP)
facts:
  - { label: Tools, value: "C++17 · OpenMP · MATLAB" }
  - { label: Method, value: "Bee Colony Optimization (swarm meta-heuristic)" }
  - { label: Test plants, value: "1st-, 2nd- and 3rd-order systems" }
  - { label: Tracking error, value: "MSE down **78–98%** vs. hand-tuned PID", highlight: true }
  - { label: Parallel speed-up, value: "**5.5×** on 10 threads", highlight: true }
---

{% include site/project_parts/facts.liquid %}

{% include site/project_parts/sectionnav.liquid %}

Choosing the three gains of a PID controller by hand is slow, and gains that work for one system often fail on another. This project lets a swarm of simulated **bees** search for the gains automatically by running thousands of closed-loop simulations. Because each simulation is independent, the search is then **parallelized with OpenMP** so it finishes in a fraction of the time.

## The problem

A PID controller turns the tracking error $$e(t) = r(t) - y(t)$$ into a control signal through three terms:

$$
\begin{aligned}
u(t) = \;& K_p\, e(t) && \text{react to the error now} \\
+\; & K_i \int_0^t e(\tau)\, d\tau && \text{remove steady-state error} \\
+\; & K_d\, \frac{de(t)}{dt} && \text{damp, anticipate}
\end{aligned}
$$

{% include site/project_parts/figure.liquid src="/assets/img/projects/parallel-bco/pid-loop.webp" n=1 width=420 caption="Unity-feedback loop: the PID controller $$C(s)$$ drives the plant $$P(s)$$." %}

Good gains have to balance speed, overshoot and settling. They also depend strongly on the plant, so three plants of increasing difficulty are used: a stable first-order system, a lightly damped second-order system, and a third-order system with complex poles.

$$
\begin{aligned}
G_1(s) &= \frac{1}{s+1} \\[4pt]
G_2(s) &= \frac{5}{s^2+2s+5} \\[4pt]
G_3(s) &= \frac{10}{(s+1)(s^2+2s+10)}
\end{aligned}
$$

## Method

### What "good gains" means

Each candidate controller $$(K_p, K_i, K_d)$$ is simulated for 40 s on a unit step, in discrete time (forward Euler, $$\Delta t = 1$$ ms). Its score is the mean squared tracking error:

$$
\text{MSE} = \frac{1}{N} \sum_{k=1}^{N} e^2[k], \qquad K_p, K_i, K_d \in [-10,\, 10].
$$

Unstable controllers that make the simulation diverge get a very large MSE, so the swarm learns to avoid them.

### Bee Colony Optimization

Each bee holds one candidate set of gains. Every iteration has three phases, inspired by how honey bees forage:

1. **Employed bees** try a small random change to their own gains and keep it if the MSE improves.
2. **Onlooker bees** pick promising solutions (lower MSE, higher chance) and search around them, focusing effort where it pays off.
3. **Scout bees** abandon a solution that hasn't improved for 30 iterations and restart it at random, so the swarm doesn't get stuck in a local minimum.

<div class="pj-caption">Table 1. BCO settings</div>

| Parameter | Value |
|:--|--:|
| Bees | 100 |
| Iterations | 500 |
| Scout limit | 30 |
| Gain range | [−10, 10] |
| Simulation time / step | 40 s / 1 ms |
{: .pj-table}

### Making it parallel

Simulating the closed loop for every bee is by far the most expensive step, and every bee's simulation is independent. So the bee loop is split across threads with OpenMP. Each thread keeps its own random-number generator and local results, and threads only synchronize briefly to update the global best.

```cpp
// one iteration of the employed-bee phase
#pragma omp parallel for schedule(static)
for (int b = 0; b < n_bees; ++b) {
    Gains trial = perturb(bees[b], rng[omp_get_thread_num()]);  // thread-private RNG
    double mse  = simulate_closed_loop(plant, trial);  // the costly part
    if (mse < bees[b].mse) bees[b] = {trial, mse};
}
update_global_best(bees);  // the only synchronization point
```

Performance is measured against the single-thread run $$T_1$$ for $$p$$ threads:

$$
\begin{aligned}
S(p) &= \frac{T_1}{T_p} && \text{speed-up} \\[4pt]
E(p) &= \frac{S(p)}{p} && \text{efficiency} \\[4pt]
C(p) &= p\, T_p && \text{cost (total CPU time)}
\end{aligned}
$$

## Results

### Tuning quality

{% include site/project_parts/figure.liquid src="/assets/img/projects/parallel-bco/pid-baseline-all.webp" n=2 width=820 caption="Hand-tuned baseline PID: stable with no overshoot, but slow; each plant needs 10–12 s to settle." %}

{% include site/project_parts/figure.liquid src="/assets/img/projects/parallel-bco/pid-optimal-all.webp" n=3 width=820 caption="BCO-tuned PID: $$G_1$$ and $$G_2$$ reach the target almost instantly; $$G_3$$ is much faster but rings briefly because of its complex poles." %}

<div class="pj-caption">Table 2. Baseline vs. BCO-tuned controller</div>

| Metric | G<sub>1</sub> base | **G<sub>1</sub> BCO** | G<sub>2</sub> base | **G<sub>2</sub> BCO** | G<sub>3</sub> base | **G<sub>3</sub> BCO** |
|:--|--:|--:|--:|--:|--:|--:|
| Rise time (s) | 5.514 | **0.337** | 6.003 | **0.047** | 4.667 | **0.119** |
| Settling time (s) | 10.90 | **0.625** | 12.19 | n/a | 10.61 | **8.090** |
| Overshoot (%) | 0 | 0.32 | 0 | 0 | 0 | 50.87 |
| Peak time (s) | 27.83 | **1.349** | 26.30 | **0.136** | 19.99 | **0.299** |
| MSE | 0.0183 | **0.00075** | 0.0162 | **0.00034** | 0.0216 | **0.00471** |
| Gains K<sub>p</sub> / K<sub>i</sub> / K<sub>d</sub> |  | 10 / 10 / 0.90 |  | 10 / 10 / 10 |  | 3.08 / 10 / 10 |
{: .pj-table}

The tuned controllers rise **16–127× faster** and cut the tracking error by **96%, 98% and 78%**. For $$G_1$$ and $$G_2$$ the gains hit the edge of the search range: with no penalty on control effort, "as aggressive as allowed" is what minimizes MSE. For $$G_3$$ the swarm backs off $$K_p$$, but the speed still costs about 51% overshoot.

### Parallel performance

<div class="pj-fig-row is-compact">
{% include site/project_parts/figure.liquid src="/assets/img/projects/parallel-bco/execution-time.webp" n=4 caption="Wall-clock time falls from 17–33 s to 3–6 s." %}
{% include site/project_parts/figure.liquid src="/assets/img/projects/parallel-bco/speedup.webp" n=5 caption="Speed-up reaches 5.2–5.5× on 10 threads." %}
</div>
<div class="pj-fig-row is-compact">
{% include site/project_parts/figure.liquid src="/assets/img/projects/parallel-bco/efficiency.webp" n=6 caption="Efficiency drops past 4–6 threads as overheads grow." %}
{% include site/project_parts/figure.liquid src="/assets/img/projects/parallel-bco/cost.webp" n=7 caption="Total CPU time rises: faster answers cost extra work." %}
</div>

<div class="pj-caption">Table 3. Execution time (s) and speed-up by thread count</div>

| Threads | G<sub>1</sub> time | G<sub>1</sub> S | G<sub>2</sub> time | G<sub>2</sub> S | G<sub>3</sub> time | G<sub>3</sub> S |
|--:|--:|--:|--:|--:|--:|--:|
| 1 | 17.38 | 1.00 | 27.07 | 1.00 | 33.04 | 1.00 |
| 2 | 9.42 | 1.85 | 14.10 | 1.92 | 17.36 | 1.90 |
| 4 | 5.68 | 3.06 | 8.11 | 3.34 | 9.87 | 3.35 |
| 6 | 4.73 | 3.68 | 6.97 | 3.88 | 8.63 | 3.83 |
| 8 | 3.90 | 4.45 | 5.72 | 4.73 | 6.94 | 4.77 |
| **10** | **3.37** | **5.15** | **4.94** | **5.48** | **5.99** | **5.52** |
{: .pj-table}

Scaling is close to ideal up to 4 threads, then flattens. The test machine (Apple M-series) mixes fast performance cores with slower efficiency cores, and once the thread count passes the performance cores, the extra threads land on slower ones. Thread scheduling and the global-best updates add further overhead.

## Takeaways

- **Parallelism pays off here** because each candidate's simulation is independent: a 5.5× speed-up with a small change to the code.
- **Hardware shapes scaling.** On hybrid CPUs, adding threads beyond the fast cores gives less and less back.
- **The objective decides the controller.** MSE alone rewards maximum aggression. A real design would also penalize overshoot or control effort.
- **Next steps:** constraint-aware fitness, adaptive search settings, and GPU acceleration.

## Code

<div class="pj-note pj-ref" markdown="1">
<i class="fa-solid fa-code"></i> **Source:** the serial and OpenMP-parallel BCO implementations, plant models and benchmark scripts are in [nsriad/BCO_PID_Project](https://github.com/nsriad/BCO_PID_Project).
</div>

{% include site/lightbox.liquid %}
