import Phaser from "phaser";
import "./style.css";
import { BootScene } from "./scenes/BootScene.js";
import { BattleScene } from "./scenes/BattleScene.js";
import { LoadingScene } from "./scenes/LoadingScene.js";
import { OfficeScene } from "./scenes/OfficeScene.js";
import { OverworldScene } from "./scenes/OverworldScene.js";

const config = {
  type: Phaser.AUTO,
  parent: "app",
  width: 1280,
  height: 720,
  pixelArt: true,
  backgroundColor: "#111317",
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
  scene: [BootScene, LoadingScene, OverworldScene, OfficeScene, BattleScene],
};

new Phaser.Game(config);
