# Asset Extraction Report

Processed asset folder:
`tax-lawyer-game/assets/processed`

Contact sheet:
`tax-lawyer-game/assets/contact_sheet_preview.png`

Manual cleanup notes:
- Player frames: magenta removed and frames re-centered on a shared `362x362` canvas. `player_walk_03` needed cleanup because the original sheet crop included a sliver from the neighboring frame.
- Elderly client frames: source sheet spacing was not an exact integer grid, so frames were extracted by detected sprite bounds and placed on a shared `362x362` canvas to keep the baseline stable.
- UI panels: cropped individually from the panel sheet with transparent padding.
- Icons: cropped individually from the icon sheet with transparent padding.
- Background: kept as one full image, unchanged except for copying into the processed background folder.

No gameplay, scenes, movement, or interaction logic were created as part of this extraction pass.
