import Phaser from "phaser";
import { ACTION_LIBRARY } from "../data/cases.js";
import { gameState } from "../state/gameState.js";
import { addScanlineOverlay, createPagedReader, createPixelButton, paginateText } from "../ui/pixelUi.js";

const OFFICE_LAYOUT = {
  sidebar: { x: 824, y: 96, w: 388, h: 452 },
  notesBox: { x: 842, y: 118, w: 352, h: 92 },
  taxBox: { x: 842, y: 226, w: 352, h: 72 },
  actionSlots: [
    { x: 842, y: 318, w: 352, h: 44 },
    { x: 842, y: 374, w: 352, h: 44 },
    { x: 842, y: 430, w: 352, h: 44 },
    { x: 842, y: 486, w: 352, h: 44 },
  ],
  feedback: { x: 70, y: 562, w: 1120 },
  dialogue: { x: 70, y: 602, w: 1120 },
};

export class OfficeScene extends Phaser.Scene {
  constructor() {
    super("office");
  }

  create() {
    this.caseFile = gameState.activeCase;
    gameState.initializeCase();
    this.stepIndex = 0;
    this.sequenceIndex = 0;
    this.feedback = "Review the file methodically and identify the strongest available classification position.";
    this.sequenceMode = Boolean(this.caseFile.officeSequence);

    this.drawOffice();
    if (this.sequenceMode) {
      this.renderSequenceStage();
    } else {
      this.renderStep();
    }
    addScanlineOverlay(this, 0.05);
  }

  drawOffice() {
    this.cameras.main.setBackgroundColor("#151922");
    this.add.image(640, 360, "office-bg").setDisplaySize(1280, 720);

    this.windowGlint = this.add.rectangle(134, 168, 18, 128, 0xffffff, 0.08);
    this.tweens.add({
      targets: this.windowGlint,
      x: 228,
      alpha: { from: 0.08, to: 0.01 },
      duration: 2400,
      repeat: -1,
      delay: 700,
    });

    this.add.text(36, 19, "TAX LAWYER :: OFFICE INTAKE", {
      fontFamily: "Courier New",
      fontSize: "27px",
      color: "#f4ead3",
      fontStyle: "bold",
    });

    this.add.text(36, 52, this.caseFile.title, {
      fontFamily: "Courier New",
      fontSize: "16px",
      color: "#9ac07a",
    });

    this.add
      .rectangle(
        OFFICE_LAYOUT.sidebar.x + OFFICE_LAYOUT.sidebar.w / 2,
        OFFICE_LAYOUT.sidebar.y + OFFICE_LAYOUT.sidebar.h / 2,
        OFFICE_LAYOUT.sidebar.w,
        OFFICE_LAYOUT.sidebar.h,
        0x11161d,
        0.94
      )
      .setStrokeStyle(3, 0xb99963, 0.4);

    this.add
      .rectangle(
        OFFICE_LAYOUT.notesBox.x + OFFICE_LAYOUT.notesBox.w / 2,
        OFFICE_LAYOUT.notesBox.y + OFFICE_LAYOUT.notesBox.h / 2,
        OFFICE_LAYOUT.notesBox.w,
        OFFICE_LAYOUT.notesBox.h,
        0x11161d,
        0.98
      )
      .setStrokeStyle(2, 0xb99963, 0.45);

    this.noteText = this.add.text(OFFICE_LAYOUT.notesBox.x + 14, OFFICE_LAYOUT.notesBox.y + 10, "", {
      fontFamily: "Courier New",
      fontSize: "13px",
      color: "#f1ead9",
      wordWrap: { width: OFFICE_LAYOUT.notesBox.w - 28 },
      lineSpacing: 3,
    });

    this.add
      .rectangle(
        OFFICE_LAYOUT.taxBox.x + OFFICE_LAYOUT.taxBox.w / 2,
        OFFICE_LAYOUT.taxBox.y + OFFICE_LAYOUT.taxBox.h / 2,
        OFFICE_LAYOUT.taxBox.w,
        OFFICE_LAYOUT.taxBox.h,
        0x11161d,
        0.98
      )
      .setStrokeStyle(2, 0xb99963, 0.45);
    this.taxBillText = this.add.text(OFFICE_LAYOUT.taxBox.x + 14, OFFICE_LAYOUT.taxBox.y + 10, "", {
      fontFamily: "Courier New",
      fontSize: "13px",
      color: "#f3d789",
      wordWrap: { width: OFFICE_LAYOUT.taxBox.w - 28 },
      lineSpacing: 3,
    });

    this.feedbackText = this.add.text(OFFICE_LAYOUT.feedback.x, OFFICE_LAYOUT.feedback.y, "", {
      fontFamily: "Courier New",
      fontSize: "14px",
      color: "#98d38a",
      wordWrap: { width: OFFICE_LAYOUT.feedback.w },
      lineSpacing: 4,
    });

    this.dialogueText = this.add.text(OFFICE_LAYOUT.dialogue.x, OFFICE_LAYOUT.dialogue.y, "", {
      fontFamily: "Courier New",
      fontSize: "16px",
      color: "#f4ebd7",
      wordWrap: { width: OFFICE_LAYOUT.dialogue.w },
      lineSpacing: 5,
    });

    this.makeMonitorMotion();
    this.buttonObjects = [];
  }

