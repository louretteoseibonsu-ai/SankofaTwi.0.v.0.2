#!/usr/bin/env node
// Sankofa Twi — curriculum invariant validator (CI-ready, zero dependencies, Node >= 18).
// Enforces the non-negotiables on every content/**/*.json unit:
//   I1 required keys present
//   I2 lineage_challenges length === 10
//   I3 action_button must NOT appear in authored content (it is a fixed UI label)
//   I4 no diaspora-mapping / cross-cultural analogies in content
//   I6 theological_framework tags present and within the controlled vocabulary
//   Phonetic bridge: pronunciation always present; segmented mode requires homophone_set_id
// Exit code 1 on any violation, 0 otherwise.

import { readFile, readdir } from "node:fs/promises";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const CONTENT_DIR = join(ROOT, "content");
const SCHEMA_PATH = join(ROOT, "contracts", "sankofa_twi.schema.json");

const REQUIRED_UNIT_KEYS = [
  "unit_title",
  "vocabulary_spotlight",
  "grammar_mechanics",
  "lineage_challenges",
  "theological_framework",
];

// I4 — banned analogy / diaspora-mapping patterns (whole word, case-insensitive).
const BANNED_PATTERNS = [
  /\bsimilar to\b/i,
  /\bequivalent of\b/i,
  /\bakin to\b/i,
  /\bcomparable to\b/i,
  /\blike the\b/i,
  /\bdiaspora\b/i,
  /\bwestern\b/i,
  /\bchristian\b/i,
  /\bbiblical\b/i,
  /\bgreek\b/i,
  /\broman\b/i,
];

const errors = [];
const fail = (file, msg) => errors.push(`${file}: ${msg}`);

async function loadEnum() {
  const schema = JSON.parse(await readFile(SCHEMA_PATH, "utf8"));
  return new Set(schema.$defs.theologicalFramework.enum);
}

async function walk(dir) {
  let entries;
  try {
    entries = await readdir(dir, { withFileTypes: true });
  } catch {
    return [];
  }
  const files = [];
  for (const e of entries) {
    const p = join(dir, e.name);
    if (e.isDirectory()) files.push(...(await walk(p)));
    else if (e.isFile() && e.name.endsWith(".json")) files.push(p);
  }
  return files;
}

function checkPhoneticBridge(file, where, bridge) {
  if (!bridge || typeof bridge !== "object") return;
  if (typeof bridge.pronunciation !== "string" || bridge.pronunciation.length === 0) {
    fail(file, `${where}: phonetics.pronunciation (simple string) is required`);
  }
  if ("segments" in bridge) {
    if (!Array.isArray(bridge.segments) || bridge.segments.length === 0) {
      fail(file, `${where}: phonetics.segments must be a non-empty array when present`);
    } else if (typeof bridge.homophone_set_id !== "string") {
      fail(file, `${where}: segmented phonetics require homophone_set_id (homophone disambiguation)`);
    }
    for (const [i, seg] of (bridge.segments || []).entries()) {
      if (!seg || typeof seg.orthography !== "string" || seg.orthography.length === 0) {
        fail(file, `${where}: segments[${i}].orthography must preserve exact graphemes (e.g. ɔ, ɛ)`);
      }
    }
  }
}

function validateUnit(file, unit, frameworks) {
  // I1
  for (const k of REQUIRED_UNIT_KEYS) {
    if (!(k in unit)) fail(file, `I1: missing required key "${k}"`);
  }
  // I3 — deep scan for action_button
  if (JSON.stringify(unit).includes('"action_button"')) {
    fail(file, `I3: "action_button" must not appear in content (it is hard-coded to "Continue")`);
  }
  // I6 — unit-level tag
  if (unit.theological_framework && !frameworks.has(unit.theological_framework)) {
    fail(file, `I6: theological_framework "${unit.theological_framework}" not in controlled vocabulary`);
  }
  // I2 — exactly 10
  const lc = unit.lineage_challenges;
  if (!Array.isArray(lc)) {
    fail(file, `I2: lineage_challenges must be an array`);
  } else if (lc.length !== 10) {
    fail(file, `I2: lineage_challenges must contain exactly 10 items (found ${lc.length})`);
  }
  // Per-challenge tags + phonetic targets
  (Array.isArray(lc) ? lc : []).forEach((c, i) => {
    if (!c || !frameworks.has(c.theological_framework)) {
      fail(file, `I6: lineage_challenges[${i}] has missing/invalid theological_framework`);
    }
    if (c && c.phonetic_target) checkPhoneticBridge(file, `lineage_challenges[${i}].phonetic_target`, c.phonetic_target);
  });
  // Vocabulary spotlight
  const v = unit.vocabulary_spotlight;
  if (v && typeof v === "object") {
    if (!frameworks.has(v.theological_framework)) {
      fail(file, `I6: vocabulary_spotlight has missing/invalid theological_framework`);
    }
    checkPhoneticBridge(file, "vocabulary_spotlight.phonetic_bridge", v.phonetic_bridge);
  }
  // Grammar mechanics — theological_framework required (QA checklist item 4)
  const g = unit.grammar_mechanics;
  if (g && typeof g === "object" && !frameworks.has(g.theological_framework)) {
    fail(file, `I6: grammar_mechanics has missing/invalid theological_framework`);
  }
  // I4 — banned analogies across the whole unit text
  const text = JSON.stringify(unit);
  for (const re of BANNED_PATTERNS) {
    const m = text.match(re);
    if (m) fail(file, `I4: banned analogy/diaspora-mapping term detected: "${m[0]}"`);
  }
}

async function main() {
  const frameworks = await loadEnum();
  const files = await walk(CONTENT_DIR);
  if (files.length === 0) {
    console.log("ℹ no content/**/*.json units found — nothing to validate (pre-content stage). PASS");
    process.exit(0);
  }
  for (const f of files) {
    const rel = f.replace(ROOT + "/", "");
    try {
      const unit = JSON.parse(await readFile(f, "utf8"));
      validateUnit(rel, unit, frameworks);
    } catch (e) {
      fail(rel, `invalid JSON: ${e.message}`);
    }
  }
  if (errors.length) {
    console.error(`\n✖ Curriculum validation FAILED (${errors.length} issue(s)):`);
    for (const e of errors) console.error("  - " + e);
    process.exit(1);
  }
  console.log(`✔ Curriculum validation PASSED — ${files.length} unit(s) conform to all invariants.`);
}

main().catch((e) => {
  console.error("validator crashed:", e);
  process.exit(1);
});
