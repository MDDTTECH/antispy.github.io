# Antispy Website

## 1. Project Overview

Статический сайт на GitHub Pages — хостит Privacy Policy для приложений Anti-Spy Camera (iOS и Android).

**URL:** `https://antispy.github.io` (→ redirects to `/docs/index.html`)
**Stack:** Static HTML, inline CSS, vanilla JS
**Hosting:** GitHub Pages

## 2. Structure

```
antispy.github.io/
├── index.html          # Root redirect → /docs/index.html
├── docs/
│   └── index.html      # Privacy Policy page (223 lines)
└── .nojekyll           # Disable Jekyll processing
```

## 3. Key Files

| File | Purpose |
|------|---------|
| `index.html` | JS + meta redirect to `/docs/index.html` |
| `docs/index.html` | Privacy Policy (11 sections, responsive, gradient header) |
| `.nojekyll` | Skip Jekyll, serve raw HTML |

## 4. Privacy Policy Sections

1. Information Collection & Use
2. Third-Party Services (Adapty)
3. In-App Purchases
4. Local-Only Features (WiFi scan, magnetometer, IR camera, on-device AI)
5. Data Sharing
6. Opt-Out Rights
7. Data Retention
8. Children's Privacy
9. Security
10. Changes to Policy
11. Contact Information

## 5. Design

- Header: purple gradient (#667eea → #764ba2)
- Content: max-width 800px, responsive
- Contact: placeholder email (`your.email@example.com` — needs update)

## 6. Deploy

Push to `main` → GitHub Pages auto-deploys. No build step.

## Agent Workflow Rules

1. **Conventional Commits**: `feat:`, `fix:`, `docs:`, `chore:`
2. **Update CLAUDE.md** when changing site structure
3. **Push to working branch**, never directly to main
4. **Keep Privacy Policy accurate** — update when app features change
5. **Test locally** — open `index.html` in browser before committing
