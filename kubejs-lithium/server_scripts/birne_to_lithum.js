onEvent('recipes', event => {
    const oxy   = 'mekanism:oxygen';
    const bri   = 'mekansim:brine';
    const lith  = 'mekanism:lithium';
    
    event.custom({
        type: 'mekanism:chemical_infusing',
        
        leftInput: {
            gas: bri,
            amount: 200
        },
        
        rightInput: {
            gas: oxy,
            amount: 100
        },
        
        output: {
            gas: lith,
            amount: 100
        }

    })
    .id('lirby:mekanism/brine_to_lithium');
});
