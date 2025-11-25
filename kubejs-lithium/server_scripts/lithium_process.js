ServerEvents.recipes(event => {

    // ---------------------------------------------
    // STUFE 1 — Pre-Washed Nuclear Waste
    // ---------------------------------------------
    event.recipes.mekanism.chemical_washer(
        {
            gas: { gas: "kubejs:pre_washed_nuclear_waste", amount: 15 }
        },
        {
            slurry: { slurry: "mekanism:spent_nuclear_waste", amount: 15 }
        },
        {
            gasInput: { gas: "mekanism:water_vapor", amount: 15 }
        }
    ).id("lithium_stufe1");


    // ---------------------------------------------
    // STUFE 2 — Nuclear Saline Solution
    // ---------------------------------------------
    event.recipes.mekanism.chemical_infuser(
        {
            gas: { gas: "kubejs:pre_washed_nuclear_waste", amount: 15 }
        },
        {
            gas: { gas: "mekanism:brine", amount: 20 }
        },
        {
            gasOutput: { gas: "kubejs:nuclear_saline_solution", amount: 20 }
        }
    ).id("lithium_stufe2");


    // ---------------------------------------------
    // STUFE 3 — Fluorinated Nuclear Saline Slurry
    // ---------------------------------------------
    event.recipes.mekanism.chemical_dissolution(
        {
            gas: { gas: "kubejs:nuclear_saline_solution", amount: 20 }
        },
        "mekanism:fluorite_gem",
        {
            slurry: { slurry: "kubejs:fluorinated_nuclear_saline_slurry", amount: 25 }
        }
    ).id("lithium_stufe3");


    // ---------------------------------------------
    // STUFE 4 — Purified Saline Fluoride Slurry
    // ---------------------------------------------
    event.recipes.mekanism.chemical_washer(
        {
            slurry: { slurry: "kubejs:fluorinated_nuclear_saline_slurry", amount: 25 }
        },
        {
            fluidInput: { fluid: "minecraft:water", amount: 100 }
        },
        {
            slurryOutput: { slurry: "kubejs:purified_saline_fluoride_slurry", amount: 20 }
        }
    ).id("lithium_stufe4");


    // ---------------------------------------------
    // STUFE 5 — Crystallized Lithium Fluoride
    // ---------------------------------------------
    event.recipes.mekanism.crystallizing(
        "kubejs:crystallized_lithium_fluoride",
        {
            slurry: { slurry: "kubejs:purified_saline_fluoride_slurry", amount: 20 }
        }
    ).id("lithium_stufe5");


    // ---------------------------------------------
    // STUFE 6 — Gaseous Lithium Fluoride
    // ---------------------------------------------
    event.recipes.mekanism.oxidizing(
        { item: "kubejs:crystallized_lithium_fluoride" },
        { gas: "kubejs:gaseous_lithium_fluoride", amount: 10 }
    ).id("lithium_stufe6");


    // ---------------------------------------------
    // STUFE 7 — Lithium Gas (ENDPRODUKT)
    // ---------------------------------------------
    event.recipes.mekanism.chemical_infuser(
        {
            gas: { gas: "kubejs:gaseous_lithium_fluoride", amount: 10 }
        },
        {
            gas: { gas: "kubejs:lava_vapor", amount: 10 }
        },
        {
            gasOutput: { gas: "mekanism:lithium", amount: 10 }
        }
    ).id("lithium_stufe7");


    // ---------------------------------------------
    // LAVA VAPOR HERSTELLUNG
    // ---------------------------------------------
    event.recipes.mekanism.rotary(
        {
            fluidInput: { fluid: "minecraft:lava", amount: 10 }
        },
        {
            gasOutput: { gas: "kubejs:lava_vapor", amount: 10 }
        }
    ).id("lava_vapor_rotary");

});
