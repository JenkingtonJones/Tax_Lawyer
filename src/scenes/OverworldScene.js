import Phaser from "phaser";
import { gameState } from "../state/gameState.js";
import { addScanlineOverlay, createModal, createPixelButton } from "../ui/pixelUi.js";

const HOTSPOTS = {
  lawOffice: { x: 265, y: 230, w: 210, h: 170, label: "Law Office" },
  taxOffice: { x: 640, y: 205, w: 220, h: 160, label: "Tax Office" },
  customs: { x: 1040, y: 470, w: 230, h: 180, label: "Customs" },
  tribunal: { x: 1100, y: 240, w: 240, h: 180, label: "Tribunal" },
};

export class OverworldScene extends Phaser.Scene {
  constructor() {
    super("overworld");
  }

  create() {
    this.mapImage = this.add.image(640, 360, "city-map").setDisplaySize(1280, 720);
    this.tweens.add({
      targets: this.mapImage,
      y: 354,
      duration: 4500,
      ease: "Sine.easeInOut",
      yoyo: true,
      repeat: -1,
    });

    this.add.rectangle(640, 28, 1280, 56, 0x0f1620, 0.94).setStrokeStyle(3, 0xb99963);
    this.add.rectangle(320, 592, 590, 176, 0x121822, 0.94).setStrokeStyle(3, 0xb99963);
    this.add.rectangle(1088, 592, 304, 176, 0x121822, 0.94).setStrokeStyle(3, 0xb99963);

    this.statusText = this.add
      .text(24, 12, "", {
        fontFamily: "Courier New",
        fontSize: "17px",
        color: "#f7f0d9",
      })
      .setDepth(10);

    this.briefText = this.add
      .text(40, 520, "", {
        fontFamily: "Courier New",
        fontSize: "20px",
        color: "#f7f0d9",
        wordWrap: { width: 550 },
        lineSpacing: 8,
      })
      .setDepth(10);

    this.hintText = this.add
      .text(40, 652, "", {
        fontFamily: "Courier New",
        fontSize: "16px",
        color: "#9ac07a",
        wordWrap: { width: 550 },
      })
      .setDepth(10);

    this.makeSidebar();
    this.addAmbientMotion();
    this.makeHotspots();
    this.makeHelpButton();
    addScanlineOverlay(this, 0.06);
    this.refreshHud("Choose where to work the file.");

    if (!gameState.tutorialDismissed) {
      this.time.delayedCall(350, () => this.showTutorial());
    }

    this.helpKeyHandler = () => this.showTutorial();
    this.input.keyboard.on("keydown-H", this.helpKeyHandler);
    this.events.on("shutdown", () => {
      this.input.keyboard.off("keydown-H", this.helpKeyHandler);
    });
  }

  makeSidebar() {
    this.caseText = this.add.text(960, 522, "", {
      fontFamily: "Courier New",
      fontSize: "18px",
      color: "#f7f0d9",
      wordWrap: { width: 250 },
      lineSpacing: 8,
    });
  }

