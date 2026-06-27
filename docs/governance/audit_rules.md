# Sankofa Twi — audit_rules.md

Machine-checkable cultural + QA rules. Drives `scripts/validate_curriculum.mjs` today and the Flutter `CulturalIntegrityGuard` + Cloud Function later. Rules are the contract between Cultural Specialist (authoring) and QA Gatekeeper (validation).

Severity: **BLOCK** = fails CI / rejected write. **WARN** = flagged for human review.

| ID | Criterion | Rule (machine-checkable) | Severity | Enforced where |
|----|-----------|--------------------------|----------|----------------|
| AK-1 | Akan Philosophy | `theological_framework` ∈ controlled enum on unit, vocabulary, grammar, every challenge | BLOCK | validator + schema |
| AK-2 | Akan Philosophy | No diaspora-mapping / cross-cultural analogy terms (banned-pattern list) | BLOCK | validator + guard |
| AK-3 | Akan Philosophy | No "African culture" generalization where an Akan-specific term exists (`african`, `africa` flagged for review) | WARN | validator |
| LP-1 | Linguistic Precision | Twi orthography uses only the Asante grapheme set (`a e ɛ i o ɔ u` + nasal + tone); no ASCII fallback for ɔ/ɛ | BLOCK | grapheme allowlist |
| LP-2 | Linguistic Precision | `headword` non-empty; gloss is Akan-internal (no foreign-equivalent phrasing) | BLOCK/WARN | validator |
| PH-1 | Phonetic Integrity | `phonetic_bridge.pronunciation` (simple string) always present | BLOCK | validator |
| PH-2 | Phonetic Integrity | Homophone-sensitive entries provide `segments[]` + `homophone_set_id` | BLOCK | validator (when minimal-pair detected) |
| PH-3 | Phonetic Integrity | Each segment preserves exact grapheme; `bo` and `bɔ` never share a `homophone_set_id` | BLOCK | validator |
| TN-1 | Tone Check | Every `segment` carries a `tone` ∈ {high, low, mid, rising, falling} | BLOCK | schema + validator |
| TN-2 | Tone Check | Minimal pairs distinguished by tone must differ in `tone` or `atr` | WARN→BLOCK | validator |
| ST-1 | Structural | `lineage_challenges.length == 10` | BLOCK | validator + schema + DB rule |
| ST-2 | Structural | `action_button` absent from content (resolves to "Continue" in UI only) | BLOCK | validator + schema + DB rule |

## Correction record format (Cultural Specialist output)
Every correction returns all six fields:
```
- field:                 <json path>
- corrected_twi:         <exact Twi, correct graphemes>
- corrected_bridge:      <pronunciation | segments[] + homophone_set_id>
- corrected_explanation: <Akan-internal cultural explanation>
- rationale:             <brief philosophical/linguistic reason>
- rule_ids:              [AK-*, LP-*, PH-*, TN-*]
```

## Banned-pattern list (AK-2) — keep in sync across validator + guard
`similar to`, `equivalent of`, `akin to`, `comparable to`, `like the`, `diaspora`, `western`, `christian`, `biblical`, `greek`, `roman`. Review list (AK-3, WARN): `african culture`, `africa`.