  makeMonitorMotion() {
    this.monitorGlow = this.add.rectangle(392, 294, 126, 100, 0x90cfe6, 0.08);
    this.micLight = this.add.circle(466, 228, 5, 0x8ed486, 1);
    this.clientHead = this.add.circle(390, 280, 16, 0xe2c9a3).setStrokeStyle(2, 0x4b3527);
    this.clientBody = this.add.rectangle(390, 323, 42, 44, 0x6e4c35);
    this.audioBars = [0, 1, 2, 3].map((index) =>
      this.add.rectangle(442 + index * 14, 346, 8, 10 + index * 3, 0x8ed486, 0.9)
    );

    this.tweens.add({
      targets: [this.clientHead, this.clientBody],
      y: "-=3",
      duration: 1100,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });

    this.tweens.add({
      targets: this.monitorGlow,
      alpha: { from: 0.08, to: 0.18 },
      duration: 900,
      yoyo: true,
      repeat: -1,
    });

    this.tweens.add({
      targets: this.micLight,
      alpha: { from: 1, to: 0.25 },
      duration: 500,
      yoyo: true,
      repeat: -1,
    });

    this.time.addEvent({
      delay: 220,
      loop: true,
      callback: () => {
        this.audioBars.forEach((bar, index) => {
          bar.height = 10 + Phaser.Math.Between(0, 22) + index * 2;
        });
      },
    });

    const steamOffsets = [-18, 0, 18];
    steamOffsets.forEach((offset, index) => {
      const puff = this.add.circle(96 + offset, 429, 7, 0xf4ead3, 0.28);
      this.tweens.add({
        targets: puff,
        y: 399 - index * 8,
        x: 98 + offset * 0.25,
        alpha: { from: 0.28, to: 0 },
        scale: { from: 1, to: 1.8 },
        duration: 1800 + index * 200,
        repeat: -1,
        delay: index * 450,
      });
    });
  }

