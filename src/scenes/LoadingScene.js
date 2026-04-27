import Phaser from "phaser";

export class LoadingScene extends Phaser.Scene {
  constructor() {
    super("loading");
  }

  preload() {
    this.add.image(640, 360, "loading-screen").setDisplaySize(1280, 720);
    this.add.rectangle(640, 360, 1280, 720, 0x05070a, 0.16);

    this.add
      .rectangle(320, 636, 640, 30, 0x0d1219, 0.92)
      .setOrigin(0, 0.5)
      .setStrokeStyle(4, 0xb99963);

    this.progressFill = this.add
      .rectangle(326, 636, 8, 20, 0xe2b54b, 1)
      .setOrigin(0, 0.5);

    this.percentText = this.add.text(1050, 612, "0%", {
      fontFamily: "Courier New",
      fontSize: "28px",
      color: "#f4ead3",
      fontStyle: "bold",
    });

    this.statusText = this.add.text(78, 614, "Opening the file. Dusting off authority.", {
      fontFamily: "Courier New",
      fontSize: "18px",
      color: "#f4ead3",
    });

    this.spark = this.add.rectangle(320, 636, 12, 30, 0xffefb0, 0.8).setOrigin(0.5, 0.5);
    this.tweens.add({
      targets: this.spark,
      alpha: { from: 0.8, to: 0.2 },
      duration: 500,
      yoyo: true,
      repeat: -1,
    });

    this.load.on("progress", (value) => {
      const width = 628 * value;
      this.progressFill.width = Math.max(8, width);
      this.spark.x = 326 + width;
      this.percentText.setText(`${Math.round(value * 100)}%`);

      if (value < 0.35) {
        this.statusText.setText("Opening the file. Dusting off authority.");
      } else if (value < 0.7) {
        this.statusText.setText("Locating tribunal energy and one usable invoice.");
      } else {
        this.statusText.setText("Preparing admissible nonsense.");
      }
    });

    this.load.image("city-map", "/assets/concepts/tax-lawyer-city-map-v1.png");
    this.load.image("office-bg", "/assets/office/tax-lawyer-office-intake-bg-v1.png");
  }

  create() {
    this.progressFill.width = 628;
    this.spark.x = 954;
    this.percentText.setText("100%");
    this.statusText.setText("Loaded. Entering the city.");

    this.tweens.add({
      targets: this.cameras.main,
      alpha: { from: 1, to: 0 },
      duration: 450,
      delay: 900,
      onComplete: () => {
        this.scene.start("overworld");
      },
    });
  }
}
