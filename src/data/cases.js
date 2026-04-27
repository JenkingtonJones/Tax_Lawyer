export const ACTION_LIBRARY = {
  listenIntently: {
    label: "listen intently",
    success: "The material facts have been taken down with sufficient precision to support further analysis.",
    failure: "The factual record remains incomplete and does not yet justify a confident position.",
  },
  unmute: {
    label: "unmute",
    success: "A surprisingly strong opening move. The client is now audible.",
    failure: "You were already audible. The room regards this as theatre.",
  },
  filingPapers: {
    label: "filing papers",
    success: "The right invoice appears at the exact moment dignity was about to leave.",
    failure: "You file very confidently. Unfortunately, the wrong thing.",
  },
  readOpinion: {
    label: "read opinion",
    success: "A note, an explanatory memo, and a precedent line up obediently.",
    failure: "You cite something interesting but not useful.",
  },
  sortReceipts: {
    label: "sort receipts",
    success: "The chronology stabilizes. Revenue's narrative starts to wobble.",
    failure: "The receipts remain a weather system, not evidence.",
  },
  temperatureLog: {
    label: "check temperature logs",
    success: "Hot is no longer a mood. It is now a measured fact pattern.",
    failure: "The logs are missing and HMRC senses weakness.",
  },
  citeNote: {
    label: "cite note",
    success: "A dry explanatory note lands like a finishing move.",
    failure: "You cite a note. It is not the right note.",
  },
  productionMethod: {
    label: "argue production method",
    success: "How the thing was made becomes inconveniently decisive.",
    failure: "Purpose sounds nice, but tariff law prefers manufacturing detail.",
  },
  essentialCharacter: {
    label: "attack essential character",
    success: "You make 'essential character' sound less mystical and more dangerous.",
    failure: "The panel agrees everything is essential, which helps no one.",
  },
  exposeContradiction: {
    label: "expose contradiction",
    success: "The agency's earlier ruling returns from the dead to testify.",
    failure: "The contradiction exists, but not helpfully enough.",
  },
  crossExamine: {
    label: "cross-examine",
    success: "The expert concedes the packaging retains heat in the same way a sweater retains weather.",
    failure: "The witness expands. The room regrets asking.",
  },
  readDocuments: {
    label: "read documents",
    success: "The documentary record now supports an intelligible theory of the case.",
    failure: "The documentary review has not yet clarified the relevant classification issue.",
  },
  muse: {
    label: "muse",
    success: "A plausible classification approach has emerged from the analytical review.",
    failure: "Further reflection has not yet produced a satisfactory analytical distinction.",
  },
  research: {
    label: "research",
    success: "Comparable authorities have been identified and can now be applied to the file.",
    failure: "The authorities reviewed do not yet furnish the comparison required.",
  },
};

