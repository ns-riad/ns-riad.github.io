---
layout: page
title: News
section: news
permalink: /news/
---

{% comment %}
  This page just lists the news items. To add one, create a file in _news/ (see SITE_GUIDE.md → News).
  The list itself is rendered by the theme's news.liquid (inside the al_folio_core gem; no need to edit it).
{% endcomment %}
{% include news.liquid %}
