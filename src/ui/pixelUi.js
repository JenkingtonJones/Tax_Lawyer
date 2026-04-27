import Phaser from "phaser";

export function createPixelButton(scene, config) {
  const {
    x,
    y,
    width,
    height,
    label,
    onClick,
    fontSize = 20,
    fill = 0x18212c,
    hoverFill = 0x243141,
    fillAlpha = 0.96,
    hoverAlpha = 1,
    border = 0xb99963,
    borderAlpha = 1,
    borderWidth = 3,
    textColor = "#f5eed8",
    textOffsetX = 18,
    textOffsetY,
    depth = 20,
  } = config;

  const bg = scene.add
    .rectangle(x, y, width, height, fill, fillAlpha)
    .setOrigin(0, 0)
    .setDepth(depth)
    .setInteractive({ useHandCursor: true });

  if (borderWidth > 0) {
    bg.setStrokeStyle(borderWidth, border, borderAlpha);
  }

  const text = scene.add
    .text(x + textOffsetX, y + (textOffsetY ?? Math.max(8, Math.floor((height - fontSize) / 2) - 2)), label, {
      fontFamily: "Courier New",
      fontSize: `${fontSize}px`,
      color: textColor,
    })
    .setOrigin(0, 0)
    .setDepth(depth + 1);

  bg.on("pointerover", () => bg.setFillStyle(hoverFill, hoverAlpha));
  bg.on("pointerout", () => bg.setFillStyle(fill, fillAlpha));
  bg.on("pointerdown", onClick);

  return {
    bg,
    text,
    destroy() {
      bg.destroy();
      text.destroy();
    },
  };
}

export function addScanlineOverlay(scene, alpha = 0.08) {
  const key = `${scene.sys.settings.key}-scanlines`;

  if (!scene.textures.exists(key)) {
    const graphics = scene.make.graphics({ x: 0, y: 0, add: false });

    for (let y = 0; y < 720; y += 4) {
      graphics.fillStyle(0x000000, y % 8 === 0 ? 0.22 : 0.1);
      graphics.fillRect(0, y, 1280, 2);
    }

    graphics.generateTexture(key, 1280, 720);
    graphics.destroy();
  }

  const overlay = scene.add
    .tileSprite(640, 360, 1280, 720, key)
    .setScrollFactor(0)
    .setDepth(220)
    .setAlpha(alpha);

  scene.tweens.add({
    targets: overlay,
    tilePositionY: 28,
    duration: 1800,
    repeat: -1,
    ease: "Linear",
  });

  return overlay;
}

export function createModal(scene, config) {
  const { title, body, buttonLabel, onClose } = config;
  const depth = 300;
  const entries = [];

  const close = () => {
    entries.forEach((entry) => entry.destroy());
    if (onClose) {
      onClose();
    }
  };

  const backdrop = scene.add
    .rectangle(640, 360, 1280, 720, 0x05070a, 0.74)
    .setDepth(depth)
    .setInteractive();

  const panel = scene.add
    .rectangle(640, 360, 860, 470, 0x121822, 0.97)
    .setStrokeStyle(4, 0xb99963)
    .setDepth(depth + 1);

  const titleText = scene.add
    .text(220, 162, title, {
      fontFamily: "Courier New",
      fontSize: "28px",
      color: "#f5eed8",
      fontStyle: "bold",
    })
    .setDepth(depth + 2);

  const bodyText = scene.add
    .text(220, 214, body, {
      fontFamily: "Courier New",
      fontSize: "19px",
      color: "#e7dfcb",
      wordWrap: { width: 810 },
      lineSpacing: 10,
    })
    .setDepth(depth + 2);

  const closeButton = createPixelButton(scene, {
    x: 465,
    y: 550,
    width: 350,
    height: 54,
    label: buttonLabel,
    fontSize: 21,
    depth: depth + 2,
    onClick: close,
  });

  const dismissText = scene.add
    .text(538, 618, "Press H or click HELP to reopen this briefing.", {
      fontFamily: "Courier New",
      fontSize: "16px",
      color: "#9ac07a",
    })
    .setDepth(depth + 2);

  const xButton = createPixelButton(scene, {
    x: 978,
    y: 146,
    width: 72,
    height: 46,
    label: "X",
    fontSize: 22,
    depth: depth + 2,
    onClick: close,
  });

  entries.push(backdrop, panel, titleText, bodyText, dismissText);
  entries.push(closeButton, xButton);

  return { close };
}

