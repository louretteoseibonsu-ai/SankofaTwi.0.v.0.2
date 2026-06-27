# Sankofa Twi — Architecture Governance (Clean Architecture)

Status: authoritative for coding agents. Source of truth: this file + the finalized JSON schema in `/contracts`.
Stack: Flutter (frontend) · Firebase (Auth/Firestore/Functions/Storage) · Vertex AI (content generation) · GitHub (source of truth) · use.ai / Claude (orchestration).

> Divergence note: the current repository is a React/Vite prototype. This document governs the **Flutter rebuild**. Treat the React app as a reference for content/UX only, not as architecture.

---

## 0. Non-Negotiable Invariants (enforced, not advisory)

| # | Invariant | Enforced in (layer) | Mechanism |
|---|-----------|---------------------|-----------|
| I1 | Curriculum unit always exposes `unit_title`, `vocabulary_spotlight`, `grammar_mechanics`, `lineage_challenges` | core (entity) + data (DTO mapper) | non-nullable fields; mapper throws `SchemaFailure` on absence |
| I2 | `lineage_challenges` contains **exactly 10** items | core (value object) + logic (validator) + Firestore rules | `LineageChallengeSet` rejects `length != 10`; CI + DB rule double-guard |
| I3 | `action_button` is hard-coded `"Continue"` | core (const) + ui | not parsed from data, not editable; const `kActionButtonLabel` |
| I4 | No diaspora-mapping / cross-cultural analogies | logic (CulturalIntegrityGuard) + content pipeline | banned-pattern lint on generated + authored text; PR gate |
| I5 | Akan concepts defined strictly within Akan cosmology + sociopolitical structures | core (taxonomy) + content pipeline | controlled `TheologicalFramework` vocabulary; prompts forbid external framing |
| I6 | `theological_framework` tagging supported on all relevant models | core (entities) | required tag field on unit/vocab/challenge content models |
| I7 | Homophone-sensitive phonetics (e.g. `bo` vs `bɔ`) never normalized away | core (PhoneticForm VO) | grapheme-exact equality incl. `ɔ ɛ` + tone; no Unicode folding |

Any change to I1–I7 requires an ADR (`/docs/adr`) and Architect sign-off.

---

## 1. Layer Map & Dependency Rule

Four layers, dependencies point **inward** to `core`. Inner layers never import outer layers.

```
ui  ──────▶ logic ──────▶ core ◀────── data
(widgets)   (use cases,    (entities,   (DTOs, Firebase/
            controllers,   value objs,  Vertex sources,
            state)         contracts)   repo impls)
```

- **core** — pure Dart. Entities, value objects, enums, failures, repository/use-case *interfaces*, constants, invariants. Zero Flutter, zero Firebase imports.
- **data** — implements `core` interfaces. Firestore/Vertex/Storage data sources, DTOs, JSON mappers (parsing lives here only), caching.
- **logic** — application layer. Use cases, controllers, state management (Riverpod), validators, the Curriculum Engine, the CulturalIntegrityGuard. Depends only on `core`.
- **ui** — Flutter widgets/screens/routing/view-models. Depends on `logic` + `core` entities. Renders only; never parses JSON.

Rule 3 (parsing ≠ rendering): JSON → DTO → entity mapping is **exclusively** in `data`. `ui` consumes entities. A lint rule forbids `dart:convert`/`fromJson` outside `data`.

---

