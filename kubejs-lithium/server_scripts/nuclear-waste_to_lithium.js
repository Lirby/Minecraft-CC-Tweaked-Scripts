onEvent('recipes', event => {

    const waste    = 'mekanism:spent_nuclear_waste';
    const hcl      = 'mekanism:hydrogen_chloride';
    const brine    = 'mekanism:brine';
    const oxygen   = 'mekanism:oxygen';
    const lithium  = 'mekanism:lithium';
    const fluorite = 'mekanism:fluorite_gem';

    // =====================================================================
    // 1) PRESSURIZED REACTION CHAMBER
    // =====================================================================
    event.custom({
        type: 'mekanism:reaction',

        itemInput: {
            ingredient: { item: fluorite }
        },

        // ❗ WICHTIG: Keine Arrays, sondern zwei getrennte Felder
        gasInput: {
            amount: 500,
            gas: waste
        },

        gasInput2: {
            amount: 250,
            gas: hcl
        },

        gasOutput: {
            gas: brine,
            amount: 500
        }
    })
    .id('custom:mekanism/waste_to_brine');



    // =====================================================================
    // 2) CHEMICAL INFUSER
    // =====================================================================
    event.custom({
        type: 'mekanism:chemical_infusing',

        leftInput: {
            gas: brine,
            amount: 500
        },

        rightInput: {
            gas: oxygen,
            amount: 250
        },

        output: {
            gas: lithium,
            amount: 100
        }
    })
    .id('custom:mekanism/brine_to_lithium');

});
