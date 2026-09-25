# Task 2 Run Note

Open the folder `tax-lawyer-game` in Godot 4.

Main scene:
`res://scenes/HomeGrid.tscn`

Controls:
- Arrow keys: move the player around the home grid map.
- Follow the single gold `NEXT` marker; only the location required by the current story stage is interactive.
- Press E near the Tax Office marker to enter the street scene.
- Press E near the Law Office marker to enter office intake, or the CRA phone call when the CRA guidance quest is active.
- Press E near the Gelato Labs marker after a successful CRA call to meet the CRA representative.
- After the CRA guidance delivery, return to Gelato Labs to begin the `Meaning of "Of"` case.
- Press E near Import Warehouse and the Tribunal when those locations unlock.
- After the Tribunal decision, follow the Law Office marker, file the result, and start the next workday. Score, escrow, risk, and completed-client totals carry forward.
- In the street, Gelato Labs, powder lab, warehouse, and Tribunal scenes, left/right arrows move the player through the side-view room.
- Space or Up: jump.
- E: talk to the elderly client or Agent Ledger when the prompt appears.
- Click `Accept receipts`, or press 2, to resolve the street dialogue and then press E to return to the home grid.
- Click `CRA guidance`, or press 3, to start the CRA guidance quest. This does not resolve the client immediately.
- If `Missing docs` or `Accept receipts` is chosen instead, finish the three Law Office intake tasks. The map then highlights the Tax Office for a receipt-review appointment, which connects the branch to the CRA guidance call.
- Click `Missing docs`, or press 1, to start the multi-step missing-documents dialogue. Then click or press 1, 2, or 3 through the facilitator prompts until the appointment result appears.
- Press E on the appointment result to return to the home grid map.
- In the office, press or click 1, 2, and 3 to complete the intake tasks, then press E to return to the home grid.
- In the CRA phone call, press or click 1, 2, and 3 to answer each CRA verification question. Too many wrong answers disconnect the call and send the player back to the map.
- In Gelato Labs, walk to Agent Ledger and press E to begin the meeting. The correct meeting answer schedules the guidance appointment.
- In the powder lab and warehouse, walk to each evidence station and press E. Correctly resolve all three stations, then return to the scene's NPC.
- At the Tribunal, walk to counsel table, press E, and answer the three argument questions.
- After a choice result appears, press E again to close the dialogue and return control to the player.

Assembly notes:
- The street background matched the `1280x720` aspect ratio when scaled from `1672x941`.
- The Gelato Labs background also uses a `1672x941` source image and is scaled in-scene to the same 16:9 viewport.
- The powder lab, Import Warehouse, and Tribunal backgrounds use generated `1672x941` source images with open lower-third walk lanes.
- Player and elderly client animation frames were already on consistent `362x362` transparent canvases.
- Agent Ledger is a generated transparent PNG placed as a static NPC with an interaction area.
- Dr. Mirella Affogato, Martin Manifest, and Member Vale are generated transparent NPC sprites.
- The home map uses `bg_city_map_walkable.png`, a clean orthogonal-road background without baked labels, HUD elements, action icons, or characters.
- Collision polygons sit conservatively inside visible buildings, fences, and water. Open pavement and plazas have no hidden blockers, and the player uses a small foot collider.
- The live map HUD shows score, escrow balance, coffee level, risk, clients, active file, next action, and destination. Narrative milestones add score.
- Only the current narrative destination receives a marker and interaction prompt.
- The quest loop never ends on an empty map: Tribunal completion creates a Law Office filing objective, and filing creates the next Tax Office objective.
- Completing receipt intake also cannot end on an empty map: it creates a Tax Office follow-up objective, and that conversation creates the Law Office CRA-call objective.
- The elderly client worried animation uses the processed third-row frames named `client_elderly_worried_*.png`.
- Local verification note: all scenes load in Godot `4.6.2.stable`; `tests/meaning_of_quest_smoke.gd` covers quest progression, visible-road probes, destination ordering, marker visibility, and map reachability.

Missing-docs interaction test:
1. On the home grid, walk to the Tax Office marker and press E.
2. Walk to the elderly client.
3. Press Space or Up while moving to confirm the player jumps and uses the walk animation in the air.
4. Confirm the player can clear the elderly client without changing the interaction outcome.
5. Press E to open the first dialogue.
6. Select `Missing docs` by clicking it or pressing 1.
7. Confirm the story line appears and the choices change to facilitator prompts.
8. Click or press 1, 2, or 3 through the facilitator prompts until the appointment result replaces the choices.
9. Press E to return to the home grid.
10. Walk to the Law Office marker and press E.
11. Complete the three office intake tasks.
12. Press E to return to the home grid.

CRA guidance quest test:
1. On the home grid, walk to the Tax Office marker and press E.
2. Walk to the elderly client and press E.
3. Select `CRA guidance` by clicking it or pressing 3.
4. Confirm the original CRA guidance explanation appears first.
5. Press E through the follow-up pages until the map opens.
6. Walk to the Law Office marker and press E.
7. Confirm the CRA call scene opens with the office background and question HUD.
8. Answer the five CRA questions. Correct answer positions are 2, 3, 1, 3, and 2.
9. Confirm the successful call sends the player back to the map and unlocks Gelato Labs.
10. Walk to the Gelato Labs marker and press E.
11. Confirm the lawyer can move left/right, jump, and walk to Agent Ledger before dialogue starts.
12. Press E near Agent Ledger and choose `Confirm the client needs pre-filing guidance`.
13. Confirm the meeting schedules guidance and sends the player back to the map.
14. Return to the Tax Office street, talk to the elderly client, and confirm the client is completed after the guidance delivery.

Meaning of "Of" quest test:
1. Continue through the new courier pages after delivering the CRA guidance to the elderly client.
2. On the map, confirm the objective points to Gelato Labs and walk there rather than switching scenes automatically.
3. Enter Gelato Labs and confirm the powder-lab background and Dr. Affogato appear.
4. Walk to all three evidence stations. Correct answers are 2 for the ingredient sample, 1 for the production record, and 3 for intended use.
5. Return to Dr. Affogato after collecting all three facts and confirm Import Warehouse unlocks.
6. Walk to Import Warehouse on the map and enter it.
7. Inspect all three warehouse stations. Correct answers are 3 for the invoice, 2 for the pallet label, and 1 for the mixing sheet.
8. Return to Martin Manifest and confirm the Tribunal unlocks.
9. Walk to the Tribunal, enter, and approach counsel table before pressing E.
10. Answer the three argument rounds in order: 2, 1, 3.
11. Confirm the decision awards $260, reduces audit risk by 12, and adds one completed client matter.
12. Confirm a wrong evidence answer costs stamina without completing the station, while a wrong Tribunal answer also increases audit risk and repeats the same round.

Text layout test:
1. Confirm the initial elderly client line wraps inside the dialogue panel.
2. Confirm each result line remains inside the dialogue panel.
3. Confirm the visible choice labels fit inside the choice panel as "Missing docs", "Accept receipts", and "CRA guidance".
4. Confirm no dialogue or choice text touches the panel border.
5. Confirm the CRA call choices fit inside the widened choice panel.
6. Confirm the Gelato Labs meeting choices fit inside the widened choice panel.
7. Confirm all powder-lab, warehouse, and Tribunal choices fit on one line without touching the panel border.
