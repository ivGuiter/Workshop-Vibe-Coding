# ThreeMon Product Requirements Document (PRD)

## Goals and Background Context

### Goals

* Deliver a **playable, browser‑based, Pokémon‑like** (“creature collector”) RPG using **three.js** that runs entirely **client‑side** with **no backend**.
* Support **GitHub Codespaces** for development and demo; publish as a static site (e.g., **GitHub Pages**) for a stable URL.
* Ship an **MVP vertical slice**: one town + one route + encounter grass + trainer battle + capture + party/inventory + save/load.
* Achieve **60 FPS desktop** and **30–60 FPS on mid‑range mobile**, with an **initial download budget < 80 MB** (code + assets).
* Provide **offline play** via **PWA**, **save data** via **IndexedDB**, and **lazy‑load** large content.
* Establish a **repeatable asset pipeline** (Blender → glTF + Draco + KTX2) to scale maps/creatures/moves efficiently.
* Ensure **legal safety** with original IP (names, creatures, logos, UI), distinct from Pokémon.
* Implement **basic accessibility** (keyboard navigation, readable text, color‑contrast targets) and **controller support** (Gamepad API).
* Set up **CI/CD** to build, test, and deploy on each main branch merge.

### Background Context

A Pokémon‑style RPG is highly feasible in the browser. **three.js** provides rendering; web platform APIs cover storage (IndexedDB), offline (service workers), controllers (Gamepad), and performance features (InstancedMesh, Web Workers/OffscreenCanvas). The primary challenge is **content scale**, not engine capability. A carefully scoped MVP with compressed assets (Draco geometry, KTX2 textures) and scene separation (overworld vs. battle) enables strong performance, mobile viability, and quick iteration. **Codespaces** supplies a dev machine and HTTPS preview URL, so the entire game can run client‑only without backend services; production can be a static deploy.

### Change Log

| Date       | Version | Description                                       | Author              |
| ---------- | ------- | ------------------------------------------------- | ------------------- |
| 2025-10-03 | 0.1     | Initial draft PRD based on feasibility discussion | GPT-5 Pro (ChatGPT) |

---

## Requirements

### Functional (FR)

* **FR1:** The game shall render a **top‑down overworld** scene in three.js with player movement, collision, and camera follow.
* **FR2:** The game shall support **encounter regions** (e.g., tall grass) that trigger a **separate battle scene**.
* **FR3:** The battle system shall implement a **turn‑based loop**: initiative/turn order, move selection, damage, status effects, win/lose states.
* **FR4:** The game shall include a **capture mechanic** with configurable probabilities and outcomes.
* **FR5:** The player shall be able to manage a **party** (add/remove/swap creatures), each with stats, level, and moves.
* **FR6:** The game shall provide **inventory management** (items, capture or healing items) with usage effects.
* **FR7:** The game shall provide a **dialogue system** for NPCs, signs, and events (advance via input).
* **FR8:** The game shall include at least **one NPC trainer battle** with simple AI (scripted move choices acceptable for MVP).
* **FR9:** All domain data (**creatures, moves, types, items, maps**) shall be **data‑driven** via JSON/TypeScript tables.
* **FR10:** The game shall implement **save/load** to **IndexedDB** (auto‑save on scene transitions + manual save in menu).
* **FR11:** The application shall install as a **PWA** and be **fully playable offline** after first load.
* **FR12:** The asset pipeline shall load **glTF/GLB** models with **Draco** geometry compression and **KTX2** texture compression.
* **FR13:** The renderer shall **lazy‑load** the **battle scene** and any large asset groups on first use.
* **FR14:** The overworld shall support **grid‑based movement** and/or a **navmesh** for NPCs.
* **FR15:** The UI shall include **title screen**, **overworld HUD**, **battle UI**, **party**, **bag**, **settings**, and **save/load** screens.
* **FR16:** The game shall support **keyboard**, **touch**, and **gamepad** input (via the **Gamepad API**).
* **FR17:** The app shall show **in‑scene text** (damage popups/status) and readable labels (e.g., **troika‑three‑text**).
* **FR18:** The build shall run in **GitHub Codespaces** using a dev server (e.g., **Vite**), with working preview URLs.
* **FR19:** The production build shall be deployable to a **static host** (e.g., GitHub Pages) with a **service worker**.
* **FR20:** The app shall provide an **options/settings** menu (audio volume, text speed, performance preset).
* **FR21:** The app shall include a **basic “data export/import”** (JSON) for save portability across changing dev URLs.
* **FR22:** The game shall include a **debug overlay** (FPS, draw calls, memory, scene toggles) for developers.
* **FR23:** The game shall provide **basic analytics hooks** that store only locally (no network/beacons) for session stats.
* **FR24:** The app shall display a **legal/about** screen clarifying original IP and third‑party licenses.