## 2. Folder Structure (layer-first, feature-scoped within)

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # kActionButtonLabel = 'Continue', kLineageChallengeCount = 10
│   ├── error/
│   │   ├── failures.dart             # Failure, SchemaFailure, InvariantFailure, IntegrityFailure
│   │   └── exceptions.dart
│   ├── cosmology/
│   │   ├── theological_framework.dart# controlled Akan taxonomy (enum + metadata)
│   │   └── akan_concept.dart         # Sunsum, Mogya, Animuonyam, Okra, Ntoro... definitions
│   ├── phonetics/
│   │   ├── phonetic_form.dart        # VO: orthography, ipa, tone, ATR, nasal, homophoneSetId
│   │   ├── tone.dart                 # enum Tone { high, low, mid, rising, falling }
│   │   └── akan_orthography.dart     # grapheme set incl. ɔ ɛ; NFC guards
│   ├── entities/
│   │   ├── curriculum_unit.dart
│   │   ├── vocabulary_spotlight.dart
│   │   ├── grammar_mechanics.dart
│   │   ├── lineage_challenge.dart
│   │   └── lineage_challenge_set.dart# enforces exactly-10
│   ├── contracts/                    # interfaces only
│   │   ├── curriculum_repository.dart
│   │   ├── phonetics_repository.dart
│   │   └── content_generation_service.dart
│   └── usecase/usecase.dart          # UseCase<Out, Params> base, Either<Failure,Out>
│
├── data/
│   ├── dto/
│   │   ├── curriculum_unit_dto.dart  # fromJson/toJson + toEntity (parsing lives here)
│   │   ├── vocabulary_spotlight_dto.dart
│   │   ├── grammar_mechanics_dto.dart
│   │   └── lineage_challenge_dto.dart
│   ├── mappers/
│   │   └── curriculum_mapper.dart    # DTO ↔ entity; raises SchemaFailure
│   ├── datasources/
│   │   ├── firestore_curriculum_ds.dart
│   │   ├── vertex_content_ds.dart    # Vertex AI structured-output calls
│   │   └── local_cache_ds.dart
│   └── repositories/
│       ├── curriculum_repository_impl.dart
│       └── phonetics_repository_impl.dart
│
├── logic/
│   ├── curriculum_engine/
│   │   ├── curriculum_engine.dart    # assembles + validates a unit
│   │   ├── invariant_validator.dart  # I1, I2, I3, I6
│   │   └── unit_builder.dart
│   ├── integrity/
│   │   ├── cultural_integrity_guard.dart # I4, I5 banned-pattern + taxonomy checks
│   │   └── banned_patterns.dart
│   ├── usecases/
│   │   ├── get_curriculum_unit.dart
│   │   ├── generate_unit_content.dart
│   │   └── resolve_phonetic_form.dart
│   └── controllers/                  # Riverpod notifiers (state)
│       ├── curriculum_controller.dart
│       └── lesson_player_controller.dart
│
├── ui/
│   ├── theme/
│   ├── routing/app_router.dart
│   ├── widgets/                      # AdinkraGlyph, PhoneticChip, ActionButton(const label)
│   └── features/
│       ├── lesson/lesson_screen.dart
│       └── lineage/lineage_challenge_screen.dart
│
├── di/injector.dart                  # get_it/Riverpod wiring
└── main.dart

contracts/                            # language-agnostic, GitHub-tracked
└── sankofa_twi.schema.json           # the finalized JSON schema (single source)

functions/                            # Firebase Cloud Functions
└── src/validateCurriculum.ts         # server-side I1–I3, I6 gate on write

docs/
├── architecture/SANKOFA_TWI_ARCHITECTURE.md  (this file)
└── adr/                              # architecture decision records
```

---

## 3. Core Domain Models (Dart, freezed-style)

Models use `freezed` for immutability + value equality. Invariants live in constructors/factories.

```dart
// core/constants/app_constants.dart
const String kActionButtonLabel = 'Continue';   // I3 — never sourced from data
const int    kLineageChallengeCount = 10;        // I2
```

```dart
// core/entities/curriculum_unit.dart
@freezed
class CurriculumUnit with _$CurriculumUnit {
  const CurriculumUnit._();
  const factory CurriculumUnit({
    required String unitTitle,                       // unit_title (I1)
    required VocabularySpotlight vocabularySpotlight,// vocabulary_spotlight (I1)
    required GrammarMechanics grammarMechanics,      // grammar_mechanics (I1)
    required LineageChallengeSet lineageChallenges,  // lineage_challenges, exactly 10 (I1,I2)
    required TheologicalFramework theologicalFramework, // I6
  }) = _CurriculumUnit;

  String get actionButton => kActionButtonLabel;     // I3 — computed const, not a field
}
```

```dart
// core/entities/lineage_challenge_set.dart  — enforces I2
@freezed
class LineageChallengeSet with _$LineageChallengeSet {
  const LineageChallengeSet._();
  const factory LineageChallengeSet._(List<LineageChallenge> items) = _LineageChallengeSet;

  factory LineageChallengeSet(List<LineageChallenge> items) {
    if (items.length != kLineageChallengeCount) {
      throw const InvariantFailure('lineage_challenges must contain exactly 10 items');
    }
    return LineageChallengeSet._(List.unmodifiable(items));
  }
}
```

```dart
// core/entities/vocabulary_spotlight.dart
@freezed
class VocabularySpotlight with _$VocabularySpotlight {
  const factory VocabularySpotlight({
    required String headword,            // Twi orthography (NFC, exact graphemes)
    required PhoneticForm phonetics,     // I7 — bo vs bɔ preserved
    required String gloss,               // Akan-internal definition only (I5)
    required TheologicalFramework theologicalFramework, // I6
    @Default(<String>[]) List<String> exampleSentences,
  }) = _VocabularySpotlight;
}
```

```dart
// core/entities/lineage_challenge.dart
enum ChallengeType { recall, phoneticDiscrimination, lineageOrdering, conceptMatch }

