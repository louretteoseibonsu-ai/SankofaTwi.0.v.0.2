# Sankofa Twi — UX/UI System & Migration Briefs

Calm-technology, heritage-premium. Governs the React prototype now and the Flutter Material 3 target. The React app (`src/`) is the **reference**, not the production target.

Two streams throughout:
- **REACT-NOW** — improve in the current prototype today.
- **FLUTTER-TARGET** — target-state component briefs to build during migration (do not assume they exist).

---

## 1. Design Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `color/plantain-green` | `#2E8B57` | primary brand, primary CTA, active states |
| `color/plantain-green-deep` | `#1F6B41` | pressed/active, headings on light |
| `color/accent-coral` | `#E2725B` | accent only — milestones, streak, single highlight per view (never two corals competing) |
| `color/sand` | `#F6F1E7` | app background (warm, low-glare → calm) |
| `color/ink` | `#1C1B19` | primary text |
| `color/ink-soft` | `#6B655C` | secondary text |
| `radius/card` | `24px` | all floating cards, sheets, primary buttons |
| `radius/chip` | `999px` | pills, phonetic chips |
| `elevation/float` | y+8, blur 24, 8% green-tinted shadow | floating card resting state |
| `elevation/lift` | y+14, blur 32 | hover/press lift |
| `motion/spring` | stiffness 380, damping 26, ~300ms settle | all transitions |
| `space/base` | 4px grid (8/12/16/24/32) | spacing rhythm |
| `type/display` | 28–32, weight 800, tight tracking | unit titles |
| `type/body` | 15–16, 1.5 line | content |

Color discipline (calm tech): green carries the journey, coral marks *one* meaningful moment per screen, sand keeps it low-contrast and quiet. No gradients on content cards; reserve the deep emerald gradient for the hero/brand only.

---

## 2. React Prototype Audit

| Area | Current state | Verdict |
|------|---------------|---------|
| Palette | emerald-700/800/900 + amber-400/500 + stone | Off-target. Swap to Plantain Green + Coral + Sand |
| Card radius | mostly `rounded-2xl` (16px), some `rounded-3xl` (24px) | Standardize to **24px** |
| Floating cards | white cards + `shadow-sm/md` | Close; deepen to a green-tinted float shadow |
| Primary CTA | varies: "Start Learning", "Next Question", "Finish Quiz", "Analyze philosophical depth" | **Violates rule** — main progression CTA must be **"Continue"** |
| Mobile nav | nav bar sits at **top** (under header) | One-handed fail. Move to **bottom** |
| Motion | spring hover/tap + staggers (added) | On-target; keep |
| Density | header pulse dot + tagline + many labels | Mild clutter; reduce chrome |
| Philosophy cues | full descriptions on cards | Good content, but presented flat — make subtle/progressive |

---

## 3. REACT-NOW Recommendations (apply in `src/`)

R1 — **Token swap** (`src/index.css` + Tailwind usage): introduce CSS vars `--plantain`, `--coral`, `--sand`; replace `emerald-*`→plantain, `amber-*`→coral (accent-only), `stone-50` page bg→sand.
R2 — **Radius**: replace `rounded-2xl`→`rounded-[24px]` on cards/buttons; chips stay pill.
R3 — **CTA standardization**: the single forward action per view renders as a shared `<ContinueButton>` labeled **"Continue"**. Keep secondary verbs ("Analyze", "Share") visually subordinate (text buttons). Quiz "Next/Finish" → "Continue".
R4 — **One-handed nav**: move the mobile tab bar to a bottom-fixed bar (`fixed bottom-0`), thumb-reachable; raise to 56px with safe-area padding.
R5 — **Float shadow**: card shadow → `0 8px 24px -8px rgba(46,139,87,.18)`.
R6 — **Calm pass**: remove the pulsing status dot; demote the right-side tagline to a single muted line; cap one coral element per screen.
R7 — **Subtle philosophy**: on symbol/lesson cards show only `name + core value` at rest; reveal full description on tap/expand (progressive disclosure), so meaning deepens rather than dumps.

These are non-breaking and keep the prototype demoable. They are **prototype polish**, not production work.

---

## 4. FLUTTER-TARGET Component Briefs (build during migration)

Each is a future widget; none exist yet.

### `FloatingCard` — FLUTTER-TARGET
- Material 3 `Card` surfaceTintColor off; custom `BoxShadow` = elevation/float; `BorderRadius.circular(24)`.
- Props: `child`, `onTap?`, `coralAccent: bool=false` (adds a 3px coral left-rule for the single highlighted card).
- Press: scale 0.98 + lift shadow via `AnimatedScale` on spring (~300ms).