### Non‑Functional (NFR)

* **NFR1:** **Client‑only architecture**: No backend required for core gameplay; all features must function offline once installed.
* **NFR2:** **Performance targets**: 60 FPS on desktop GPUs and 30–60 FPS on mid‑range mobile under target scenes.
* **NFR3:** **Download budget**: < 80 MB initial (app + core assets); subsequent areas/assets lazy‑loaded.
* **NFR4:** **Memory budget**: Aim for < 500 MB total GPU memory on desktop, < 350 MB on mid‑range mobile at peak.
* **NFR5:** **Draw call budget**: Keep typical overworld frames ≤ 500 draw calls via instancing/batching; battle scenes ≤ 300.
* **NFR6:** **Browser support**: Latest Chrome, Edge, Firefox, Safari on desktop/mobile; graceful degradation for older browsers (e.g., reduced effects).
* **NFR7:** **Accessibility**: Target **WCAG AA** for contrast and text size; all core actions accessible via keyboard.
* **NFR8:** **Security/Privacy**: No PII collection. Saves stored locally (IndexedDB). No trackers by default.
* **NFR9:** **Legal/IP**: All names, art, creatures, logos, and story **must be original** and non‑infringing.
* **NFR10:** **Stability**: App should recover from failed asset loads (retry/fallback) and corrupted saves (rollback/backup).
* **NFR11:** **Internationalization‑ready**: Text externalized to resource files; support left‑to‑right languages in MVP.
* **NFR12:** **Build & CI**: Deterministic builds; CI enforces type checks, linting, unit tests, and PWA validation.
* **NFR13:** **Code quality**: TypeScript + ESLint + Prettier; module boundaries for rendering, data, systems, and UI.
* **NFR14:** **Scalability**: Asset pipeline (glTF/Draco/KTX2) and streaming designed to scale to 50–150 creatures.

---

## User Interface Design Goals

> **Assumptions made.** Where information was missing, choices below are educated defaults to enable the UX/Design track to proceed. Replace with brand/style direction when available.

### Overall UX Vision

A **clean, readable, low‑poly 2.5D** aesthetic that evokes classic monster‑collectors without imitating them. Minimalist HUD overlays, **orthographic** camera in overworld, **cinematic cut‑in** for battles. Prioritize clarity (readable text, color‑blind‑safe type chart cues) and **fast menus** (1–2 inputs to reach common actions).

### Key Interaction Paradigms

* **Overworld:** Directional movement, context interact, encounter triggers, NPC talks, sign reads.
* **Battle:** Turn queue → move/item/switch/capture → result popups → end state → return to overworld.
* **Menus:** Diegetic pause → party, bag, settings, save/load. Quick swap and confirm dialogs.
* **Input:** Keyboard (WASD/Arrows + Enter/Esc), Touch (virtual D‑pad + tap), Gamepad (A/B/X/Y + Start).

### Core Screens and Views

* Title & Continue
* Overworld (HUD: party lead, currency, mini prompts)
* Battle (creature panels, moves list, log, VFX)
* Party Management
* Bag/Items
* Dialogue/Interaction Overlay
* Settings (audio, text speed, performance preset)
* Save/Load & Data Export/Import
* Legal/About

### Accessibility: **WCAG AA**

* Minimum 14–16 px base UI text, scalable in settings.
* Color‑blind‑aware type effectiveness indicators (icon + text, not color alone).
* All actions reachable via keyboard; focus outlines visible.

### Branding