@freezed
class LineageChallenge with _$LineageChallenge {
  const factory LineageChallenge({
    required String prompt,
    required ChallengeType type,
    required List<String> options,
    required int correctIndex,
    PhoneticForm? phoneticTarget,        // for bo/bɔ discrimination items
    required TheologicalFramework theologicalFramework, // I6
  }) = _LineageChallenge;
}
```

---

## 4. Cosmology Taxonomy (I5) — Akan-internal only

`theological_framework` is a **controlled vocabulary**, not free text. Definitions are bound to Akan cosmology and sociopolitical structures; no external framing is permitted in metadata or generated copy.

```dart
// core/cosmology/theological_framework.dart
enum TheologicalFramework {
  onyame,        // Supreme Being / creator
  abosom,        // tutelary deities
  nsamanfo,      // ancestors / venerated dead
  okra,          // life-soul given by Onyame
  sunsum,        // spirit / personality-energy
  mogya,         // blood; matrilineal abusua identity
  ntoro,         // patrilineal spirit-transmission
  animuonyam,    // dignity / honor / glory
  abusua,        // matriclan sociopolitical unit
  ahenfie,       // chieftaincy / court structure
  adinkra,       // symbolic-proverbial system
}
```

```dart
// core/cosmology/akan_concept.dart — strict, self-contained definitions
class AkanConcept {
  final TheologicalFramework tag;
  final String akanTerm;        // e.g. 'Sunsum'
  final String definition;      // defined ONLY within Akan cosmology + sociopolitics
  final List<String> relatedTerms; // other Akan terms (no foreign analogues)
  const AkanConcept({required this.tag, required this.akanTerm,
                     required this.definition, required this.relatedTerms});
}
```

Authoring rule: a concept's `definition` may reference other Akan concepts (`okra`, `mogya`, `ntoro`, `abusua`) but must not be explained via non-Akan religious, philosophical, or diaspora frameworks (I4/I5).

---

## 5. Homophone-Sensitive Phonetic Model (I7)

`bo` vs `bɔ` are distinct (vowel `o` +ATR vs `ɔ` −ATR) and tone is contrastive. The VO preserves graphemes and tone; equality is grapheme- and tone-exact. **No NFKC folding, no ASCII fallback.**

```dart
// core/phonetics/phonetic_form.dart
@freezed
class PhoneticForm with _$PhoneticForm {
  const PhoneticForm._();
  const factory PhoneticForm({
    required String orthography,   // NFC, exact: 'bo' ≠ 'bɔ'
    required String ipa,           // e.g. /bo/ vs /bɔ/
    required List<Tone> tones,     // per-syllable tone, contrastive
    required AtrClass atr,         // +ATR / -ATR vowel harmony class
    @Default(false) bool nasalized,
    required String homophoneSetId,// groups TRUE homophones only
    String? senseKey,              // disambiguates within a homophone set
  }) = _PhoneticForm;

  // Equality MUST keep minimal pairs distinct (I7).
  @override
  bool operator ==(Object o) =>
      o is PhoneticForm &&
      o.orthography == orthography &&   // ɔ/o, ɛ/e preserved
      listEquals(o.tones, tones) &&
      o.atr == atr && o.nasalized == nasalized;
}
```

```dart
enum Tone { high, low, mid, rising, falling }
enum AtrClass { advanced, retracted } // +ATR (o,e,i,u,a-adv) vs -ATR (ɔ,ɛ,...)
```

Guards in `core/phonetics/akan_orthography.dart`:
- Validate input contains only the Asante Twi grapheme set (`a e ɛ i o ɔ u` + tone marks, nasal).
- Reject/repair non-NFC input; never strip `ɔ`/`ɛ`.
- `homophoneSetId` is assigned only when orthography **and** tone match; `bo`/`bɔ` therefore land in different sets.

---

## 6. JSON Schema Contract & Parsing (Rule 3)

`/contracts/sankofa_twi.schema.json` is the single source. Parsing is confined to `data/`.

DTO → entity flow (the only place `fromJson` is allowed):

```dart
// data/mappers/curriculum_mapper.dart
CurriculumUnit toEntity(CurriculumUnitDto d) {
  final challenges = d.lineageChallenges.map(_challenge).toList();
  // I1: missing fields already non-nullable on DTO → SchemaFailure on null
  // I2: constructor throws if length != 10
  return CurriculumUnit(
    unitTitle: d.unitTitle,
    vocabularySpotlight: _vocab(d.vocabularySpotlight),
    grammarMechanics: _grammar(d.grammarMechanics),
    lineageChallenges: LineageChallengeSet(challenges),
    theologicalFramework: TheologicalFramework.values.byName(d.theologicalFramework),
  );
  // NOTE: d.actionButton is intentionally NOT read (I3).
}
```

Mapper responsibilities: (a) raise `SchemaFailure` on shape mismatch, (b) enforce I1/I2/I6 at the boundary, (c) drop/ignore any incoming `action_button` value.

---

## 7. Repository & Use-Case Contracts (core/contracts)

All async ops return `Either<Failure, T>` (dartz). UI/logic never see raw exceptions.

```dart
// core/contracts/curriculum_repository.dart
abstract interface class CurriculumRepository {
  Future<Either<Failure, CurriculumUnit>> getUnit(String unitId);
  Future<Either<Failure, List<String>>> listUnitIds({String? track});
  Future<Either<Failure, Unit>> cacheUnit(CurriculumUnit unit);
}

