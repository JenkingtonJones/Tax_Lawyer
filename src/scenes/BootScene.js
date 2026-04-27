import Phaser from "phaser";

export class BootScene extends Phaser.Scene {
  constructor() {
    super("boot");
  }

  preload() {
    this.load.image("loading-screen", "/assets/loading/tax-lawyer-loading-screen-v1.png");
  }

  create() {
    this.scene.start("loading");
  }
}