* **Original IP**: unique game name, creature designs, UI motifs, and iconography.
* Visual direction: **soft‑shaded low‑poly** environments; flat‑colored, stylized creatures; subtle screen‑space effects only.

### Target Device and Platforms: **Web Responsive**

* Desktop and mobile browsers; installable PWA.

---

## Technical Assumptions

### Repository Structure: **Monorepo**

* Single repo with `/game` (client), `/tools` (asset pipeline, scripts), `/docs`.
* Rationale: keeps assets, pipeline, and client in sync; simplifies CI.

### Service Architecture

* **Static client‑only “monolith”** (Vite + TypeScript + three.js).
* No backend services. Optional later: add lightweight functions for leaderboards/trading.

### Testing Requirements

* **Unit + Integration + Light E2E**:

  * Unit: data parsers, battle math, save/load adapters.
  * Integration: scene transitions, resource loading, IndexedDB guards.
  * E2E: smoke via Playwright (title → battle → capture → save → reload).

### Additional Technical Assumptions and Requests

* **Languages/Frameworks:** TypeScript, Vite, three.js, troika‑three‑text.
* **Navigation:** Grid (PathFinding.js) and/or navmesh (three‑pathfinding) for NPCs.
* **AI:** Minimal FSM; optionally Yuka for steering/pursuit.
* **Asset pipeline:** Blender → glTF/GLB → **Draco** + **KTX2** via `gltf-transform` CLI.
* **Rendering:** WebGL via three.js; use `InstancedMesh` for repeated props; PMREM for IBL.
* **Storage:** IndexedDB (persisted if available); structured save schema + versioning.
* **Offline:** `vite-plugin-pwa` + Workbox runtime caching; SW scope at `/`.
* **Controllers:** Gamepad API; input abstraction layer for keyboard/touch/pad.
* **Performance extras:** Optional OffscreenCanvas/Web Worker path (progressive enhancement).
* **Deployment:** GitHub Pages (static) with CI artifact publishing; Codespaces dev server for previews.
* **Large assets:** Git LFS; content hash filenames; HTTP range requests supported by host.
* **Security headers (dev):** COOP/COEP for shared array buffers when needed.

---

## Epic List

1. **Foundation & CI/CD:** Scaffold project, rendering canary scene, type/lint/test, PWA shell, CI deploy to static host.
2. **Overworld Core:** Player movement, collision, camera, encounter regions, basic NPC dialogue.
3. **Battle Loop MVP:** Separate battle scene, turn system, moves, damage/status, victory/defeat.
4. **Data & Saves:** Data tables (creatures/moves/types/items/maps), IndexedDB save/load, schema versioning.
5. **Content Vertical Slice:** Town + Route + trainer battle + capture + party/bag menus.
6. **PWA & Offline:** Service worker caching, install prompt, offline validation, data export/import.
7. **Performance & Mobile:** Instancing, compression, lazy loading, performance presets, mobile QA.
8. **Branding & Legal:** Original IP assets, logos, icons, credits/licenses, legal/about screen.

> Rationale: Each epic is deployable and builds logically on previous foundations while delivering user‑visible value.

---

## Epic 1 — Foundation & Core Infrastructure

**Goal:** Establish the project skeleton and continuous delivery. Deliver a running canary (title → canary 3D scene) with PWA shell so stakeholders can install and test on devices.

### Story 1.1 — Project Scaffold & Hello Three.js

**As a** developer, **I want** a Vite + TypeScript + three.js app with a minimal scene, **so that** we can render and iterate quickly.

**Acceptance Criteria**
1: Repo initialized with Vite TS template; three.js added; `npm run dev` works.
2: Renders a cube and FPS meter; responsive canvas.
3: Linting (ESLint) and Prettier configured; CI lints on push.
4: README with setup instructions (local, Codespaces).

### Story 1.2 — PWA Shell

**As a** player, **I want** to install the game as an app, **so that** I can play offline after first load.

**Acceptance Criteria**
1: Service worker registered with `vite-plugin-pwa`.
2: Manifest includes name, icons, start_url `/`, display `standalone`.
3: Offline fallback screen appears if network missing before first cache.
4: Lighthouse PWA checks pass (installable).

