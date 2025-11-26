onEvent('recipes', event => {
    const oxy   = 'mekanism:oxygen';
    const bri   = 'mekansim:birne';
    const lith  = 'mekanism:lithum';
    
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
            gas: lithium,
            amount: 100
        }

    })
    .id('custom:mekanism/brine_to_lithium');
});