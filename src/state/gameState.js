import { CASES } from "../data/cases.js";

export const gameState = {
  money: 850,
  stamina: 5,
  maxStamina: 5,
  reputation: 2,
  currentCaseIndex: 0,
  tutorialDismissed: false,
  prepared: false,
  officeNotes: [],
  officeTaxBill: 0,
  officeTaxSaved: 0,
  caseResults: [],
  get activeCase() {
    return CASES[this.currentCaseIndex] ?? null;
  },
  resetForCase() {
    this.prepared = false;
    this.officeNotes = [];
    this.officeTaxBill = this.activeCase?.taxBillStart ?? 0;
    this.officeTaxSaved = 0;
  },
  hasNote(note) {
    return this.officeNotes.includes(note);
  },
  addNote(note) {
    if (note && !this.officeNotes.includes(note)) {
      this.officeNotes.push(note);
    }
  },
  initializeCase() {
    if (this.officeTaxBill === 0 && this.activeCase?.taxBillStart) {
      this.officeTaxBill = this.activeCase.taxBillStart;
      this.officeTaxSaved = 0;
    }
  },
  reduceTaxBill(amount) {
    if (!amount) {
      return;
    }

    const floor = this.activeCase?.taxBillTarget ?? 0;
    const nextBill = Math.max(floor, this.officeTaxBill - amount);
    this.officeTaxSaved += this.officeTaxBill - nextBill;
    this.officeTaxBill = nextBill;
  },
  nextCase() {
    if (this.activeCase) {
      this.caseResults.push(this.activeCase.id);
    }
    this.currentCaseIndex += 1;
    this.resetForCase();
  },
};
