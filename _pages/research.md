---
layout: page
permalink: /research/
title: Research
description: Multimodal data fusion, machine intelligence and cyber-physical systems for autonomous vehicles. Publications are listed newest first. Use the search box to filter by title, venue, year or type.
nav: true
nav_order: 1
---

<!-- Publications are generated from _bibliography/papers.bib by jekyll-scholar. -->

{% include bib_search.liquid %}

<!-- pub-tl = vertical timeline with years on the left (style: _sass/_custom.scss → "RESEARCH TIMELINE") -->
<div class="publications pub-tl">

{% bibliography %}

</div>

<script>
  // Number papers newest = highest ([13] … [1]). Numbers belong to the paper,
  // so they stay the same when the search box filters the list.
  (function () {
    var items = document.querySelectorAll(".pub-tl ol.bibliography > li");
    items.forEach(function (li, i) { li.setAttribute("data-n", items.length - i); });
  })();
</script>