  addAmbientMotion() {
    this.activeMarker = this.add.container(0, 0).setDepth(40).setVisible(false);
    const ring = this.add.circle(0, 0, 18, 0x000000, 0).setStrokeStyle(4, 0xf0d58a, 1);
    const bubble = this.add.circle(0, -28, 13, 0xce5a46, 0.96).setStrokeStyle(3, 0xf6e9c9);
    const bang = this.add.text(-4, -39, "!", {
      fontFamily: "Courier New",
      fontSize: "18px",
      color: "#fff3d4",
      fontStyle: "bold",
    });
    this.activeMarker.add([ring, bubble, bang]);
    this.tweens.add({
      targets: this.activeMarker,
      y: "-=8",
      duration: 900,
      ease: "Sine.easeInOut",
      yoyo: true,
      repeat: -1,
    });
    this.tweens.add({
      targets: ring,
      scale: 1.18,
      alpha: 0.45,
      duration: 900,
      yoyo: true,
      repeat: -1,
    });

    const routes = [
      {
        points: [
          { x: 94, y: 510 },
          { x: 94, y: 674 },
          { x: 248, y: 674 },
          { x: 248, y: 510 },
        ],
        duration: 2600,
        color: 0xd8d1be,
      },
      {
        points: [
          { x: 885, y: 150 },
          { x: 1180, y: 150 },
          { x: 1180, y: 224 },
          { x: 885, y: 224 },
        ],
        duration: 3200,
        color: 0x6dbf65,
      },
      {
        points: [
          { x: 980, y: 350 },
          { x: 1180, y: 350 },
          { x: 1180, y: 430 },
          { x: 980, y: 430 },
        ],
        duration: 2800,
        color: 0x8fd2ee,
      },
      {
        points: [
          { x: 808, y: 648 },
          { x: 982, y: 648 },
          { x: 982, y: 600 },
          { x: 808, y: 600 },
        ],
        duration: 2600,
        color: 0xd76450,
      },
    ];

    routes.forEach((route, index) => {
      const car = this.createCar(route.points[0].x, route.points[0].y, route.color);
      this.driveRoute(car, route.points, route.duration, index * 450);
    });

    for (let i = 0; i < 4; i += 1) {
      const shimmer = this.add.rectangle(1110 + i * 42, 468 + i * 6, 58, 3, 0xd8eef8, 0.18);
      this.tweens.add({
        targets: shimmer,
        x: shimmer.x + 60,
        alpha: { from: 0.18, to: 0.02 },
        duration: 1500 + i * 150,
        repeat: -1,
        delay: i * 220,
      });
    }
  }

  getActiveLocationKey() {
    if (!gameState.activeCase) {
      return null;
    }

    return gameState.prepared ? gameState.activeCase.targetLocation : "lawOffice";
  }

  createCar(x, y, color) {
    const car = this.add.container(x, y).setDepth(32);
    const shadow = this.add.rectangle(0, 5, 20, 5, 0x000000, 0.2);
    const body = this.add.rectangle(0, 0, 16, 8, color, 1).setStrokeStyle(1, 0x1f232b);
    const roof = this.add.rectangle(0, -1, 8, 4, 0xe8f1f8, 0.85).setStrokeStyle(1, 0x1f232b);
    car.add([shadow, body, roof]);
    return car;
  }

  driveRoute(car, points, duration, initialDelay = 0) {
    const step = (index) => {
      const current = points[index];
      const next = points[(index + 1) % points.length];
      const dx = next.x - current.x;
      const dy = next.y - current.y;
      const distance = Phaser.Math.Distance.Between(current.x, current.y, next.x, next.y);
      const segmentDuration = Math.max(350, (distance / 60) * duration);

      if (Math.abs(dx) > Math.abs(dy)) {
        car.rotation = 0;
      } else {
        car.rotation = Math.PI / 2;
      }

      if (dx < 0 || dy < 0) {
        car.scaleX = -1;
      } else {
        car.scaleX = 1;
      }

      this.tweens.add({
        targets: car,
        x: next.x,
        y: next.y,
        duration: segmentDuration,
        ease: "Linear",
        delay: index === 0 ? initialDelay : 0,
        onComplete: () => step((index + 1) % points.length),
      });
    };

    step(0);
  }

  makeHotspots() {
    Object.entries(HOTSPOTS).forEach(([key, spot]) => {
      const zone = this.add.zone(spot.x, spot.y, spot.w, spot.h).setOrigin(0.5, 0.5);
      zone.setInteractive({ useHandCursor: true });

      zone.on("pointerover", () => {
        this.hintText.setText(`${spot.label}: ${this.describeLocation(key)}`);
      });

      zone.on("pointerout", () => {
        this.hintText.setText(this.defaultHint());
      });

      zone.on("pointerdown", () => {
        if (this.helpModal) {
          return;
        }
        this.handleLocation(key);
      });
    });
  }

