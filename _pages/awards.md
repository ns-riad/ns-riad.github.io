---
layout: page
title: "Awards & Certification"
permalink: /awards/
nav: true
nav_order: 4
---

### 🎓 Academic Honors

- **Dean’s Award** — KUET (2017–2020, three consecutive years)

### 🏆 Research Recognition

- **Best Paper Award** — [Conference Name], Year

### 📜 Training & Certifications

- **CTL Training Award**, UAH
- **FERPA Training**, UAH
- **CITI Program (Research Ethics & Compliance)**
- **Coursera Certifications** — [Course name(s)]

## Certifications

<!-- Best Paper Award -->
<div class="award-card">
  <h3>Best Paper Award</h3>
  <p><em>Won 1st prize award in the "Best Paper Category" out of 103 accepted papers at 5th International Conference on Electrical Engineering and Information & Communication Technology (ICEEICT 2021).</em></p>
  <p>Faculty of EEE, KUET.</p>

  <details class="cert">
    <summary class="btn btn-sm">View Certificate</summary>
    <div class="cert-body">
      <object data="{{ '/assets/pdf/iceeict_best_paper.pdf' | relative_url }}" type="application/pdf" width="100%" height="640">
        <p>PDF preview not supported. <a href="{{ '/assets/pdf/iceeict_best_paper.pdf' | relative_url }}" target="_blank">Open PDF</a></p>
      </object>
    </div>
  </details>
</div>

<!-- Dean’s Award (toggle-to-expand, full-width preview) -->
<div class="award-card">
  <h3>Dean’s Award</h3>
  <p><em>Achieved the Dean’s Award for outstanding academic performance in three consecutive years (2017–18, 2018–19, 2019–20).</em></p>
  <p>Faculty of EEE, KUET.</p>

  <!-- Buttons row -->
  <div class="cert-tabs" data-target="deans-preview">
    <button class="btn btn-sm"
            data-src="{{ '/assets/pdf/Deans_Award_3rd_year.pdf' | relative_url }}">
      View Certificate (2018–19)
    </button>

    <button class="btn btn-sm"
            data-src="{{ '/assets/pdf/Deans_Award_4th_year.pdf' | relative_url }}">
      View Certificate (2019–20)
    </button>

  </div>

  <!-- Shared preview panel (hidden by default) -->
  <div class="cert-preview hidden" id="deans-preview">
    <embed src="" type="application/pdf" />
  </div>
</div>

<!-- Education Board Scholarship -->
<div class="award-card">
  <h3>Education Board Scholarship</h3>
  <p><em>Awarded the Education Board Scholarship for exceptional achievements in Primary (2008), Secondary (2014), and Higher Secondary (2016).</em></p>
  <p>Rajshahi Education Board, Bangladesh.</p>

  <details class="cert">
    <summary class="btn btn-sm">View Certificate</summary>
    <div class="cert-body">
      <object data="{{ '/assets/pdf/board_scholarship.pdf' | relative_url }}" type="application/pdf" width="100%" height="640">
        <p>PDF preview not supported. <a href="{{ '/assets/pdf/board_scholarship.pdf' | relative_url }}" target="_blank">Open PDF</a></p>
      </object>
    </div>
  </details>
</div>

<!-- Intra-district Chess Champion -->
<div class="award-card">
  <h3>Intra-district Chess Champion</h3>
  <p><em>Secured the first place in the Intra-district Chess Championship.</em></p>
  <p>District Sports Officer’s Office, Bogura, Bangladesh.</p>

  <details class="cert">
    <summary class="btn btn-sm">View Certificate</summary>
    <div class="cert-body">
      <object data="{{ '/assets/pdf/Chess_certificate.pdf' | relative_url }}" type="application/pdf" width="100%" height="640">
        <p>PDF preview not supported. <a href="{{ '/assets/pdf/Chess_certificate.pdf' | relative_url }}" target="_blank">Open PDF</a></p>
      </object>
    </div>
  </details>
</div>

