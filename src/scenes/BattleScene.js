import Phaser from "phaser";
import { ACTION_LIBRARY } from "../data/cases.js";
import { gameState } from "../state/gameState.js";
import { addScanlineOverlay, createPixelButton } from "../ui/pixelUi.js";

export class BattleScene extends Phaser.Scene {
  constructor() {
    super("battle");
  }

  create() {
    this.caseFile = gameState.activeCase;
    this.turn = 0;
    this.position = 8;
    this.credibility = Math.max(4, gameState.stamina + 1);
    this.bureaucracy = 7;

    this.drawRoom();
    this.refreshHud(this.caseFile.battleIntro);
    addScanlineOverlay(this, 0.05);
  }

  drawRoom() {
    this.cameras.main.setBackgroundColor("#1a1e26");

    this.add.rectangle(640, 42, 1280, 84, 0x10151d).setStrokeStyle(3, 0xb99963);
    this.add.rectangle(640, 210, 1280, 260, 0x262d38);
    this.add.rectangle(640, 382, 1280, 190, 0x313846);
    this.add.rectangle(640, 510, 1200, 110, 0x10151d, 0.95).setStrokeStyle(3, 0xb99963);
    this.add.rectangle(640, 644, 1200, 112, 0x10151d, 0.95).setStrokeStyle(3, 0xb99963);

    this.playerAvatar = this.add.rectangle(250, 230, 220, 260, 0x6d4c36).setStrokeStyle(4, 0xc29d67);
    this.playerFace = this.add.rectangle(250, 260, 120, 120, 0xe4caa6).setStrokeStyle(4, 0x402a19);
    this.venueAvatar = this.add.rectangle(1030, 230, 220, 260, 0x55606f).setStrokeStyle(4, 0xc29d67);
    this.venueFace = this.add.rectangle(1030, 260, 120, 120, 0xd8d2c0).setStrokeStyle(4, 0x323845);

    this.tweens.add({
      targets: [this.playerAvatar, this.playerFace],
      y: "-=5",
      duration: 1300,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });
    this.tweens.add({
      targets: [this.venueAvatar, this.venueFace],
      y: "-=5",
      duration: 1450,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });

    this.add.text(154, 90, "YOU", {
      fontFamily: "Courier New",
      fontSize: "20px",
      color: "#f4ead3",
    });
    this.add.text(910, 90, this.caseFile.venue.toUpperCase(), {
      fontFamily: "Courier New",
      fontSize: "20px",
      color: "#f4ead3",
    });

    this.add.text(34, 20, `ARGUMENT BATTLE :: ${this.caseFile.title}`, {
      fontFamily: "Courier New",
      fontSize: "28px",
      color: "#f4ead3",
      fontStyle: "bold",
    });

    this.logText = this.add.text(60, 440, "", {
      fontFamily: "Courier New",
      fontSize: "18px",
      color: "#f4ead3",
      wordWrap: { width: 1120 },
      lineSpacing: 8,
    });

    this.statText = this.add.text(60, 110, "", {
      fontFamily: "Courier New",
      fontSize: "20px",
      color: "#f4ead3",
      lineSpacing: 8,
    });

    this.buttonObjects = [];
    this.objectionFlash = this.add
      .text(900, 596, "OBJECTION", {
        fontFamily: "Courier New",
        fontSize: "22px",
        color: "#e97f61",
        fontStyle: "bold",
      })
      .setAlpha(0);
    this.makeButtons();
  }

  makeButtons() {
    this.caseFile.battleActions.forEach((entry, index) => {
      const button = createPixelButton(this, {
        x: 48 + (index % 2) * 590,
        y: 596 + Math.floor(index / 2) * 54,
        width: 560,
        height: 44,
        label: ACTION_LIBRARY[entry.action].label,
        fontSize: 19,
        onClick: () => this.takeAction(entry),
      });

      this.buttonObjects.push(button);
    });
  }

  takeAction(entry) {
    if (this.bureaucracy <= 0 || this.credibility <= 0) {
      return;
    }

    this.tweens.killTweensOf(this.objectionFlash);
    this.objectionFlash.setAlpha(0.95).setScale(0.92).setX(900);
    this.tweens.add({
      targets: this.objectionFlash,
      alpha: 0,
      scale: 1.06,
      x: 930,
      duration: 450,
      ease: "Quad.Out",
    });

    const hasPrep = entry.prep ? gameState.hasNote(entry.prep) : false;
    const actionMeta = ACTION_LIBRARY[entry.action];
    const damage = hasPrep ? entry.damage : Math.max(0, entry.damage - 1);
    const credChange = hasPrep ? entry.cred : entry.cred - 1;

    this.bureaucracy = Math.max(0, this.bureaucracy - damage);
    this.position = Math.max(0, Math.min(10, this.position + (hasPrep ? 1 : 0)));
    this.credibility = Math.max(0, Math.min(9, this.credibility + credChange));

    let log = hasPrep ? actionMeta.success : actionMeta.failure;

    if (!hasPrep && entry.prep) {
      log += ` You are missing the note: ${entry.prep}.`;
    }

    if (this.bureaucracy <= 0) {
      this.winBattle(log);
      return;
    }

    const enemyLine = this.caseFile.enemyLines[this.turn % this.caseFile.enemyLines.length];
    this.turn += 1;
    this.credibility = Math.max(0, this.credibility - 1);

    if (this.credibility <= 0) {
      this.loseBattle(`${log}\n\n${enemyLine}`);
      return;
    }

    this.refreshHud(`${log}\n\n${enemyLine}`);
  }

  refreshHud(message) {
    this.statText.setText(
      `POSITION ${"■".repeat(this.position)}${"□".repeat(10 - this.position)}\nCREDIBILITY ${"■".repeat(this.credibility)}${"□".repeat(9 - this.credibility)}\nBUREAUCRACY ${"■".repeat(this.bureaucracy)}${"□".repeat(7 - this.bureaucracy)}`
    );
    this.logText.setText(message);
  }

  winBattle(message) {
    gameState.money += 250;
    gameState.reputation = Math.min(5, gameState.reputation + 1);
    gameState.stamina = Math.max(2, Math.min(gameState.maxStamina, gameState.stamina + 1));
    const closing = `${message}\n\n${this.caseFile.winText}`;
    gameState.nextCase();
    this.finishBattle(closing, "return to map");
  }

  loseBattle(message) {
    gameState.money = Math.max(250, gameState.money - 100);
    gameState.stamina = Math.max(2, gameState.stamina - 1);
    gameState.prepared = false;
    const closing = `${message}\n\nThe file survives, but your position does not. Return to the office and assemble a better theory.`;
    this.finishBattle(closing, "back to office");
  }

  finishBattle(message, buttonText) {
    this.buttonObjects.forEach((entry) => entry.destroy());
    this.buttonObjects = [];
    this.refreshHud(message);

    const back = createPixelButton(this, {
      x: 360,
      y: 596,
      width: 560,
      height: 48,
      label: buttonText,
      fontSize: 20,
      onClick: () => {
        this.scene.start("overworld");
      },
    });

    this.buttonObjects.push(back);
  }
}