// core/contracts/content_generation_service.dart
abstract interface class ContentGenerationService {
  /// Returns a DRAFT unit that MUST pass CulturalIntegrityGuard + InvariantValidator
  /// before persistence. Never writes directly.
  Future<Either<Failure, CurriculumUnit>> generateUnit(GenerateUnitParams params);
}
```

```dart
// logic/usecases/get_curriculum_unit.dart
class GetCurriculumUnit implements UseCase<CurriculumUnit, UnitParams> {
  final CurriculumRepository repo;
  const GetCurriculumUnit(this.repo);
  @override
  Future<Either<Failure, CurriculumUnit>> call(UnitParams p) => repo.getUnit(p.id);
}
```

Controller contract (state):

```dart
// logic/controllers/curriculum_controller.dart
sealed class CurriculumState {}
class CurriculumLoading extends CurriculumState {}
class CurriculumReady   extends CurriculumState { final CurriculumUnit unit; ... }
class CurriculumError   extends CurriculumState { final Failure failure; ... }

class CurriculumController extends StateNotifier<CurriculumState> {
  // load(unitId) -> validates via InvariantValidator -> emits Ready/Error
}
```

---

## 8. Vertex AI Content Pipeline (I4/I5 guardrails)

Generated content is **untrusted** until validated. Flow:

```
GenerateUnitParams
   ↓ (data/datasources/vertex_content_ds.dart)
Vertex AI structured-output call  (responseSchema = sankofa_twi.schema.json subset)
   ↓ DTO → entity (mapper: I1,I2,I6)
CulturalIntegrityGuard  (I4 banned patterns, I5 taxonomy-bound definitions)
   ↓ pass
InvariantValidator (I1–I3,I6)
   ↓ pass
Firestore write  (Cloud Function re-validates server-side)
```

Prompt contract (system-level, immutable, in `data/datasources/vertex_content_ds.dart`):
- Output MUST conform to `responseSchema`; `lineage_challenges` length 10; omit `action_button`.
- Define Akan concepts **only** within Akan cosmology + historical sociopolitical structures.
- FORBIDDEN: comparisons/analogies to non-Akan traditions, diaspora mapping, "similar to", "the African equivalent of", etc.

```dart
// logic/integrity/banned_patterns.dart  (I4)
const bannedAnalogyPatterns = <RegExp>[
  RegExp(r'\b(similar to|equivalent of|like the|akin to|comparable to)\b', caseSensitive: false),
  RegExp(r'\b(diaspora|western|christian|biblical|greek|roman)\b', caseSensitive: false),
];
// CulturalIntegrityGuard rejects any unit whose copy matches; emits IntegrityFailure.
```

---

## 9. Firebase Model & Server-Side Guard

Firestore (denormalized read model):
```
curriculum_units/{unitId}
  unit_title: string
  vocabulary_spotlight: map
  grammar_mechanics: map
  lineage_challenges: array  (len == 10)
  theological_framework: string  (∈ TheologicalFramework)
  // action_button intentionally absent
