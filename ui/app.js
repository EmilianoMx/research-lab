const content = {
  en: {
    title: 'Reproducible Research Platform for Everyone',
    subtitle: 'A friendly interface to navigate governance, methodology, data standards, and reproducibility assets without technical friction.',
    ctaMain: 'Open bilingual home',
    ctaSecondary: 'Open Spanish home',
    docsTitle: 'Core modules',
    replicate: 'How to replicate in 4 steps',
    footer: 'Built for researchers who are experts in science, not necessarily in programming.',
    steps: [
      'Clone the repository.',
      'Run: make validate',
      'Open EN/ES documentation from the cards below.',
      'Use pull requests to update standards with traceability.'
    ],
    cards: [
      ['Governance', 'Roles, decision rules, merge quality gates.', '../GOVERNANCE.md'],
      ['Contributing', 'How collaborators propose and review changes.', '../CONTRIBUTING.md'],
      ['Code of Conduct', 'Research ethics and expected behavior.', '../CODE_OF_CONDUCT.md'],
      ['Methodology Standards', 'Q1-ready methodological quality baseline.', '../docs/METHODOLOGY_STANDARDS.md'],
      ['Reproducibility Checklist', 'Pre-submission checklist for replicability.', '../docs/REPRODUCIBILITY_CHECKLIST.md'],
      ['Data Management', 'FAIR data protocol and implementation plan.', '../docs/DATA_MANAGEMENT_PROTOCOL.md'],
      ['Quality Audit', 'International maturity and roadmap.', '../docs/INTERNATIONAL_QUALITY_AUDIT.md'],
      ['Spanish Hub', 'Navigate all Spanish versions.', '../README.es.md']
    ]
  },
  es: {
    title: 'Plataforma de investigación reproducible para todos',
    subtitle: 'Interfaz amigable para navegar gobernanza, metodología, datos y reproducibilidad sin fricción técnica.',
    ctaMain: 'Abrir inicio bilingüe',
    ctaSecondary: 'Abrir inicio en español',
    docsTitle: 'Módulos principales',
    replicate: 'Cómo replicar en 4 pasos',
    footer: 'Creado para científicos expertos en su área, aunque no programen mucho.',
    steps: [
      'Clona el repositorio.',
      'Ejecuta: make validate',
      'Abre documentación EN/ES desde las tarjetas.',
      'Usa pull requests para actualizar estándares con trazabilidad.'
    ],
    cards: [
      ['Gobernanza', 'Roles, decisiones y criterios de merge.', '../GOVERNANCE.es.md'],
      ['Contribución', 'Cómo proponer y revisar cambios.', '../CONTRIBUTING.es.md'],
      ['Código de conducta', 'Ética de investigación y convivencia.', '../CODE_OF_CONDUCT.es.md'],
      ['Estándares metodológicos', 'Base de calidad metodológica para Q1.', '../docs/METHODOLOGY_STANDARDS.es.md'],
      ['Checklist reproducibilidad', 'Lista previa a envío/publicación.', '../docs/REPRODUCIBILITY_CHECKLIST.es.md'],
      ['Gestión de datos', 'Protocolo FAIR e implementación.', '../docs/DATA_MANAGEMENT_PROTOCOL.es.md'],
      ['Auditoría de calidad', 'Madurez internacional y hoja de ruta.', '../docs/INTERNATIONAL_QUALITY_AUDIT.es.md'],
      ['Centro en inglés', 'Navegar versiones en inglés.', '../README.en.md']
    ]
  }
};

function render(lang) {
  const c = content[lang];
  document.getElementById('title').textContent = c.title;
  document.getElementById('subtitle').textContent = c.subtitle;
  document.getElementById('cta-main').textContent = c.ctaMain;
  document.getElementById('cta-secondary').textContent = c.ctaSecondary;
  document.getElementById('section-docs').textContent = c.docsTitle;
  document.getElementById('section-replicate').textContent = c.replicate;
  document.getElementById('footer-text').textContent = c.footer;

  const steps = document.getElementById('steps-list');
  steps.innerHTML = '';
  c.steps.forEach((s) => {
    const li = document.createElement('li');
    li.textContent = s;
    steps.appendChild(li);
  });

  const grid = document.getElementById('docs-grid');
  grid.innerHTML = '';
  c.cards.forEach(([title, desc, link]) => {
    const card = document.createElement('article');
    card.className = 'card';
    card.innerHTML = `<h3>${title}</h3><p>${desc}</p><a href="${link}" target="_blank">Open ↗</a>`;
    grid.appendChild(card);
  });

  document.getElementById('lang-en').classList.toggle('active', lang === 'en');
  document.getElementById('lang-es').classList.toggle('active', lang === 'es');
}

document.getElementById('lang-en').addEventListener('click', () => render('en'));
document.getElementById('lang-es').addEventListener('click', () => render('es'));
render('en');
