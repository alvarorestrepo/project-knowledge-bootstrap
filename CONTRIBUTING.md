# Contributing to project-knowledge-bootstrap

Gracias por tu interés en mejorar `project-knowledge-bootstrap`. Este skill es usado por agentes de IA para analizar proyectos reales, por lo que **la precisión y la consistencia son más importantes que la cantidad de código**.

> **Si vas a contribuir, lee esto primero.** No aceptamos PRs que no sigan estas reglas.

---

## 🎯 Filosofía del Proyecto

1. **ANALYZE first, GENERATE second.** Nunca agregues detección para un framework que no hayas visto en un proyecto real.
2. **AGENTS.md es el MAPA, skills son el TERRITORIO.** El mapa debe ser ligero; el territorio, profundo.
3. **Idempotencia sobre todo.** UPDATE mode debe ser 100% seguro de re-ejecutar.
4. **Real > Genérico.** Todo snippet, path y comando en un skill debe ser real, no inventado.

---

## 🐛 Reportando Bugs

Antes de abrir un issue:

1. **Buscá** si ya existe un issue similar.
2. **Probá** en un proyecto real (o un repo mínimo que reproduzca el bug).
3. **Anotá**: versión del skill, tipo de proyecto, y qué artefacto salió mal (`AGENTS.md`, un skill específico, `setup.sh`, etc.).

Usá el template de **Bug Report** y no borres las secciones.

---

## 💡 Proponiendo Features

Buenas ideas para contribuir:

- Soporte para un nuevo lenguaje o framework que el skill no detecta aún.
- Mejoras en heurísticas de detección de módulos.
- Nuevas plantillas (`assets/`) que sean compatibles con más herramientas de IA.
- Correcciones en la lógica de UPDATE mode o smart-merge.

Malas ideas:

- Agregar tu framework favorito sin haberlo probado en un codebase real.
- Hacer `AGENTS.md` más largo. El límite es **150 líneas**, no negociable.
- Romper la compatibilidad con Bash 3 (macOS default).

---

## 🔧 Cómo contribuir código

### 1. Fork y branch

```bash
git checkout -b feat/tu-feature
# o
git checkout -b fix/tu-bugfix
```

### 2. Commits

Usamos **Conventional Commits**:

```
feat: add Rust workspace detection in Phase 1
fix: prevent false positives for infra directories in Phase 1.3
docs: clarify UPDATE mode smart-merge rules
refactor: simplify setup.sh tool detection logic
```

### 3. Qué archivos tocar

| Querés cambiar...                | Archivo a editar                |
| -------------------------------- | ------------------------------- |
| Lógica del skill (fases, reglas) | `SKILL.md`                      |
| Plantilla de `AGENTS.md`         | `assets/AGENTS-TEMPLATE.md`     |
| Plantilla de skills              | `assets/SKILL-TEMPLATE.md`      |
| Instalador multi-tool            | `assets/setup.sh`               |
| Auto-invoke sync                 | `assets/sync.sh`                |
| README / docs                    | `README.md` / `CONTRIBUTING.md` |

### 4. Reglas de edición de `SKILL.md`

- **No borres fases.** Si querés agregar algo, hacelo en la fase correcta.
- **Mantené los diagramas Mermaid** compatibles con renderizado de GitHub.
- **Si cambiás una regla en Phase 3, actualizá los ejemplos.**
- **No cambiés la estructura de frontmatter** sin discutirlo primero en un issue.

### 5. Probar antes de enviar PR

Si cambiaste:

- **`SKILL.md`** → Probá que un agente de IA pueda seguir las instrucciones sin ambigüedad.
- **`assets/setup.sh`** → Corrélo en Bash 3: `bash --version` debe ser ≤ 3.2. Probalo con `--dry-run` si podés.
- **`assets/sync.sh`** → Corrélo dos veces seguidas. El output debe ser **idéntico**.

---

## ✅ Checklist del PR

Tu PR debe incluir:

- [ ] Descripción clara de qué cambia y por qué.
- [ ] Referencia a un issue (si aplica).
- [ ] Evidencia de prueba: un proyecto real o un repo mínimo donde se validó.
- [ ] Commits con mensajes claros siguiendo Conventional Commits.
- [ ] No rompe compatibilidad con Bash 3.
- [ ] No supera las 150 líneas de `AGENTS.md` (si aplica).

---

## 🏷 Versionado

Seguimos [SemVer](https://semver.org/):

- `MAJOR` — Cambios que rompen la compatibilidad de `AGENTS.md` o `skills/` generados.
- `MINOR` — Nuevas capacidades (nuevo lenguaje detectado, nueva fase, etc.).
- `PATCH` — Fixes, mejoras en heurísticas, correcciones de templates.

---

## 🧠 Preguntas?

Abrí una **Discussion** en GitHub o etiquetá tu issue con `question`.

---

<p align="center">
  <i>Contribuciones bien pensadas > contribuciones rápidas.</i>
</p>
