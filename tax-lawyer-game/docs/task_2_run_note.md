# Task 2 Run Note

Open the folder `tax-lawyer-game` in Godot 4.

Main scene:
`res://scenes/HomeGrid.tscn`

Controls:
- Arrow keys: move the player around the home grid map.
- Press E near the Tax Office marker to enter the street scene.
- Press E near the Law Office marker to enter office intake, or the CRA phone call when the CRA guidance quest is active.
- Press E near the Gelato Labs marker after a successful CRA call to meet the CRA representative.
- In the street scene and Gelato Labs, left/right arrows move the player through the side-view room.
- Space or Up: jump.
- E: talk to the elderly client or Agent Ledger when the prompt appears.
- Click `Accept receipts`, or press 2, to resolve the street dialogue and then press E to return to the home grid.
- Click `CRA guidance`, or press 3, to start the CRA guidance quest. This does not resolve the client immediately.
- Click `Missing docs`, or press 1, to start the multi-step missing-documents dialogue. Then click or press 1, 2, or 3 through the facilitator prompts until the appointment result appears.
- Press E on the appointment result to return to the home grid map.
- In the office, press or click 1, 2, and 3 to complete the intake tasks, then press E to return to the home grid.
- In the CRA phone call, press or click 1, 2, and 3 to answer each CRA verification question. Too many wrong answers disconnect the call and send the player back to the map.
- In Gelato Labs, walk to Agent Ledger and press E to begin the meeting. The correct meeting answer schedules the guidance appointment.
- After a choice result appears, press E again to close the dialogue and return control to the player.

Assembly notes:
- The street background matched the `1280x720` aspect ratio when scaled from `1672x941`.
- The Gelato Labs background also uses a `1672x941` source image and is scaled in-scene to the same 16:9 viewport.
- Player and elderly client animation frames were already on consistent `362x362` transparent canvases.
- Agent Ledger is a generated transparent PNG placed as a static NPC with an interaction area.
- UI panel assets are usable, but the generated HUD bars are very large; they were scaled down in-scene rather than reprocessed.
- The elderly client worried animation uses the processed third-row frames named `client_elderly_worried_*.png`.
- Local verification note: the project opens headlessly in Godot `4.6.2.stable` without parser errors.

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

Text layout test:
1. Confirm the initial elderly client line wraps inside the dialogue panel.
2. Confirm each result line remains inside the dialogue panel.
3. Confirm the visible choice labels fit inside the choice panel as "Missing docs", "Accept receipts", and "CRA guidance".
4. Confirm no dialogue or choice text touches the panel border.
5. Confirm the CRA call choices fit inside the widened choice panel.
6. Confirm the Gelato Labs meeting choices fit inside the widened choice panel.
