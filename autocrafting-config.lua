-- AE2 Auto-Crafter Konfiguration
-- Einfach Items hinzufügen, bearbeiten oder löschen

return {
    -- Monitor und Bridge Einstellungen
    bridge_side = "bottom",
    monitor_side = "right",
    monitor_scale = 0.5,
    
    -- CPU Name für Auto-Crafting
    cpu_name = "ac",
    
    -- Wartezeit zwischen Updates (in Sekunden)
    update_interval = 5,
    
    -- Minimale Wartezeit zwischen Crafting-Jobs für dasselbe Item (in Sekunden)
    craft_cooldown = 30,
    
    -- Items die überwacht werden sollen
    -- Format: {name = "mod:item_id", target = Anzahl, displayName = "Anzeigename"}
    items = {
        {name = "minecraft:glass", target = 512, displayName = "Glass"},
        {name = "minecraft:stick", target = 1024, displayName = "Stick"},
        {name = "mekanism:enriched_redstone", target = 512, displayName = "Enriched Redstone"},
        {name = "mekanism:enriched_carbon", target = 512, displayName = "Enriched Carbon"},
        {name = "mekanism:enriched_diamond", target = 128, displayName = "Enriched Diamond"},
        {name = "appliedenergistics2:calculation_processor", target = 4096, displayName = "Calculation Processor"},
        {name = "appliedenergistics2:engineering_processor", target = 4096, displayName = "Engineering Processor"},
        {name = "appliedenergistics2:logic_processor", target = 4096, displayName = "Logic Processor"},
        {name = "mekanism:alloy_infused", target = 1024, displayName = "Infused Alloy"},
        {name = "mekanism:alloy_reinforced", target = 512, displayName = "Reinforced Alloy"},
        {name = "mekanism:alloy_atomic", target = 128, displayName = "Atomic Alloy"},
        {name = "appliedenergistics2:silicon", target = 4096, displayName = "Silicon"},
        {name = "appliedenergistics2:fluix_crystal", target = 1024, displayName = "Fluix Crystal"},
        {name = "appliedenergistics2:purified_fluix_crystal", target = 256, displayName = "Pure Fluix Crystal"},
        {name = "appliedenergistics2:fluix_dust", target = 256, displayName = "Fluix Dust"},
        {name = "minecraft:oak_planks", target = 512, displayName = "Oak Planks"},
        
        -- Weitere Items hier hinzufügen:
        -- {name = "mod:item", target = 100, displayName = "Mein Item"},
    }
}