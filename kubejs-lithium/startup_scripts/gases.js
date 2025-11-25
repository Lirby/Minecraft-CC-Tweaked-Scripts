// =============================================
// GAS REGISTRATION — OPTIMIZED
// For Lithium Extraction Chain
// =============================================

StartupEvents.registry('mekanism:gas', event => {

    // ---------------------------------------------------
    // STUFE 1 OUTPUT — Pre-Washed Nuclear Waste
    // ---------------------------------------------------
    event.create('pre_washed_nuclear_waste')
        .displayName('Pre-Washed Nuclear Waste')
        .color(0x6C6C6C) // dunkles Grau
        .tooltip("Partially cleaned nuclear waste.\nFirst stage of chemical processing.");

    // ---------------------------------------------------
    // STUFE 2 OUTPUT — Nuclear Saline Solution
    // ---------------------------------------------------
    event.create('nuclear_saline_solution')
        .displayName('Nuclear Saline Solution')
        .color(0x7EC8D9) // kühles hellblau
        .tooltip("A brine-stabilized nuclear solution.\nContains extractable light ions like lithium.");

    // ---------------------------------------------------
    // STUFE 3 OUTPUT — Fluorinated Nuclear Saline Slurry
    // ---------------------------------------------------
    event.create('fluorinated_nuclear_saline_slurry')
        .displayName('Fluorinated Nuclear Saline Slurry')
        .color(0x4FA090) // grünlich-fluoriert
        .tooltip("Fluorite-reacted slurry.\nContains lithium bound as fluoride compounds.");

    // ---------------------------------------------------
    // STUFE 4 OUTPUT — Purified Saline Fluoride Slurry
    // ---------------------------------------------------
    event.create('purified_saline_fluoride_slurry')
        .displayName('Purified Saline Fluoride Slurry')
        .color(0xA7E0C8) // klareres grün/blau
        .tooltip("Highly purified fluoride-rich brine.\nSafe for crystallization processes.");

    // ---------------------------------------------------
    // STUFE 6 OUTPUT — Gaseous Lithium Fluoride
    // ---------------------------------------------------
    event.create('gaseous_lithium_fluoride')
        .displayName('Gaseous Lithium Fluoride')
        .color(0xC8F0FF) // sehr hellblau (Gas)
        .tooltip("Lithium fluoride vapor.\nRequires extreme heat for thermal reduction.");

    // ---------------------------------------------------
    // EXTRA GAS — Lava Vapor
    // ---------------------------------------------------
    event.create('lava_vapor')
        .displayName('Lava Vapor')
        .color(0xFF4A00) // Lava-Orange
        .tooltip("Superheated lava vapor.\nUsed for extreme thermal reduction of metal fluorides.");

});