export const CASES = [
  {
    id: "retail-set-panic",
    title: "Retail Set Panic",
    code: "TAR-3B",
    risk: "Medium",
    venue: "Customs",
    targetLocation: "customs",
    client: "Coffee Roasters Ltd.",
    summary:
      "The client imports retail packages of ground coffee. Customs has found a way to make this more expensive than the client thinks it should be.",
    officeBrief:
      "The issue is straightforward, at least until one looks at it. The client imports ground coffee in retail packages. Customs appears inclined to think less about the coffee as imported, and more about the beverage it may later become. The client would prefer to pay tax on the thing it imports, rather than on the cup of coffee someone eventually makes from it.",
    clientBrief:
      "Coffee Roasters Ltd. imports sealed retail packages of premium ground coffee. The goods arrive as coffee granules in fixed consumer quantities. They do not arrive as a beverage. They also do not arrive with cups, saucers, spoons, kettles, or any other object that might encourage Customs to become imaginative.\n\nThe difficulty is that Customs appears attracted to the proposition that one should think about the brewed coffee, rather than the imported goods. That is not a small distinction. If one begins with the goods as imported, one has a package of granules. If one begins with the brewed result, one has a cup of liquid. These are not the same thing, though the latter is plainly the ambition of the former.\n\nThe client’s position is that tax should follow the imported article. The goods are bought, sold, and imported as packaged coffee granules. The fact that hot water may later be introduced to the relationship should not, on the client’s view, alter the analysis at the border.\n\nThe financial consequences are not trivial. On the client’s numbers, the difference between the competing approaches is large enough to matter in an immediate and unwelcome way.",
    taxBillStart: 18250,
    taxBillTarget: 9750,
    officeSequence: [
      {
        id: "call",
        title: "Phone Call",
        instruction:
          "Initial instructions are taken by telephone. The client states the issue directly and confines itself to the facts.",
        action: "listenIntently",
        note: "client-call",
        taxDelta: 0,
        narration:
          "\"We import retail packages of premium ground coffee. Customs appears inclined to treat the product by reference to the brewed beverage rather than the goods as imported. If that view prevails, the tax consequences will be materially adverse.\"",
        result:
          "The real issue presents itself quickly. This is not about giftware, presentation, or the social life of coffee. It is about whether the goods should be classified as imported, or as the liquid they may later become.",
        readingMaterial:
          "Telephone note\n\nThe client confirms that the imported goods consist only of retail packages of ground coffee. Nothing else is imported with them. This is helpful, because once cups and saucers appear, everyone starts having unhelpful thoughts about gift boxes.\n\nSo the immediate question is a narrow one. Do we classify the coffee as imported, meaning as a retail package of granules, or do we allow the later act of brewing to do all the analytical work? The client strongly prefers the former. On balance, so do you.",
      },
      {
        id: "documents",
        title: "Documents",
        instruction:
          "The documentary record is reviewed: invoices, product descriptions, package specifications, and import paperwork.",
        action: "readDocuments",
        note: "document-stack",
        taxDelta: 1150,
        narration:
          "The documents confirm uniform retail packages of ground coffee, sold by weight, with no accompanying giftware or mixed-purpose articles.",
        result:
          "The documents are helpful, though not in the way Customs appears to think. They describe a consistent retail product sold by weight and packaged in fixed consumer quantities. That is exactly what one would hope to see if one wished to argue that the imported goods should be taken seriously in their imported form.",
        readingMaterial:
          "Document review\n\nThe invoices describe the goods by weight, as retail packages of ground coffee. The package specifications are standardized. The product materials speak of brewing after purchase, which is true enough, but they do not suggest that the imported goods are somehow less coffee because hot water may later be involved.\n\nJust as importantly, there is no sign of mixed packaging, no accompanying tableware, and no attempt to sell the product as a charming domestic ensemble. It is coffee in a package. One would think that might simplify matters. It does not, but at least the documents are on your side.",
      },
      {
        id: "muse",
        title: "Muse",
        instruction:
          "Possible classification approaches are considered and tested before a final position is adopted.",
        action: "muse",
        note: "granule-angle",
        taxDelta: 3250,
        narration:
          "At this point a slightly alarming thought occurs to you. Spaghetti can be a set. Fries can be a set. Ground coffee is also sold as a collection of many tiny things put up together for a single purpose. No one imports one granule. No one sells one granule. No one, one hopes, brews one granule. The fact that the granules later become liquid does not obviously mean they were liquid all along.",
        result:
          "Three possible lines of argument suggest themselves:\n- the imported goods are a retail quantity of granules put up together for sale\n- the law should respect the condition of the goods as imported\n- brewing happens later, and later is not always the right place to begin",
        readingMaterial:
          "Working note on possible approaches\n\nHere is the thought, and it is not entirely ridiculous. The imported article is a package of coffee granules placed up together for retail sale. Each granule is tiny, yes, but that is not the same as being irrelevant. The goods are bought, sold, imported, and used as a collective quantity.\n\nThis starts to look awkwardly similar to other examples where many small components, sold together for one purpose, are treated as a grouped article. Spaghetti does not cease to be spaghetti because it will later become dinner. Fries do not cease to be fries because ketchup may eventually intervene. By the same logic, coffee granules need not be ignored simply because they are destined for a kettle.\n\nSo the possible position is this: the imported goods are not a cup of coffee waiting to happen. They are coffee granules put up together for retail sale. Just because something becomes a liquid later does not mean it was legally unitary from the start.",
      },
      {
        id: "research",
        title: "Research",
        instruction:
          "Comparable authorities and explanatory examples are reviewed once the factual understanding is sufficiently settled.",
        action: "research",
        note: "wco-note",
        taxDelta: 4100,
        narration:
          "Three examples immediately present themselves: the sandwich with fries, the spaghetti meal, and the coffee package with a cup and saucer. The law has already managed to say something odd about all three, so you might as well use it.",
        result:
          "Research points:\n- sandwich with fries: treated as a set, classified by the sandwich\n- spaghetti with sauce and cheese: treated as a set, classified by the spaghetti\n- coffee with cup and saucer: not treated as a set, which is useful because this file is about coffee, not table manners\n\nThat is enough to proceed.",
        readingMaterial:
          "Research note\n\nThe sandwich example helps because it shows that the law is prepared, in the right circumstances, to treat separately identifiable items put up together as a single retail set, and to classify the set by reference to what gives it its character.\n\nThe spaghetti example helps for much the same reason, except that it is somehow even stranger once one stops to think about it. Uncooked spaghetti, sauce, and cheese can be treated as a set because they are put together for a unified purpose and are meant to be used together.\n\nThen there is the coffee example with the cup and saucer, which goes the other way. That package is not treated as the relevant kind of set. This is useful, because it lets you distinguish between coffee packaged with tableware for presentation, and coffee sold simply as coffee.\n\nSo the file becomes clearer. The present issue is not whether coffee can be sold beside other things in a box. It is whether ground coffee, imported in retail quantities, should be analyzed as the thing it is, rather than the beverage someone may later prepare from it.",
      },
    ],
    routeNarration:
      "You now know enough to become dangerous. The next step is Customs. The highlighted location is the only place worth visiting for this file.",
    battleIntro:
      "CBSA opens with the devastating observation that coffee is drunk, cups are held, and the law has noticed the difference.",
    battleActions: [
      { action: "citeNote", damage: 3, cred: 0, prep: "wco-note" },
      { action: "essentialCharacter", damage: 2, cred: 0, prep: "shared-use" },
      { action: "filingPapers", damage: 1, cred: 1, prep: "invoice-order" },
      { action: "exposeContradiction", damage: 1, cred: -1, prep: null },
    ],
    enemyLines: [
      "Counsel: A gift basket is not a meal simply because cardboard was involved.",
      "Officer: The jar and cup are acquainted, not integrated.",
      "Panel: Please define why these goods are intended to be used together without using the word vibe.",
    ],
    winText:
      "You do not fully convert the tribunal, but you reduce the matter to a respectable argument about shared use rather than decorative companionship.",
  },
  {
    id: "dog-chew-apocalypse",
    title: "Dog Chew Apocalypse",
    code: "DOG-245",
    risk: "High",
    venue: "Tax Office",
    targetLocation: "taxOffice",
    client: "Pet Chews Inc.",
    summary:
      "A line of dog chews has somehow wandered across categories including bone, offal, feed, leather, and supply-managed dairy.",
    officeBrief:
      "You are required to explain, calmly, why a flavored yak cheese chew is not the same regulatory species as a braided rawhide stick with starch.",
    officeSteps: [
      {
        prompt:
          "\"Our catalog includes rawhide braids, beef tendon twists, and dried yak cheese bars. We thought this was diversification.\"",
        choices: [
          { action: "listenIntently", note: "catalog-split", effect: 2 },
          { action: "unmute", note: "audible-client", effect: 0 },
          { action: "filingPapers", note: "mixed-skus", effect: -1 },
          { action: "readOpinion", note: "chew-rulings", effect: 1 },
        ],
        bestAction: "listenIntently",
      },
      {
        prompt:
          "The key question is not what a chew is for, but how it is made and from what.",
        choices: [
          { action: "productionMethod", note: "method-matters", effect: 2 },
          { action: "readOpinion", note: "chew-rulings", effect: 1 },
          { action: "sortReceipts", note: "ingredient-binders", effect: 1 },
          { action: "filingPapers", note: "misfiled-leather", effect: -1 },
        ],
        bestAction: "productionMethod",
      },
    ],
    battleIntro:
      "The auditor's position is elegant in the way a chainsaw is elegant: if it is cheese, the tariff is ruinous; if it is leather, it is somehow still not food; and if it is extruded, everyone becomes philosophical.",
    battleActions: [
      { action: "productionMethod", damage: 3, cred: 0, prep: "method-matters" },
      { action: "citeNote", damage: 2, cred: 0, prep: "chew-rulings" },
      { action: "sortReceipts", damage: 1, cred: 1, prep: "ingredient-binders" },
      { action: "essentialCharacter", damage: 1, cred: -1, prep: null },
    ],
    enemyLines: [
      "Auditor: The dog's opinion is interesting but not determinative.",
      "Officer: Rawhide remains leather even when marketed with alarming enthusiasm.",
      "Auditor: Supply management has entered the chat carrying a flamethrower.",
    ],
    winText:
      "You drag the dispute back to production method, which is where tariff classification likes to hide when ordinary language has failed society.",
  },
  {
    id: "hot-chicken-incident",
    title: "Hot Chicken Incident",
    code: "VAT-20",
    risk: "High",
    venue: "Tribunal",
    targetLocation: "tribunal",
    client: "Morrisons-ish Foods",
    summary:
      "The issue is whether rotisserie chickens sold in paper bags were supplied hot for consumption hot, or merely sold while still possessing recent warmth.",
    officeBrief:
      "You need temperature logs, packaging details, and enough skepticism about the word 'hot' to make everyone uncomfortable.",
    officeSteps: [
      {
        prompt:
          "\"We roast them in store, bag them, put them out, and many customers eat them later. Sometimes cold. Sometimes reheated. Often as tomorrow's problem.\"",
        choices: [
          { action: "listenIntently", note: "consumed-later", effect: 2 },
          { action: "unmute", note: "audible-client", effect: 0 },
          { action: "temperatureLog", note: "missing-temps", effect: -1 },
          { action: "readOpinion", note: "hmrc-history", effect: 1 },
        ],
        bestAction: "listenIntently",
      },
      {
        prompt:
          "You need to undermine packaging-as-heat-retention and preserve the point that being warm is not the same as being supplied as hot takeaway food.",
        choices: [
          { action: "temperatureLog", note: "temperature-curve", effect: 2 },
          { action: "crossExamine", note: "packaging-expert", effect: 2 },
          { action: "filingPapers", note: "bag-specs", effect: 1 },
          { action: "unmute", note: "still-audible", effect: -1 },
        ],
        bestAction: "crossExamine",
      },
    ],
    battleIntro:
      "HMRC arrives carrying seventeen million pounds of hindsight and a paper bag that allegedly retains heat with theological significance.",
    battleActions: [
      { action: "crossExamine", damage: 3, cred: 0, prep: "packaging-expert" },
      { action: "temperatureLog", damage: 2, cred: 0, prep: "temperature-curve" },
      { action: "exposeContradiction", damage: 2, cred: 1, prep: "hmrc-history" },
      { action: "citeNote", damage: 1, cred: -1, prep: null },
    ],
    enemyLines: [
      "HMRC: The chicken is hot, the bag retains heat, civilization must respond.",
      "Witness: Every bag retains heat if one lowers one's standards sufficiently.",
      "Tribunal: The phrase 'supplied hot' is doing astonishing work today.",
    ],
    winText:
      "You do not abolish semantic chaos, but you make 'hot' answerable to evidence instead of vibes, which is as close to justice as tax gets.",
  },
];
