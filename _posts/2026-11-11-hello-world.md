---
layout: post
title: Hello, world — what this blog is for
date: 2026-11-11
description: Research notes, the PhD journey, code, and the occasional stray thought.
tags: [meta]
categories: [thoughts]
giscus_comments: true
toc:
  sidebar: left
---

Welcome! This blog is where I'll write things that don't fit in a paper:

- **Research notes.** Ideas, derivations and negative results from my work on mixed-autonomy traffic.
- **The PhD journey.** What I wish someone had told me earlier.
- **Tutorials.** Small, reproducible code snippets and notebooks.
- **Thoughts.** Everything else. Some of it in বাংলা.

## A taste of what's possible

Math typesets with MathJax. Here is the Intelligent Driver Model:

$$
\dot v = a\left[1-\left(\frac{v}{v_0}\right)^{\delta}-\left(\frac{s^*(v,\Delta v)}{s}\right)^2\right],
\qquad s^* = s_0 + vT + \frac{v\,\Delta v}{2\sqrt{ab}}
$$

Code gets syntax highlighting and a copy button:

```python
def idm_accel(v, dv, s, v0=30.0, T=1.5, a=1.0, b=2.0, s0=2.0, delta=4):
    s_star = s0 + v * T + v * dv / (2 * (a * b) ** 0.5)
    return a * (1 - (v / v0) ** delta - (s_star / s) ** 2)
```

> ##### TIP
>
> Jupyter notebooks can be embedded directly in a post with `{% raw %}{% jupyter_notebook "/assets/jupyter/notebook.ipynb" %}{% endraw %}`.
{: .block-tip }

Thanks for stopping by. Comments are open below.
