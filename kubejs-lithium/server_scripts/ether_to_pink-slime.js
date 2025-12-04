onEvent('recipes', event => {
    const cinna = 'thermal:cinnabar'
    const ether = 'industrialforegoing:ether_gas'
    const pink = 'industrialforegoing:pink_slime'

    event.custom({
        type: "thermal:machine_brewer",

        ingredients: [
            { item: cinna },
            { item: cinna },
            { item: cinna },
            { item: cinna }
        ],

        input_fluid: {
            fluid: ether,
            amount: 500
        },

        result: {
            fluid: pink,
            amount: 1000
        },

        energy: 12000
    })
    .id('Lirby:thermal/ether_to_pinkslime')
});