# Task 2 Run Note

Open the folder `tax-lawyer-game` in Godot 4.

Main scene:
`res://scenes/HomeGrid.tscn`

Controls:
- Arrow keys: move the player around the home grid map.
- Press E near the Tax Office marker to enter the street scene.
- Press E near the Law Office marker to enter office intake after an appointment is unlocked.
- In the street scene, left/right arrows move the player along the sidewalk.
- Space or Up: jump.
- E: talk to the elderly client when the prompt appears.
- Click `Accept receipts` or `CRA guidance`, or press 2 or 3, to resolve the street dialogue and then press E to return to the home grid.
- Click `Missing docs`, or press 1, to start the multi-step missing-documents dialogue. Then click or press 1, 2, or 3 through the facilitator prompts until the appointment result appears.
- Press E on the appointment result to return to the home grid map.
- In the office, press or click 1, 2, and 3 to complete the intake tasks, then press E to return to the home grid.
- After a choice result appears, press E again to close the dialogue and return control to the player.

Assembly notes:
- The street background matched the `1280x720` aspect ratio when scaled from `1672x941`.
- Player and elderly client animation frames were already on consistent `362x362` transparent canvases.
- UI panel assets are usable, but the generated HUD bars are very large; they were scaled down in-scene rather than reprocessed.
- The elderly client worried animation uses the processed third-row frames named `client_elderly_worried_*.png`.
- Local verification note: the project opens headlessly in Godot `4.6.2.stable` without parser errors.

Interaction test:
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

Text layout test:
1. Confirm the initial elderly client line wraps inside the dialogue panel.
2. Confirm each result line remains inside the dialogue panel.
3. Confirm the visible choice labels fit inside the choice panel as "Missing docs", "Accept receipts", and "CRA guidance".
4. Confirm no dialogue or choice text touches the panel border.
5. Confirm the longest CRA guidance result uses smaller text but remains readable.
