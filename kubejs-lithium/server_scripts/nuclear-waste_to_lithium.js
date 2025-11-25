// ============================================================================
//  nuclear_to_lithium.js
//  ------------------------------------------
//  Custom Mekanism-Gas-Rezepte via KubeJS
//  Sichtbar in JEI
//  Minecraft 1.16.5 + Mekanism + KubeJS
// ============================================================================

onEvent('recipes', event => {

    // ----------------------------------------------------------------------
    // Gas-IDs aus Mekanism
    // ----------------------------------------------------------------------
    const waste    = 'mekanism:spent_nuclear_waste';
    const hcl      = 'mekanism:hydrogen_chloride';
    const brine    = 'mekanism:brine';
    const oxygen   = 'mekanism:oxygen';
    const lithium  = 'mekanism:lithium';

    // ----------------------------------------------------------------------
    // Item-IDs
    // ----------------------------------------------------------------------
    const fluorite = 'mekanism:fluorite_gem';


    // =========================================================================
    // 1) PRESSURIZED REACTION CHAMBER (PRC)
    //
    //    Spent Nuclear Waste (Gas)
    //    + Hydrogen Chloride (Gas)
    //    + Fluorite Dust (Item)
    //    → Brine Gas
    //
    //    WICHTIG:
    //    • Nur GasOutput
    //    • Kein fluidOutput
    //    • Kein itemOutput
    //    → Nur DANN zeigt JEI es korrekt an
    // =========================================================================

    event.custom({
        type: 'mekanism:reaction',

        itemInput: {
            ingredient: { item: fluorite }
        },

        gasInput: [
            { gas: waste, amount: 500 }, // Waste Gas
            { gas: hcl,   amount: 250 }  // HCl Gas
        ],

        gasOutput: {
            gas: brine,
            amount: 500
        }
    })
    .id('custom:mekanism/waste_to_brine');



    // =========================================================================
    // 2)