<!-- css -->
<style>
/* —— Cards ——————————————————————————————————————————————— */
.award-card{
  margin:1rem 0 1.25rem;
  padding:1rem 1.25rem;
  border:1px solid var(--global-border);
  border-radius:10px;
  background:var(--global-bg);
  box-shadow:0 1px 6px rgba(0,0,0,.06);
}
.award-card h3{ margin:0 0 .35rem; }
.award-card p{  margin:.35rem 0; }

/* —— <details> blocks (Best Paper / Scholarship / Chess) ——— */
.cert{ margin-top:.5rem; }
.cert summary{
  list-style:none;
  cursor:pointer;
  display:inline-block;
  user-select:none;
}
.cert summary::-webkit-details-marker{ display:none; }
/* arrows for <details> */
.cert[open] summary.btn::after{ content:" ▲"; font-size:.85em; }
.cert:not([open]) summary.btn::after{ content:" ▼"; font-size:.85em; }

.cert-body{
  margin-top:.75rem;
  padding:1rem;
  border:1px dashed var(--global-border);
  background:var(--global-bg);
}
.cert-body object,
.cert-body embed,
.cert-body iframe,
.cert-body img{
  display:block;
  width:100%;
  height:50vh;                /* adjust if you want shorter/taller */
  max-height:900px;
  border:1px solid var(--global-border);
  border-radius:6px;
}

/* —— Dean’s Award “tabs” (toggle-to-expand) ——————————— */
.cert-tabs{
  display:flex;
  gap:.75rem;
  flex-wrap:wrap;
  margin-top:.5rem;
}
/* arrows for tab buttons */
.cert-tabs .btn::after{
  content:" ▼";
  font-size:.85em;
  margin-left:.35rem;
}
.cert-tabs .btn.is-active::after{ content:" ▲"; }

/* full-width shared preview panel (hidden by default) */
.hidden{ display:none; }

.cert-preview{
  margin-top:.75rem;
  padding:1rem;
  border:1px dashed var(--global-border);
  background:var(--global-bg);
}
.cert-preview embed,
.cert-preview object,
.cert-preview iframe{
  display:block;
  width:100%;
  height:60vh;                /* adjust as you like */
  max-height:95vh;
  border:1px solid var(--global-border);
  border-radius:6px;
}

/* optional: active button highlight */
.cert-tabs .btn.is-active{
  box-shadow:0 0 0 2px var(--global-accent);
}
</style>

<script>
document.addEventListener('click', function (e) {
  var btn = e.target.closest ? e.target.closest('.cert-tabs .btn') : null;
  if (!btn) return;

  // prevent the page from jumping when the button is clicked
  e.preventDefault();

  var tabs = btn.closest ? btn.closest('.cert-tabs') : null;
  var panelId = (tabs && tabs.dataset) ? tabs.dataset.target : null;
  if (!panelId) return;

  var panel = document.getElementById(panelId);
  if (!panel) return;

  var viewer = panel.querySelector('embed, object, iframe');
  var nextSrc = btn.getAttribute('data-src');

  var isActive = btn.classList.contains('is-active');
  var isVisible = panel.className.indexOf('hidden') === -1;
  var currentSrc = panel.dataset ? panel.dataset.currentSrc || '' : '';

  // Collapse if clicking the same active button
  if (isActive && isVisible) {
    panel.classList.add('hidden');
    var allBtns = tabs.querySelectorAll('.btn');
    for (var i = 0; i < allBtns.length; i++) allBtns[i].classList.remove('is-active');
    if (panel.dataset) panel.dataset.currentSrc = '';
    return;
  }

  // Show and load requested certificate
  if (viewer) viewer.setAttribute('src', nextSrc);
  panel.classList.remove('hidden');
  if (panel.dataset) panel.dataset.currentSrc = nextSrc;

  // Active button state
  var all = tabs.querySelectorAll('.btn');
  for (var j = 0; j < all.length; j++) all[j].classList.remove('is-active');
  btn.classList.add('is-active');

  // Smooth scroll (fallback for older engines)
  try { panel.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
  catch (err) { panel.scrollIntoView(); }
});
</script>


---
