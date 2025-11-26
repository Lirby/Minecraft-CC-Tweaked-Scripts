onEvent('recipes', event => {
    const hcl   = 'forge:hydrogen_chloride';
    const waste = 'mekanism:nuclear_spent_waste';
    const flu   = 'mekanism:flourite/gem';
    const bri   = 'mekanism:brine';
    
    event.costum({
        type: 'mekanism:reaction',
        
        itemInput: {
            tag: flu,
            amount: 1
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
            gas: birne,
            amount: 100
        }
    })
    .id('lirby:mekanism/waste_to_birne');
});