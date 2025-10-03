## Goals and Background Context

### Goals

* Deliver an Inspect-based evaluation that **quantifies LLM-judge biases** (position, verbosity, safety‑preface) with reproducible metrics.
* **Expand** the baseline by adding an **AutoStyle Attack** that discovers content‑preserving “winning styles” and a **Style Normalizer** defense that reduces bias.
* Provide a **Cross‑Judge Calibration** module to compare multiple judges and report **disagreement, bias shrinkage, and confidence**.
* Ship a **turnkey workflow** (CLI + Inspect tasks + HTML/Markdown report) that runs in < 2 hours on workshop hardware with API‑only LLM access.
* Enforce **safe-by-default** practices (innocuous prompts, no harmful content stored; label-only options).
* Make results **explainable and teachable**: visual dashboards, small ablation toggles, and guidance for further experiments.

### Background Context

LLM‑as‑a‑Judge is widely used in eval pipelines, but judges can be **swayed by style artifacts** even when answer content is identical. The baseline workshop shows this effect in Inspect. This PRD elevates the exercise by (1) **automating style search** (attack) under content‑equivalence constraints, (2) **normalizing** answers before judging (defense), and (3) **calibrating across multiple judges** to quantify robustness and variance. The result is a compact, API‑only framework teams can understand, extend, and trust as a pattern for building safer evaluations.

### Change Log

| Date       | Version | Description                                     | Author              |
| ---------- | ------- | ----------------------------------------------- | ------------------- |
| 2025-10-03 | 0.1     | Initial draft PRD (no external brief attached). | GPT-5 Pro (ChatGPT) |

---

## Requirements

### Functional (FR)

* **FR1:** Provide three Inspect tasks that reproduce baseline biases: **position**, **verbosity**, **safety‑preface**.
* **FR2:** Implement **AutoStyle Attack**: an iterative rewriter that searches style space (length, structure, tone, prefaces, citations‑ish framing) while preserving semantics.
* **FR3:** Implement **Style Normalizer** (defense) that enforces neutral tone, concision, and removes apologies/disclaimers without altering meaning.
* **FR4:** Add a **Cross‑Judge Calibration** runner that evaluates the same comparisons with ≥2 judge models and reports **preference rates, tie rates, and inter‑judge agreement**.
* **FR5:** Include a **Content‑Equivalence Guard** that rejects or re‑writes candidate pairs if the rewriter changed meaning (LLM check + heuristic similarity guard).
* **FR6:** Output a consolidated **Report** (Markdown + optional HTML) with bias indices, confidence intervals, and “before vs after normalization” deltas.
* **FR7:** Provide **CLI flags** to configure models per role (author/rewriter/grader), sample size/seed, attack rounds, and normalization on/off.
* **FR8:** Persist **run artifacts** (config, metrics JSON, Inspect logs) for reproducibility; include a `--dry-run` mode for cost estimation.
* **FR9:** Offer **label‑only logging** for judged comparisons (no raw model text) to support safe demonstrations.
* **FR10:** Provide small **starter datasets** (20–60 innocuous CS/SE questions) and accept custom CSV input.
* **FR11:** Compute and show **Bias Resilience Score (BRS)** per judge: `BRS = 1 − weighted_bias_after_normalization`, weights configurable per bias type.
* **FR12:** Provide **statistical tests**: Wilson 95% CI for preference proportions; McNemar test for paired AB vs BA; bootstrap for Δs.

### Non Functional (NFR)

* **NFR1:** **API‑only**: no external tools beyond LLM APIs (generation + judging; optional embeddings if available via same provider).
* **NFR2:** **Run time**: default configuration completes within **≤ 90 minutes** on 40–120 comparisons per bias, typical API latencies.
* **NFR3:** **Cost bound**: default budget flag enforces a hard cap; job aborts gracefully if projected spend exceeds cap.
* **NFR4:** **Reproducibility**: seeds, prompts, and versions captured in a single `run_manifest.json`.
* **NFR5:** **Privacy & Safety**: no PII; prompts are innocuous; optional label‑only storage; redact disclosures in errors/logs.
* **NFR6:** **Portability**: Python 3.11+, works on Mac/Linux; zero GPU assumptions.
* **NFR7:** **Observability**: structured logs; metrics export in JSON/CSV; warning if equivalence guard fails > X%.
* **NFR8:** **Accessibility of results**: report renders cleanly in static Markdown; optional HTML with no JS requirement.

---

## User Interface Design Goals

> These UI/UX notes guide how results appear in **Inspect View** and in the **generated report**. **Assumptions are called out**—please confirm where needed.

### Overall UX Vision

A workshop‑friendly experience where participants can:
(1) run a task, (2) inspect a few representative pairs, (3) view concise aggregate charts, and (4) toggle the normalizer or swap judges to see effects immediately.