### Story 1.3 — CI/CD to Static Hosting

**As a** maintainer, **I want** automatic builds and deploys, **so that** main branch updates go live.

**Acceptance Criteria**
1: GitHub Actions workflow builds, runs type/lint/tests, uploads artifacts.
2: Successful merges deploy to GitHub Pages (or configured static host).
3: Cache‑busting file names; SW updates on new deploy (autoUpdate).

---

## Epic 2 — Overworld Core

**Goal:** Provide a controllable player in a small map, with collisions, camera follow, and encounter triggers; enable basic NPC dialogue.

### Story 2.1 — Map Loading & Collision

**As a** player, **I want** to walk around a small map, **so that** I can explore.

**Acceptance Criteria**
1: Test map loads (GLB or tile JSON).
2: Player sprite/model moves; collisions prevent walking through blocked tiles.
3: Camera follows player with clamp to map bounds.

### Story 2.2 — Encounter Regions

**As a** player, **I want** random battles in designated areas, **so that** exploration is meaningful.

**Acceptance Criteria**
1: Entering “grass” region starts an encounter via probability check.
2: Transition to battle scene stub (loading screen ok).
3: Return to overworld after dummy battle.

### Story 2.3 — NPC Dialogue

**As a** player, **I want** to talk to NPCs, **so that** I can receive hints or flavor text.

**Acceptance Criteria**
1: Interact prompt on proximity; dialogue box with paging.
2: Dialogue data externalized; keyboard/touch/gamepad advances.
3: Simple branching (e.g., yes/no).

---

## Epic 3 — Battle Loop MVP

**Goal:** Deliver a fully functional turn‑based battle with moves, damage, status, and outcomes; swap back to overworld on completion.

### Story 3.1 — Turn System & Moves

**As a** player, **I want** to choose moves and see turn results, **so that** battles are strategic.

**Acceptance Criteria**
1: Initiative determines action order.
2: 4‑move list per creature; move metadata from data tables.
3: Damage calculation implemented with type effectiveness.

### Story 3.2 — Status Effects & End States

**As a** player, **I want** statuses (e.g., poison/sleep) and clear victory/defeat, **so that** battles feel complete.

**Acceptance Criteria**
1: At least two status effects impact turns.
2: Victory/defeat conditions and rewards.
3: Transition back to overworld on end.

### Story 3.3 — Capture Mechanic

**As a** player, **I want** to capture creatures, **so that** I can build a party.

**Acceptance Criteria**
1: Capture item triggers probability check with HP/status modifiers.
2: Success adds creature to party/box; failure resumes battle.
3: UI feedback (shake/animations, text).

---

## Epic 4 — Data & Saves

**Goal:** Centralize game data and implement robust save/load with schema versioning.

### Story 4.1 — Data Tables

**As a** designer, **I want** data‑driven creatures/moves/types/items, **so that** balancing is easy.

**Acceptance Criteria**
1: JSON/TS schemas and validation.
2: Sample dataset (10 creatures, 20 moves, type chart).
3: Loader caches and exposes data to systems.

### Story 4.2 — IndexedDB Save/Load

**As a** player, **I want** my progress saved, **so that** I can continue later.

**Acceptance Criteria**
1: Auto‑save on transitions; manual save in menu.
2: Versioned saves; migration path for minor schema changes.
3: Corruption handling with last‑known‑good fallback.

### Story 4.3 — Save Export/Import

**As a** developer/player, **I want** to export/import saves, **so that** I can move between dev URLs.

**Acceptance Criteria**
1: Export to JSON file; import validates schema.
2: Import merges or replaces current slot; confirmation dialog.
3: Errors surface actionable messages.

---

## Epic 5 — Content Vertical Slice

**Goal:** Ship a small but complete experience: one town, one route, one trainer battle, one wild capture, party/bag menus.

### Story 5.1 — Town & Route Content

**As a** player, **I want** one town and one route, **so that** I can experience exploration and encounters.

**Acceptance Criteria**
1: Town scene with 2–3 NPCs and a signboard.
2: Route scene with encounter grass and a trainer.
3: Transitions between scenes.

