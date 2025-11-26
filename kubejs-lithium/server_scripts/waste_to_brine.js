onEvent('recipes', event => {
    const hcl   = 'forge:hydrogen_chloride';
    const waste = 'mekanism:spent_nuclear_waste';
    const flu   = 'mekanism:fluorite_gem';
    const bri   = 'mekanism:brine';
    
    event.custom({
        type: 'mekanism:reaction',
        
        itemInput: {
            ingredient: { item: flu }
        },
        
        fluidInput: {
            tag: hcl,
            amount: 200
        },
        
        gasInput: {
            gas: waste,
            amount: 100
        },
        
        gasOutput: {
            gas: bri,
            amount: 100
        },
        
        duration: 600
    })
    .id('lirby:mekanism/waste_to_brine');
});