  renderSequenceStage() {
    const stage = this.caseFile.officeSequence[this.sequenceIndex];

    this.dialogueText.setText(
      `${stage.title}\n${stage.instruction}`
    );

    this.noteText.setText(
      `FILE NOTES\nCode: ${this.caseFile.code}\nVenue: ${this.caseFile.venue}\nNotes: ${gameState.officeNotes.length ? gameState.officeNotes.join("; ") : "none yet"}`
    );
    this.taxBillText.setText(
      `POSSIBLE TAX BILL\n$${gameState.officeTaxBill.toLocaleString()}\nSaved so far: $${gameState.officeTaxSaved.toLocaleString()}`
    );
    this.feedbackText.setText(this.feedback);

    this.buttonObjects.forEach((entry) => entry.destroy());
    this.buttonObjects = [];

    const primary = createPixelButton(this, {
      x: OFFICE_LAYOUT.actionSlots[0].x,
      y: OFFICE_LAYOUT.actionSlots[0].y,
      width: OFFICE_LAYOUT.actionSlots[0].w,
      height: OFFICE_LAYOUT.actionSlots[0].h,
      label: stage.action === "research" ? "RESEARCH" : ACTION_LIBRARY[stage.action].label,
      fontSize: 18,
      fill: 0x18212c,
      hoverFill: 0x2a3542,
      fillAlpha: 0.95,
      hoverAlpha: 1,
      borderWidth: 2,
      borderAlpha: 0.45,
      textOffsetY: 10,
      onClick: () => this.resolveSequenceStage(stage),
    });

    this.buttonObjects.push(primary);

    const briefButton = createPixelButton(this, {
      x: OFFICE_LAYOUT.actionSlots[1].x,
      y: OFFICE_LAYOUT.actionSlots[1].y,
      width: OFFICE_LAYOUT.actionSlots[1].w,
      height: OFFICE_LAYOUT.actionSlots[1].h,
      label: "open client brief",
      fontSize: 17,
      fill: 0x18212c,
      hoverFill: 0x2a3542,
      fillAlpha: 0.95,
      hoverAlpha: 1,
      borderWidth: 2,
      borderAlpha: 0.45,
      textOffsetY: 10,
      onClick: () => this.openReader("Client Brief", this.caseFile.clientBrief ?? this.caseFile.officeBrief),
    });
    this.buttonObjects.push(briefButton);

    if (stage.readingMaterial) {
      const materialButton = createPixelButton(this, {
        x: OFFICE_LAYOUT.actionSlots[2].x,
        y: OFFICE_LAYOUT.actionSlots[2].y,
        width: OFFICE_LAYOUT.actionSlots[2].w,
        height: OFFICE_LAYOUT.actionSlots[2].h,
        label: stage.id === "research" ? "open research file" : "open materials",
        fontSize: 17,
        fill: 0x18212c,
        hoverFill: 0x2a3542,
        fillAlpha: 0.95,
        hoverAlpha: 1,
        borderWidth: 2,
        borderAlpha: 0.45,
        textOffsetY: 10,
        onClick: () => this.openReader(stage.title, stage.readingMaterial),
      });
      this.buttonObjects.push(materialButton);
    }

    if (stage.id === "muse") {
      const angles = createPixelButton(this, {
        x: OFFICE_LAYOUT.actionSlots[3].x,
        y: OFFICE_LAYOUT.actionSlots[3].y,
        width: OFFICE_LAYOUT.actionSlots[3].w,
        height: OFFICE_LAYOUT.actionSlots[3].h,
        label: "review analytical positions",
        fontSize: 17,
        fill: 0x18212c,
        hoverFill: 0x2a3542,
        fillAlpha: 0.95,
        hoverAlpha: 1,
        borderWidth: 2,
        borderAlpha: 0.45,
        textOffsetY: 10,
        onClick: () => {
          this.feedback = "The present issue turns on the goods as imported and the extent to which later transformation should be disregarded.";
          this.dialogueText.setText(
            `${stage.title}\n${stage.instruction}\n\n${stage.result}`
          );
        },
      });
      this.buttonObjects.push(angles);
    }
  }

  resolveSequenceStage(stage) {
    gameState.addNote(stage.note);
    gameState.reduceTaxBill(stage.taxDelta);
    this.feedback = `${ACTION_LIBRARY[stage.action].success} Estimated tax exposure now stands at $${gameState.officeTaxBill.toLocaleString()}.`;
    this.dialogueText.setText(
      `${stage.title}\n${stage.result}`
    );
    this.noteText.setText(
      `FILE NOTES\nCode: ${this.caseFile.code}\nVenue: ${this.caseFile.venue}\nNotes: ${gameState.officeNotes.join("; ")}`
    );
    this.taxBillText.setText(
      `POSSIBLE TAX BILL\n$${gameState.officeTaxBill.toLocaleString()}\nSaved so far: $${gameState.officeTaxSaved.toLocaleString()}`
    );
    this.feedbackText.setText(this.feedback);
    this.buttonObjects.forEach((entry) => entry.destroy());
    this.buttonObjects = [];

    if (this.sequenceIndex >= this.caseFile.officeSequence.length - 1) {
      gameState.prepared = true;
      this.finishSequence(stage);
      return;
    }

    const continueButton = createPixelButton(this, {
      x: OFFICE_LAYOUT.actionSlots[3].x,
      y: OFFICE_LAYOUT.actionSlots[3].y,
      width: OFFICE_LAYOUT.actionSlots[3].w,
      height: OFFICE_LAYOUT.actionSlots[3].h,
      label: "continue review",
      fontSize: 18,
      fill: 0x18212c,
      hoverFill: 0x2a3542,
      fillAlpha: 0.95,
      hoverAlpha: 1,
      borderWidth: 2,
      borderAlpha: 0.45,
      textOffsetY: 10,
      onClick: () => {
        this.sequenceIndex += 1;
        this.renderSequenceStage();
      },
    });

    this.buttonObjects.push(continueButton);
  }