  makeHelpButton() {
    this.helpButton = createPixelButton(this, {
      x: 1138,
      y: 7,
      width: 120,
      height: 40,
      label: "HELP",
      fontSize: 20,
      onClick: () => this.showTutorial(),
    });
  }

  showTutorial() {
    if (this.helpModal) {
      return;
    }

    this.helpModal = createModal(this, {
      title: "How To Play",
      body:
        "1. Start at the Law Office when a file is unprepared.\n\n" +
        "2. Pick the least embarrassing intake actions to gather notes.\n\n" +
        "3. Read the active file card to find the correct venue.\n\n" +
        "4. After preparation, go to the target location and argue.\n\n" +
        "5. In battle, actions backed by your notes hit harder.\n\n" +
        "6. Click HELP or press H anytime to reopen this briefing.",
      buttonLabel: "close briefing",
      onClose: () => {
        this.helpModal = null;
        gameState.tutorialDismissed = true;
      },
    });
  }

  describeLocation(key) {
    const activeCase = gameState.activeCase;

    if (!activeCase) {
      return "All current files are complete.";
    }

    if (key === "lawOffice") {
      return "Client intake, document review, and the occasional encounter with causation.";
    }

    if (key === "customs") {
      return "Where everyday products discover hidden tariff destinies.";
    }

    if (key === "taxOffice") {
      return "Audit energy, assessed with confidence and later explained.";
    }

    if (key === "tribunal") {
      return "The place where definitions go to become expensive.";
    }

    return activeCase.summary;
  }

  defaultHint() {
    return "Hover locations for flavor. Click the active destination to proceed.";
  }

  handleLocation(key) {
    const activeCase = gameState.activeCase;

    if (!activeCase) {
      this.refreshHud("All three launch cases are complete. The city briefly respects you.");
      return;
    }

    if (!gameState.prepared) {
      if (key === "lawOffice") {
        this.scene.start("office");
        return;
      }

      this.refreshHud("You need intake, facts, and a defensible position before performing legal theatre in public.");
      return;
    }

    if (key === activeCase.targetLocation) {
      this.scene.start("battle");
      return;
    }

    this.refreshHud(`Wrong venue. This file belongs at ${activeCase.venue}.`);
  }

  refreshHud(message) {
    const activeCase = gameState.activeCase;
    const activeLocationKey = this.getActiveLocationKey();
    const target = !activeCase
      ? "None"
      : gameState.prepared
        ? activeCase.venue
        : "Law Office";

    this.statusText.setText(
      `MONEY $${gameState.money}   STAMINA ${gameState.stamina}/${gameState.maxStamina}   REPUTATION ${gameState.reputation}/5   TARGET ${target.toUpperCase()}`
    );

    if (!activeCase) {
      this.briefText.setText("FILE STATUS\n\nYou have cleared the initial docket. The city pauses to respect you against its better instincts.");
      this.caseText.setText(
        "FILE STATUS\n\nAll launch cases complete.\n\nNatural next build:\n- deeper map interactions\n- more cases\n- persistence\n- sharper battle balance"
      );
      this.hintText.setText(this.defaultHint());
      this.activeMarker.setVisible(false);
      return;
    }

    const coaching = gameState.prepared
      ? activeCase.routeNarration ?? `Take the file to ${activeCase.venue}.`
      : "Start in your office. Listen, read, think, research, then go where the file belongs.";

    this.briefText.setText(`ACTIVE OBJECTIVE\n\n${activeCase.title}\n\n${message}`);
    this.caseText.setText(
      `ACTIVE FILE\n\n${activeCase.title}\nCode: ${activeCase.code}\nRisk: ${activeCase.risk}\nVenue: ${activeCase.venue}\nClient: ${activeCase.client}\n\n${activeCase.summary}`
    );
    this.hintText.setText(coaching);

    if (activeLocationKey) {
      const spot = HOTSPOTS[activeLocationKey];
      this.activeMarker.setPosition(spot.x, spot.y - spot.h / 2 + 22);
      this.activeMarker.setVisible(true);
    } else {
      this.activeMarker.setVisible(false);
    }
  }
}