export function paginateText(text, maxChars = 420) {
  if (!text) {
    return [""];
  }

  const paragraphs = text.split("\n");
  const pages = [];
  let current = "";

  paragraphs.forEach((paragraph) => {
    const chunk = paragraph.trim() === "" ? "\n" : `${paragraph}\n`;

    if ((current + chunk).length <= maxChars) {
      current += chunk;
      return;
    }

    if (current.trim()) {
      pages.push(current.trim());
      current = "";
    }

    if (chunk.length <= maxChars) {
      current = chunk;
      return;
    }

    const words = paragraph.split(" ");
    let line = "";

    words.forEach((word) => {
      const next = line ? `${line} ${word}` : word;
      if (next.length > maxChars) {
        pages.push(line.trim());
        line = word;
      } else {
        line = next;
      }
    });

    current = `${line}\n`;
  });

  if (current.trim()) {
    pages.push(current.trim());
  }

  return pages.length ? pages : [text];
}

export function createPagedReader(scene, config) {
  const { title, pages, onClose } = config;
  const depth = 340;
  const entries = [];
  let pageIndex = 0;

  const backdrop = scene.add
    .rectangle(640, 360, 1280, 720, 0x05070a, 0.8)
    .setDepth(depth)
    .setInteractive();

  const panel = scene.add
    .rectangle(640, 360, 940, 560, 0x121822, 0.98)
    .setStrokeStyle(4, 0xb99963)
    .setDepth(depth + 1);

  const titleText = scene.add
    .text(200, 110, title, {
      fontFamily: "Courier New",
      fontSize: "26px",
      color: "#f5eed8",
      fontStyle: "bold",
    })
    .setDepth(depth + 2);

  const pageText = scene.add
    .text(200, 164, "", {
      fontFamily: "Courier New",
      fontSize: "18px",
      color: "#e7dfcb",
      wordWrap: { width: 880 },
      lineSpacing: 8,
    })
    .setDepth(depth + 2);

  const pageIndexText = scene.add
    .text(200, 620, "", {
      fontFamily: "Courier New",
      fontSize: "16px",
      color: "#9ac07a",
    })
    .setDepth(depth + 2);

  const close = () => {
    entries.forEach((entry) => entry.destroy());
    if (onClose) {
      onClose();
    }
  };

  const refresh = () => {
    pageText.setText(pages[pageIndex] ?? "");
    pageIndexText.setText(`Page ${pageIndex + 1} of ${pages.length}`);
    prevButton.bg.setVisible(pageIndex > 0);
    prevButton.text.setVisible(pageIndex > 0);
    nextButton.text.setText(pageIndex === pages.length - 1 ? "close file" : "next page");
  };

  const prevButton = createPixelButton(scene, {
    x: 200,
    y: 650,
    width: 180,
    height: 44,
    label: "previous page",
    fontSize: 18,
    depth: depth + 2,
    onClick: () => {
      pageIndex = Math.max(0, pageIndex - 1);
      refresh();
    },
  });

  const nextButton = createPixelButton(scene, {
    x: 760,
    y: 650,
    width: 180,
    height: 44,
    label: "next page",
    fontSize: 18,
    depth: depth + 2,
    onClick: () => {
      if (pageIndex >= pages.length - 1) {
        close();
        return;
      }

      pageIndex += 1;
      refresh();
    },
  });

  const xButton = createPixelButton(scene, {
    x: 1016,
    y: 96,
    width: 72,
    height: 42,
    label: "X",
    fontSize: 20,
    depth: depth + 2,
    onClick: close,
  });

  entries.push(backdrop, panel, titleText, pageText, pageIndexText, prevButton, nextButton, xButton);
  refresh();

  return { close };
}