  renderStep() {
    const step = this.caseFile.officeSteps[this.stepIndex];

    this.dialogueText.setText(
      `${this.caseFile.client}\n${this.caseFile.officeBrief}\nClient says: ${step.prompt}`
    );

    this.noteText.setText(
      `FILE NOTES\nCode: ${this.caseFile.code}\nVenue: ${this.caseFile.venue}\nNotes: ${gameState.officeNotes.length ? gameState.officeNotes.join(", ") : "none yet"}`
    );
    this.taxBillText.setText("");
    this.feedbackText.setText(this.feedback);

    this.buttonObjects.forEach((entry) => entry.destroy());
    this.buttonObjects = [];

    step.choices.forEach((choice, index) => {
      const button = createPixelButton(this, {
        x: 848,
        y: 200 + index * 58,
        width: 352,
        height: 42,
        label: `${index + 1}. ${ACTION_LIBRARY[choice.action].label}`,
        fontSize: 18,
        fill: 0x11161d,
        hoverFill: 0x2a3542,
        fillAlpha: 0.06,
        hoverAlpha: 0.22,
        borderWidth: 0,
        onClick: () => this.resolveChoice(choice, step.bestAction),
      });

      this.buttonObjects.push(button);
    });
  }

  resolveChoice(choice, bestAction) {
    const actionCopy = ACTION_LIBRARY[choice.action];
    const strongChoice = choice.action === bestAction;

    gameState.addNote(choice.note);

    if (choice.effect < 0) {
      gameState.stamina = Math.max(1, gameState.stamina + choice.effect);
    }

    if (choice.effect > 0 && gameState.stamina < gameState.maxStamina) {
      gameState.stamina += 1;
    }

    this.feedback = strongChoice ? actionCopy.success : actionCopy.failure;
    this.stepIndex += 1;

    if (this.stepIndex >= this.caseFile.officeSteps.length) {
      gameState.prepared = true;
      this.finishOffice();
      return;
    }

    this.renderStep();
  }

  finishOffice() {
    this.buttonObjects.forEach((entry) => entry.destroy());
    this.buttonObjects = [];

    this.dialogueText.setText(
      `${this.caseFile.client}\nFile prepared. You have enough facts to stop guessing in public.\nProceed to ${this.caseFile.venue}. Status: defensible, which is all anyone can honestly ask.`
    );

    this.noteText.setText(
      `FILE NOTES\nStatus: defensible\nNotes: ${gameState.officeNotes.length ? gameState.officeNotes.join(", ") : "none yet"}`
    );

    this.feedbackText.setText(
      "Office work complete. You have gathered the facts, the note, and at least one theory that can survive contact with authority."
    );

    const back = createPixelButton(this, {
      x: OFFICE_LAYOUT.actionSlots[0].x,
      y: OFFICE_LAYOUT.actionSlots[0].y,
      width: OFFICE_LAYOUT.actionSlots[0].w,
      height: OFFICE_LAYOUT.actionSlots[0].h,
      label: "return to city map",
      fontSize: 19,
      fill: 0x18212c,
      hoverFill: 0x2a3542,
      fillAlpha: 0.95,
      hoverAlpha: 1,
      borderWidth: 2,
      borderAlpha: 0.45,
      textOffsetY: 10,
      onClick: () => {
        this.scene.start("overworld");
      },
    });

    this.buttonObjects.push(back);
  }

  finishSequence(stage) {
    this.buttonObjects.forEach((entry) => entry.destroy());
    this.buttonObjects = [];

    this.feedbackText.setText(
      `Research complete. Estimated bill reduced to $${gameState.officeTaxBill.toLocaleString()}. The more you save, the stronger the score.`
    );
    this.dialogueText.setText(
      `${this.caseFile.client}\n${stage.result}\n\n${this.caseFile.routeNarration}`
    );
    this.noteText.setText(
      `FILE NOTES\nCode: ${this.caseFile.code}\nVenue: ${this.caseFile.venue}\nNotes: ${gameState.officeNotes.join("; ")}`
    );
    this.taxBillText.setText(
      `POSSIBLE TAX BILL\n$${gameState.officeTaxBill.toLocaleString()}\nSaved so far: $${gameState.officeTaxSaved.toLocaleString()}`
    );

    const back = createPixelButton(this, {
      x: OFFICE_LAYOUT.actionSlots[0].x,
      y: OFFICE_LAYOUT.actionSlots[0].y,
      width: OFFICE_LAYOUT.actionSlots[0].w,
      height: OFFICE_LAYOUT.actionSlots[0].h,
      label: "go to city map",
      fontSize: 19,
      fill: 0x18212c,
      hoverFill: 0x2a3542,
      fillAlpha: 0.95,
      hoverAlpha: 1,
      borderWidth: 2,
      borderAlpha: 0.45,
      textOffsetY: 10,
      onClick: () => {
        this.scene.start("overworld");
      },
    });

    this.buttonObjects.push(back);
  }

  openReader(title, text) {
    if (this.readerModal) {
      return;
    }

    const pages = paginateText(text, 900);
    this.readerModal = createPagedReader(this, {
      title,
      pages,
      onClose: () => {
        this.readerModal = null;
      },
    });
  }
}