```

Security rule (defense-in-depth for I2/I3/I6):
```
match /curriculum_units/{id} {
  allow write: if request.auth.token.role == 'author'
    && request.resource.data.lineage_challenges.size() == 10            // I2
    && !('action_button' in request.resource.data)                     // I3
    && request.resource.data.theological_framework is string;          // I6
}
```
Cloud Function `validateCurriculum` re-runs I1–I3/I6 on write and rejects non-conforming docs (clients can be bypassed; the server cannot).

---

## 10. Orchestration Layer (use.ai / Claude) & GitHub Governance

GitHub is the single source of truth; all changes land via PR.

Agent roles (orchestrated):
- **SchemaGuardian** — blocks PRs that alter `/contracts/sankofa_twi.schema.json` without an ADR; verifies I1–I3, I6.
- **CulturalReviewer** — runs CulturalIntegrityGuard over authored + generated content (I4/I5).
- **RefactorAgent** — keeps code inside layer boundaries; fails CI on illegal cross-layer imports.
- **ContentAuthor** — drafts units via Vertex pipeline; output is a PR, never a direct DB write.

CI gates (required checks, must pass to merge):
1. `dart analyze` + custom lint: no `fromJson`/`dart:convert` outside `data/`; no `ui→data` imports.
2. Schema validation of all fixtures against `sankofa_twi.schema.json`.
3. Invariant tests (I1–I3, I6) + phonetic equality tests (I7: `bo != bɔ`).
4. Banned-analogy scan (I4) over content + docs.

---

## 11. Implementation Checklist (for coding agents)

1. Scaffold `lib/{core,data,logic,ui,di}` per §2; add `freezed`, `dartz`, `riverpod`, `get_it`.
2. Implement `core` first: constants (I3, I2 count), failures, `TheologicalFramework`, `PhoneticForm` (+ equality tests for `bo`/`bɔ`), entities, `LineageChallengeSet` (exactly-10 test).
3. Commit `/contracts/sankofa_twi.schema.json`; generate DTOs; implement `data` mappers raising `SchemaFailure`; add the lint forbidding parsing outside `data`.
4. Implement `logic`: `InvariantValidator`, `CulturalIntegrityGuard`, Curriculum Engine, use cases, controllers.
5. Build `ui` with a const `ActionButton(label: kActionButtonLabel)`; screens render entities only.
6. Wire Vertex pipeline (§8) + Cloud Function guard (§9); enable CI gates (§10).
7. Every I1–I7 change → ADR in `/docs/adr` + Architect approval.

---

## 12. Migration Disposition (current repo = React prototype only)

The repo today contains **only** the React prototype. There is **no** finalized schema, **no** Flutter scaffolding (`lib/`, `android/`, `ios/`, `pubspec.yaml`, `assets/` do not exist). Everything in §2–§11 is **migration work**. The folder trees and Dart in this document are *target-state specifications*, not existing code.

Every file is classified into exactly one bucket:

### Bucket A — Create now (governance + contracts; no app code, no React disruption)
| Path | Purpose | Status |
|------|---------|--------|
| `docs/architecture/SANKOFA_TWI_ARCHITECTURE.md` | this governing spec | ✅ created |
| `docs/adr/0001-record-architecture-decisions.md` | ADR process + template | proposed |
| `docs/adr/0002-sankofa-twi-schema-as-source-of-truth.md` | freezes I1–I7 | proposed |
| `contracts/sankofa_twi.schema.json` | **DRAFT stub**, non-authoritative until finalized by Architect | proposed |

These are docs/JSON only — they neither run nor touch the React build.

### Bucket B — Migrate later (Flutter app; create only when migration sprint starts)
Do **not** create these until explicitly tasked. Order = dependency order.
1. `pubspec.yaml`, `analysis_options.yaml` (lint rules enforcing layer boundaries + parsing-in-`data` only)
2. `lib/core/**` (constants, failures, cosmology, phonetics, entities, contracts)
3. `lib/data/**` (DTOs, mappers, datasources, repo impls)
4. `lib/logic/**` (engine, integrity guard, use cases, controllers)
5. `lib/ui/**`, `lib/di/injector.dart`, `lib/main.dart`
6. `functions/**` (Cloud Function server-side guard), Firebase project config
7. `android/`, `ios/`, `assets/` (generated by `flutter create`, then customized)

### Bucket C — Leave untouched (React prototype — reference only)
Do **not** modify during Flutter migration; these remain the working reference implementation:
`src/**`, `index.html`, `server.ts`, `vite.config.ts`, `tsconfig.json`, `package.json`, `package-lock.json`, `metadata.json`, `assets/.aistudio/**`.

Coexistence rule: until the Flutter app reaches parity, React (`src/`) and Flutter (`lib/`) live side-by-side in the monorepo on separate top-level paths. No shared build. Cut-over is a separate ADR.