### Story 5.2 — Party & Bag Menus

**As a** player, **I want** to manage party and items, **so that** I can prepare for battles.

**Acceptance Criteria**
1: Party screen (order, inspect, swap).
2: Bag screen (use items in/out of battle where valid).
3: Input works across keyboard/touch/gamepad.

---

## Epic 6 — PWA & Offline

**Goal:** Ensure installability and fully offline play after first load; finalize caching strategy.

### Story 6.1 — Caching Strategy

**As a** player, **I want** fast loads offline, **so that** I can play anywhere.

**Acceptance Criteria**
1: Precache core shell; runtime cache assets/maps with versioning.
2: Update flow: new deploy triggers SW update after tab reload.
3: Offline smoke test: new session without network succeeds.

### Story 6.2 — Install & UX Polish

**As a** player, **I want** a good install experience, **so that** the app feels native.

**Acceptance Criteria**
1: App icons/splash; masked icon.
2: “Install” hint (non‑intrusive).
3: About/legal tab with licenses.

---

## Epic 7 — Performance & Mobile

**Goal:** Hit performance targets, optimize for mobile devices, and reduce bundle sizes.

### Story 7.1 — Asset Compression & Streaming

**As a** developer, **I want** Draco/KTX2 assets, **so that** downloads and memory stay low.

**Acceptance Criteria**
1: Transcoder/decoder paths set; assets compressed.
2: Lazy‑load the battle scene on first use.
3: Initial bundle size metrics captured (< 80 MB total).

### Story 7.2 — Instancing & Presets

**As a** player, **I want** smooth performance, **so that** gameplay is responsive.

**Acceptance Criteria**
1: Instanced meshes for repeated props (trees/grass).
2: Performance presets (low/med/high) adjust shadows, FOV, post.
3: Mobile QA on iOS/Android mid‑range devices.

---

## Epic 8 — Branding & Legal

**Goal:** Finalize original branding, verify legal safety, and ship credits/licenses.

### Story 8.1 — Brand & Icons

**As a** stakeholder, **I want** unique brand assets, **so that** the game identity is clear and non‑infringing.

**Acceptance Criteria**
1: App name, logo, icons, wordmark delivered.
2: In‑game title and iconography updated.
3: Brand kit checked into `/assets/brand`.

### Story 8.2 — Legal/About

**As a** player, **I want** transparency, **so that** I understand IP and licenses.

**Acceptance Criteria**
1: “About” screen lists licenses and attributions.
2: Clear statement of original IP (not affiliated with Pokémon/Nintendo).
3: Third‑party license files included in build.

---

## Checklist Results Report

*Ready to run PM checklist once you confirm this PRD is the desired baseline. This section will capture the checklist output and any remediation items.*

---

## Next Steps

### UX Expert Prompt

> Using this PRD as your input, propose a **concept UX** for a low‑poly, top‑down three.js creature‑collector with separate battle scenes. Deliver wireframes for: Title/Continue, Overworld HUD, Battle UI (moves/log/status), Party, Bag, Settings, Save/Load. Call out accessibility (WCAG AA), touch/gamepad affordances, and a motion system for transitions that preserves clarity on mobile.

### Architect Prompt

> Using this PRD as your input, produce a **technical architecture** for a client‑only, PWA‑ready three.js game. Specify module boundaries (renderer/world/battle/data/systems/ui), asset pipeline (Blender → glTF + Draco + KTX2 with gltf‑transform), loading strategy (lazy‑load battle), IndexedDB schema with versioning/migrations, Codespaces dev setup, CI/CD to GitHub Pages, and testing pyramid (unit/integration/E2E). Include performance budgets and a plan for instancing and mobile presets.

---

**Appendix: Constraints & Notes**

* **Codespaces:** Preview URL may change (origin change → IndexedDB scope). Use export/import saves during dev; deploy to a stable domain for persistent saves.
* **Audio policy:** Gate audio start behind a user gesture (“Tap to Start”).
* **Future work (post‑MVP):** Online trading/leaderboards (requires backend), expanded roster/maps, cutscenes, WebGPU path once stable.
