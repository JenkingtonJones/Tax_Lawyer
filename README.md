# Tax Lawyer

Retro-satirical legal RPG concept built around tariff classification, VAT edge cases, audits, and absurdly specific administrative disputes.

## Core Pitch

`Tax Lawyer` is a 16-bit-style 2.5D narrative RPG where the player runs a small tax law office, travels across a compact city map, gathers facts from clients and agencies, and then defends a legal position in turn-based "argument battles."

The joke is that the stakes are deadly serious inside the game world, while the actual disputes are things like:

- whether a coffee gift box is a retail set
- whether a dog chew is leather, feed, or dairy
- whether a rotisserie chicken is sold hot
- whether a powder is "of" milk

## World Structure

The overworld is a city map with a few memorable legal-economic districts:

- Your office: intake, research, drafting, stamina recovery
- Government tax office: audits, reassessments, document requests
- Customs house: tariff classification disputes, inspections, import holds
- Tribunal or tax court: boss fights, precedent battles, appeals
- Port warehouses: customs seizures, bonded goods, import mysteries
- Business district: clients, manufacturers, retailers, distributors
- Grocery plaza: VAT/GST fact-pattern missions
- Industrial edge: pet chew plant, gelato powder importer, food processor

## Core Loop

1. Accept client file
2. Travel to locations to gather facts
3. Sort documents and identify missing evidence
4. Choose a legal theory
5. Enter an argument battle against the CRA/CBSA/HMRC analogue
6. Win relief, reduce penalties, or get crushed by technical wording
7. Upgrade office, reputation, research library, and stamina

## Tone

- Dry, smart, slightly sarcastic
- Bureaucratic nonsense treated like epic fantasy lore
- Real legal ambiguity presented as combat mechanics
- Never broad parody; keep the humor rooted in specificity

## Example Cases

- `Retail Set Panic`: canned goods bundle, spaghetti meal, sandwich combo, coffee cup gift box
- `Dog Chew Apocalypse`: bone vs offal vs animal feed vs leather vs dairy import quota
- `Hot Chicken Incident`: whether food was heated for consumption hot or merely sold while hot
- `Meaning Of "Of"`: whether flavored powder is food preparation "of" milk

## Combat Translation

Each battle argument uses three layers:

- Facts: invoices, packaging, ingredient lists, product composition, temperature logs
- Law: tariff headings, interpretive rules, explanatory notes, prior rulings
- Positioning: essential character, intended use, marketing, production method

Possible battle actions:

- `Object`
- `Cite Note`
- `Cross-Examine`
- `Distinguish Case`
- `File Adjustment`
- `Request Extension`
- `Attack Essential Character`
- `Expose Administrative Contradiction`

## Art Direction

- Faux 16-bit pixel art with crisp outlines
- 2.5D/isometric city-map presentation
- Warm office interiors and muted civic exteriors
- Dense visual clutter: paper stacks, filing cabinets, street signs, customs gates
- Retro HUD with score, stamina, risk meter, client count, and active form/code

## First Visual Target

An overworld city-map screen showing:

- the law office as home base
- the government tax office
- customs house near a port or freight yard
- warehouses and storefront clients
- a tribunal building for major encounters
- tiny moving citizens, trucks, and document icons

The map should feel legible as a game board, not just as background art.

## Prototype

The current repository now contains a browser-playable vertical slice built with `Phaser` and `Vite`.

Included scenes:

- overworld city map
- office intake scene
- argument battle scene

Included launch files:

- `Retail Set Panic`
- `Dog Chew Apocalypse`
- `Hot Chicken Incident`

## Run

```bash
npm install
npm run dev
```

Production build:

```bash
npm run build
```

## Project Layout

- `src/main.js`: Phaser bootstrapping
- `src/scenes/BootScene.js`: asset preload
- `src/scenes/OverworldScene.js`: city map and location flow
- `src/scenes/OfficeScene.js`: intake and fact gathering
- `src/scenes/BattleScene.js`: legal-position combat
- `src/data/cases.js`: case writing, office choices, and battle actions
- `src/state/gameState.js`: lightweight campaign state
- `public/assets/concepts/tax-lawyer-city-map-v1.png`: map art used in the prototype

## Engine Choice

`Phaser` is the right choice for this stage because it gets a browser prototype working quickly.

If you want a standalone app later, the migration paths are reasonable:

- wrap the web build with `Electron` for the fastest desktop packaging
- wrap it with `Tauri` for a lighter desktop app
- rebuild in `Godot` later only if you want deeper native-game tooling