### `ContinueButton` — FLUTTER-TARGET  (enforces the CTA rule)
- `FilledButton`, full-width, 24px radius, plantain green, label **hard-coded** `AppConstants.actionButtonLabel` (`"Continue"`). No `label` prop is exposed — callers cannot rename it.
- States: enabled / pressed (deep green) / disabled (sand-on-sand). Haptic light-impact on tap.

### `OneHandNavBar` — FLUTTER-TARGET
- Bottom `NavigationBar` (Material 3), 5 destinations, thumb zone; active pill in plantain green that **slides** between items on spring (mirrors the React indicator).
- Center destination optionally raised (FAB-style) for the primary "Learn" flow.

### `MilestoneMap` — FLUTTER-TARGET  (replaces generic progress bars)
- Vertical, scroll-snapped "lineage path": each unit is a `FloatingCard` node connected by a thin path line; completed nodes carry a small Adinkra glyph seal (not stars/XP — no shallow gamification).
- Current node pulses once on entry (spring), coral seal marks the single "now" node.
- Props: `nodes: List<MilestoneNode{title, state: locked|current|done, glyphId}>`.

### `PhilosophicalNudge` — FLUTTER-TARGET  (subtle, never preachy)
- A quiet inline card surfaced *contextually* (e.g., after a lineage challenge about `mogya`): one Akan proverb + a one-line, Akan-internal gloss. No modal, no interruption; dismiss by scroll.
- Premium feel: serif accent line, generous whitespace, coral hairline. Frequency-capped (≤1 per session segment) to avoid clutter.
- Props: `concept: TheologicalFramework`, `proverbTwi`, `glossAkanInternal`. (Content must pass CulturalIntegrityGuard — no diaspora framing.)

### `PronunciationOverlay` — FLUTTER-TARGET  (uses the two-mode phonetic bridge)
- Bottom sheet, 24px top radius. Simple mode: large headword + `pronunciation` string + audio play.
- Homophone mode (segmented): renders each `PhoneticSegment` as a chip showing exact grapheme (e.g. **bɔ**), tone marker (▲ high / ▼ low / – mid), and an ATR badge (+/−). Minimal-pair toggle shows `bo` vs `bɔ` side-by-side so the contrast is *felt*, not explained.
- Props: `bridge: PhoneticBridge` (Simple | Segmented). Never normalizes `ɔ`→`o`.

### `UpgradePrompt` — FLUTTER-TARGET  (premium, value-framed)
- Triggered at depth, not paywalled drills. Framed around **philosophical depth, tonal mastery, lineage continuity** — never "unlock pro features".
- Layout: full-bleed sand sheet, one Adinkra motif, a single value sentence, `ContinueButton`-style CTA in coral ("Continue your lineage path"). One offer, no feature grid (anti-clutter).

---

## 5. Screen Hierarchy (target)

```
AppShell
├── OneHandNavBar (bottom, slides active pill)
└── IndexedStack
    ├── LearnScreen
    │   ├── MilestoneMap (lineage path of units)
    │   └── UnitDetail
    │       ├── FloatingCard: VocabularySpotlight ──▶ PronunciationOverlay
    │       ├── FloatingCard: GrammarMechanics
    │       ├── LineageChallengeList (exactly 10) ──▶ PhilosophicalNudge (contextual)
    │       └── ContinueButton ("Continue")   ← only forward CTA
    ├── DayNameScreen
    ├── TutorScreen (AI)
    ├── QuizScreen → ContinueButton ("Continue")
    └── SymbolsScreen (Adinkra gallery → tap = progressive disclosure)
```

---

## 6. Migration Roadmap (React → Flutter, per component)

| React (now) | Flutter (target) | Phase |
|-------------|------------------|-------|
| tab `<motion.button>` + indicator | `OneHandNavBar` (bottom) | 2 |
| symbol/category cards | `FloatingCard` + progressive disclosure | 2 |
| ad-hoc CTAs | `ContinueButton` (locked label) | 1 (also fix in React now) |
| quiz progress bar | `MilestoneMap` lineage path | 3 |
| inline symbol descriptions | `PhilosophicalNudge` | 3 |
| phonetic text (string only) | `PronunciationOverlay` (simple + segmented) | 2 |
| — (none) | `UpgradePrompt` | 4 |

Phase 1 = parity primitives, Phase 2 = core learn loop, Phase 3 = heritage depth, Phase 4 = monetization. Keep React running until Phase 3 parity; cut-over is a separate ADR.

---

## 7. Non-Negotiables Encoded in UI
- Forward CTA is **always** "Continue" — enforced by `ContinueButton` exposing no label prop.
- Philosophy is **progressive + contextual**, never modal walls or flattening summaries.
- **One** coral moment per screen; sand background; 24px floats — calm, not busy.
- No XP/badges/streak-spam. Progress is a **lineage path**, not a game score.