### Key Interaction Paradigms

* **Role‑based model selection:** simple dropdown/flags for author, rewriter, grader.
* **One‑click rerun with toggles:** `normalize=on/off`, `rounds=1..5`, judge swap.
* **Drill‑down from aggregate to examples:** click a bar to open the underlying AB pair in Inspect’s transcript viewer.
* **Safety‑first browsing:** label‑only mode hides raw completions by default with a “reveal for this row” guard.

### Core Screens and Views

* **Run Config Panel:** models per role, sample size, caps, attack rounds.
* **Bias Dashboard:** bars for preference rates (A% vs B%), Δ from 50%, CIs; pre/post normalization comparison.
* **Attack Explorer:** line chart of preference vs attack round; table of top “winning styles.”
* **Judge Calibration View:** matrix of judges × biases with BRS, tie rate, κ/percent agreement.
* **Pair Browser:** AB text (collapsed by default), equivalence verdict, winner, and rationale trace.

### Accessibility: WCAG AA

* High‑contrast charts, keyboard navigation, clear focus states, descriptive alt text in HTML report.

### Branding

* Use minimal neutral styling; room to apply workshop/organization logo and colors later.

### Target Device and Platforms: Web Responsive

* Inspect View in browser + static report for sharing; no mobile‑specific flows assumed.

**Assumptions made:** We assume Inspect View is available in the workshop environment and participants can open local HTML/Markdown reports. Confirm if you want custom CSS/branding bundled.

---

## Technical Assumptions

### Repository Structure: Monorepo

* Single repo with: `/inspect_tasks`, `/cli`, `/reports`, `/data`, `/docs`.

### Service Architecture

* **Monolith** Python project using **inspect-ai** for tasks/solvers/scorers, plus a small **CLI** wrapper to orchestrate runs and produce reports.

### Testing Requirements

* **Unit + Integration**

  * Unit tests for: equivalence guard, stats calculators, config loader.
  * Integration tests for: small 4‑prompt run using a mock/minimal model backend or deterministic stubs.

### Additional Technical Assumptions and Requests

* Python 3.11+, `inspect-ai` latest; minimal deps (pydantic, numpy, scipy or statsmodels for CIs/tests).
* Model providers configured via environment (e.g., `INSPECT_EVAL_MODEL`, and role overrides).
* Optional embeddings (same provider) for a **semantic‑similarity heuristic** in the equivalence guard.
* Artifacts written to `runs/<timestamp>/...`; report to `runs/<timestamp>/report.md` (+ `.html` if enabled).
* Cost guard implemented via token‑price maps; conservative defaults; dry‑run estimates shown before execution.

---

## Epic List

1. **Epic 1: Foundation & Baseline Bias Tasks** — Set up repo, Inspect tasks (position, verbosity, safety‑preface), basic scorer and metrics.
2. **Epic 2: Content‑Equivalence Guard** — Ensure rewrites do not change meaning; reject/repair pairs automatically.
3. **Epic 3: AutoStyle Attack** — Iteratively search style space to maximize judge preference without altering content.
4. **Epic 4: Style Normalizer & Mitigation Report** — Normalize answers before judging; quantify bias shrinkage and compute **BRS**.
5. **Epic 5: Cross‑Judge Calibration & Reports** — Multi‑judge runs, agreement metrics, final Markdown/HTML report, and label‑only logging.

---

## Epic 1 Foundation & Baseline Bias Tasks

**Goal:** Deliver a working Inspect project with three bias tasks, a pairwise judge scorer, and reproducible metrics.

### Story 1.1 Project Scaffolding

**As a** developer
**I want** a ready repo with Inspect, CLI, and data folders
**so that** I can run experiments immediately.

**Acceptance Criteria**

1. `poetry`/`pip` project with lockfile; `make run` shortcut.
2. `.env.example` with model role env vars; README quickstart.
3. CI lint/test workflow passes on a smoke build.

### Story 1.2 Baseline Tasks (Position, Verbosity, Safety)

**As a** researcher
**I want** Inspect tasks for the three biases
**so that** I can reproduce baseline effects.

**Acceptance Criteria**

1. Tasks compile and run with defaults; sample data (≥20 items).
2. Mean preference and Δ from 50% computed with CIs.
3. Inspect View shows datasets, runs, and aggregate metrics.

### Story 1.3 Pairwise Judge Scorer

**As a** researcher
**I want** a JSON‑strict judge scorer
**so that** results are machine‑parsable and robust.

**Acceptance Criteria**

1. Scorer enforces `{"winner":"A"|"B"}`; tolerant parsing fallback.
2. Seeds and decoding params stored in `run_manifest.json`.
3. Tie handling policy captured (default break ties to A, log tie rate).

---

## Epic 2 Content‑Equivalence Guard

