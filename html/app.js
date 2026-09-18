/* LXR-DISPATCH — the call stack | © 2026 iBoss21 / LXRCore */
(function () {
  const $ = (id) => document.getElementById(id);
  const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'lxr-dispatch';
  const stack = $('stack'), cards = $('cards');
  let L = {}, calls = [], timer = null;
  const t = (k, vars) => { let s = L[k] || k.split('.').pop().replace(/_/g, ' '); if (vars) for (const v in vars) s = s.replace('%{' + v + '}', vars[v]); return s; };
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const post = (name, body) => fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body || {}) }).catch(() => {});
  const age = (at) => { const s = Math.max(0, Math.floor(Date.now() / 1000 - (Number(at) || 0))); return s < 60 ? t('ui.age_s', { n: s }) : t('ui.age_m', { n: Math.floor(s / 60) }); };
  function applyLocale() { document.querySelectorAll('[data-l]').forEach(el => { const k = 'ui.' + el.dataset.l; if (L[k]) el.textContent = L[k]; }); }
  function render() {
    cards.innerHTML = '';
    calls.forEach(c => {
      const el = document.createElement('div'); el.className = 'dp-card p' + (Number(c.priority) || 3);
      const resp = (c.responders || []).map(r => r.name).join(', ');
      el.innerHTML = `<div class="dp-card__top"><span class="dp-card__code">${esc(c.code || '')}</span><span>${esc(c.label || '')}</span>${c.town ? `<span>· ${esc(c.town)}</span>` : ''}<span class="dp-card__age" data-at="${Number(c.at) || 0}">${esc(age(c.at))}</span></div><div class="dp-card__title">${esc(c.title || c.label || '')}</div>${c.message ? `<div class="dp-card__msg">${esc(c.message)}</div>` : ''}<div class="dp-card__foot"><span class="dp-card__resp">${resp ? esc(t('ui.responding')) + ' ' + esc(resp) : esc(t('ui.nobody'))}</span><span class="lxr-grow"></span><button class="dp-btn" data-a="route">${esc(t('ui.route'))}</button><button class="dp-btn is-on" data-a="respond">${esc(t('ui.respond'))}</button><button class="dp-btn" data-a="close">×</button></div>`;
      el.querySelectorAll('.dp-btn').forEach(b => b.addEventListener('click', () => post(b.dataset.a, { id: c.id })));
      cards.appendChild(el);
    });
    clearInterval(timer);
    timer = setInterval(() => cards.querySelectorAll('.dp-card__age').forEach(el => { el.textContent = age(el.dataset.at); }), 5000);
  }
  window.addEventListener('message', e => {
    const m = e.data || {};
    if (m.brand && m.brand.theme) document.documentElement.dataset.theme = m.brand.theme;
    if (m.locale) { L = m.locale; applyLocale(); }
    if (m.lang) document.body.classList.toggle('lang-ka', m.lang === 'ka');
    if (m.respondKey) $('key').textContent = m.respondKey;
    if (m.action === 'calls') { calls = m.payload || []; render(); stack.classList.toggle('lxr-hidden', !m.shown || !calls.length); }
  });
  if (window.__LXR_MOCK__) window.postMessage(window.__LXR_MOCK__, '*');
})();
