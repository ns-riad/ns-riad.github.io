---
layout: page
permalink: /writing/
title: Writing
description: Poems and essays, in English and বাংলা.
section: writing
---

{% assign poems = site.poems | sort: 'date' | reverse %}
{% assign essays = site.essays | sort: 'date' | reverse %}

<div class="writing-cols">
  <section>
    <h2 class="section-title">Poems</h2>
    {% if poems.size > 0 %}
      <ul class="writing-list">
        {% for p in poems %}
          <li>
            <a href="{{ p.url | relative_url }}" {% if p.lang %}lang="{{ p.lang }}"{% endif %}>{{ p.title }}</a>
            <span class="muted small">{{ p.date | date: '%b %Y' }}</span>
          </li>
        {% endfor %}
      </ul>
    {% else %}
      <p class="muted">Nothing yet.</p>
    {% endif %}
  </section>
  <section>
    <h2 class="section-title">Essays</h2>
    {% if essays.size > 0 %}
      <ul class="writing-list">
        {% for p in essays %}
          <li>
            <a href="{{ p.url | relative_url }}" {% if p.lang %}lang="{{ p.lang }}"{% endif %}>{{ p.title }}</a>
            <span class="muted small">{{ p.date | date: '%b %Y' }}</span>
          </li>
        {% endfor %}
      </ul>
    {% else %}
      <p class="muted">Nothing yet.</p>
    {% endif %}
  </section>
</div>
