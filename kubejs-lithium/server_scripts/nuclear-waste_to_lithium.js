// ============================================================================
//  nuclear_to_lithium.js
//  Mekanism custom processing chain:
//     Spent Nuclear Waste → Brine Gas → Lithium Gas
//  JEI-compatible recipe registration via KubeJS
//  Minecraft 1.16.5 + KubeJS + Mekanism
// ============================================================================

onEvent('recipes', event => {

    // -------------------------------------------------------------
    // GASE - Mekanism Gas IDs
    // -------------------------------------------------------------
    const waste      = 'mekanism:spent_nuclear_waste';
    const hcl        = 'mekanism:hydrogen_chloride';
    const brine      = 'mekanism:brine';
    const oxygen     = 'mekanism:oxygen';
    const lithium    = 'mekanism:lithium';

    // -------------------------------------------------------------
    // ITEM - Fluorite Dust (Reagenz)
    // -------------------------------------------------------------
    const fluorite   = 'mekanism:fluorite_gem';


    // =====================================================================
    // 1) PRESSURIZED REACTION CHAMBER
    //    Spent Nuclear Waste + HCl + Fluorite Dust → Brine Gas
    //
    //    Maschine: mekanism:reaction
    //    JEI Kategorie: Pressurized Reaction Chamber (funktioniert!)
    // =====================================================================

    event.custom({
        type: 'mekanism:reaction',
        itemInput: {
            ingredient: { item: fluorite }
        },
        gasInput: [
            { amount: 500, gas: waste },  // 500 mB Waste Gas
            { amount: 250, gas: hcl }     // 250 mB HCl
        ],
        gasOutput: {
            gas: brine,
            amount: 500                  // 500 mB Brine Gas
        },
        // PRC verlangt dieses Feld — wir setzen es auf „Werthaltig: null”
        fluidOutput: {
            fluid: 'minecraft:water',
            amount: 0
        }
    }).id('custom:mekanism/waste_to_brine');



    // =====================================================================
    // 2) CHEMICAL INFUSER
    //    Brine Gas + Oxygen Gas → Lithium Gas
    //
    //    Maschine: mekanism:chemical_infusing
    //    JEI Kategorie: Chemical Infuser (sichtbar!)
    // =====================================================================

    event.custom({
        type: 'mekanism:chemical_infusing',
        leftInput: {
            amount: 500,
            gas: brine                 // 500 mB Brine Gas
        },
        rightInput: {
            amount: 250,
            gas: oxygen               // 250 mB O₂ Gas
        },
        output: {
            gas: lithium,
            amount: 100               // 100 mB Lithium Gas
        }
    }).id('custom:mekanism/brine_to_lithium');

});
