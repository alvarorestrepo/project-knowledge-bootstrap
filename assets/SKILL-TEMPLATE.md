---
name: {{SKILL_NAME}}
description: >
  {{SKILL_DESCRIPTION}}
  Trigger: {{SKILL_TRIGGER}}
license: MIT
metadata:
  author: user
  version: "1.1.2"
  scope: [{{SCOPE}}]
  generated_by: project-knowledge-bootstrap
  generated_at: "{{ISO_DATE}}"
  source_version: "1.1.2"
  auto_invoke:
    {{#AUTO_INVOKE}}
    - "{{ACTION}}"
    {{/AUTO_INVOKE}}
allowed-tools: Read, Glob, Grep
---

## Purpose

{{PURPOSE_DESCRIPTION}}

---

## Directory Structure

```
{{MODULE_PATH}}/
{{DIRECTORY_TREE}}
```

---

## Key Patterns

### {{PATTERN_1_NAME}}

{{PATTERN_1_DESCRIPTION}}

```{{LANGUAGE}}
// From {{ACTUAL_FILE_PATH}}
{{REAL_CODE_SNIPPET}}
```

### {{PATTERN_2_NAME}}

{{PATTERN_2_DESCRIPTION}}

```{{LANGUAGE}}
// From {{ACTUAL_FILE_PATH}}
{{REAL_CODE_SNIPPET}}
```

---

## Decision Trees

### {{DECISION_1_NAME}}

```
{{DECISION_DESCRIPTION}}
├── Step 1: {{STEP_1}}
├── Step 2: {{STEP_2}}
├── Step 3: {{STEP_3}}
└── Step 4: {{STEP_4}}
```

---

## Critical Rules

{{#RULES}}

- {{RULE_TYPE}} {{RULE_DESCRIPTION}}
{{/RULES}}
<!-- Use ALWAYS, NEVER, PREFER, AVOID prefixes -->

---

## Testing

- **Framework**: {{TEST_FRAMEWORK}}
- **Location**: `{{TEST_DIRECTORY}}/`
- **Naming**: {{NAMING_CONVENTION}}
- **Run**: `{{TEST_COMMAND}}`

### Test Pattern

```{{LANGUAGE}}
// From {{ACTUAL_TEST_FILE}}
{{REAL_TEST_SNIPPET}}
```

---

## Commands

```bash
# Run tests
{{TEST_COMMAND}}

# Lint
{{LINT_COMMAND}}

# Build
{{BUILD_COMMAND}}
```

---

## Key Files

| File | Purpose |
| ---- | ------- |

{{#KEY_FILES}}
| `{{FILE_PATH}}` | {{FILE_PURPOSE}} |
{{/KEY_FILES}}
