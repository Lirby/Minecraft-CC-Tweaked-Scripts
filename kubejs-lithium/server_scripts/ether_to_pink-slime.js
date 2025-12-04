onEvent('recipes', event => {
  const cinna = 'thermal:cinnabar'
  const ether = 'industrialforegoing:ether_gas'
  const pink = 'industrialforegoing:pink_slime'

  event.recipes.thermal.brewer(
    Fluid.of(pink, 1000),
    [
      Fluid.of(ether, 500),
      '4x ' + cinna
    ]
  ).energy(12000).id('lirby:thermal/ether_to_pinkslime')
})