**Goal:** Prevent semantic drift when generating paraphrases/attacks.

### Story 2.1 LLM Equivalence Check

**As a** developer
**I want** an LLM judge for equivalence
**so that** paraphrases that change meaning are rejected.

**Acceptance Criteria**

1. Prompt template returns `{"equivalent": true|false}`.
2. Thresholded confidence or rationale string logged.
3. Non‑equivalent cases are auto‑rewritten up to N retries, else dropped and counted.

### Story 2.2 Heuristic Similarity Gate (Optional)

**As a** developer
**I want** a fast similarity check
**so that** we avoid unnecessary LLM calls.

**Acceptance Criteria**

1. Cosine similarity via provider embeddings (if available) or lexical heuristics (n‑gram overlap).
2. Tunable thresholds; guardrail unit tests with fixture pairs.
3. Guard raises a warning if >10% of pairs fail equivalence.

---

## Epic 3 AutoStyle Attack

**Goal:** Discover style‑only rewrites that sway the judge.

### Story 3.1 Style Generator

**As a** researcher
**I want** K style variants per round
**so that** we can explore the style space efficiently.

**Acceptance Criteria**

1. Rewriter supports knobs: length, structure (bullets/steps), tone (deferential/professional), safety‑preface, citation‑ish framing.
2. All rewrites pass the equivalence guard or are retried/dropped with counters.

### Story 3.2 Selection & Iteration

**As a** researcher
**I want** to select the highest‑scoring variant each round
**so that** we approximate a hill‑climb.

**Acceptance Criteria**

1. Randomized AB order each compare; track winning rate per variant.
2. Converge for R rounds (default 3–5); produce “winning style recipe.”
3. Attack Explorer chart: preference vs round.

---

## Epic 4 Style Normalizer & Mitigation Report

**Goal:** Reduce bias with a neutralizing pre‑judge pass; quantify improvement.

### Story 4.1 Normalizer Prompt

**As a** developer
**I want** a neutralizer that standardizes tone/length
**so that** style artifacts are minimized.

**Acceptance Criteria**

1. Constraints: neutral tone, no apologies/disclaimers, concise ≤120 words, preserve meaning.
2. Passes equivalence guard; failures retried/dropped with counters.

### Story 4.2 Bias Resilience Score (BRS)

**As a** researcher
**I want** a single summary metric
**so that** judges can be compared on robustness.

**Acceptance Criteria**

1. Compute BRS per bias and overall weighted score.
2. Report pre/post normalization deltas and bootstrap CIs.
3. Dashboard shows shrinkage bars side‑by‑side.

---

## Epic 5 Cross‑Judge Calibration & Reports

**Goal:** Compare multiple judges and generate sharable artifacts.

### Story 5.1 Multi‑Judge Runner

**As a** facilitator
**I want** to run the same suite across ≥2 judges
**so that** I can quantify judge dependence.

**Acceptance Criteria**

1. Role override flags for `grader` (e.g., `--model-role grader=provider/model`).
2. Agreement metrics (percent agreement, Cohen’s κ) per bias.

### Story 5.2 Safe Reports & Artifacts

**As a** facilitator
**I want** clean reports
**so that** we can present results safely and clearly.

**Acceptance Criteria**

1. `report.md` + optional `report.html` with all figures/tables.
2. Label‑only mode hides raw text by default; reveal toggle per row.
3. All configs, metrics, and versions saved in `runs/<ts>/`.

---

## Checklist Results Report

> When you’re ready, I can run (or script) a lightweight PM checklist across this PRD and populate this section with a status table. Just say the word and I’ll proceed.

---

## Next Steps

### UX Expert Prompt

> “Using this PRD, design a minimal, accessible **Bias Dashboard** within Inspect’s constraints (or a static HTML report) that emphasizes: (1) Δ from 50% with CIs, (2) pre/post normalization bars, (3) attack rounds line chart, (4) judge‑by‑bias matrix with BRS and agreement. Keep interactions simple and demo‑friendly.”

### Architect Prompt

> “Using this PRD, create a **monolith Python** architecture with Inspect tasks/solvers/scorers, CLI orchestration, and a reporting module. Implement role‑based model configuration, equivalence guard (LLM + heuristic), AutoStyle Attack loop, Style Normalizer, Cross‑Judge Calibration, and reproducible runs with cost guards. Produce a project skeleton and the first runnable baseline task.”

---

### Open Questions / Assumptions to Confirm

* Preferred LLM provider(s) and specific judge/author/rewriter models?
* Hard **time/cost caps** for the workshop environment?
* Desire for custom branding in the HTML report?
* Do we need a CSV import schema for participant‑authored prompts? (Assumed yes.)

If you want, I can now convert this PRD into a starter repository layout and the first Inspect task file so you can run a dry‑run immediately.
