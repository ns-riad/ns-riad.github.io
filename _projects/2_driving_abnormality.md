---
layout: page
title: Driver-Adaptive Abnormality Detection
description: Soft-clustering each driver's own style to flag when they drive unlike themselves. Best Paper, ICEEICT 2021.
img: assets/img/publication_preview/driving_abnormality.png
importance: 3
category: research
related_publications: true
---

Fixed thresholds treat every driver the same. This system learns **each driver's own style** and flags deviations from it.

1. Kinematic features (velocity, space/time headway, acceleration, jerk) are chosen with the Maximal Information Coefficient.
2. A **Gaussian Mixture Model** soft-clusters driving into _aggressive_, _moderate_ and _protective_ styles. GMM beat FCM and K-means.
3. Real-time style is compared against the long-term profile, and a learning factor lets the profile adapt as the driver's skill changes.

Validated on reconstructed **NGSIM I-80** data. The paper won **1st prize in the Best Paper category** (out of 103 papers) at ICEEICT 2021.

Paper: {% cite shakib2021adaptive %}
