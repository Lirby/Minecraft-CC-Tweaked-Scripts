-- AE2 Auto-Crafter für CC:Tweaked mit Lua 5.2
-- ME Bridge unten, Monitor rechts

local bridge = peripheral.wrap("bottom")
local monitor = peripheral.wrap("right")

-- Items die überwacht werden sollen
local items = {
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
    {name = "minecraft:oak_planks", target = 512, displayName = "Oak Planks"}
}

-- Funktion um Item-Anzahl zu prüfen
local function getItemCount(itemName)
    local itemList = bridge.listItems()
    for _, item in pairs(itemList) do
        if item.name == itemName then
            return item.amount
        end
    end
    return 0
end

-- Tabelle für laufende Crafting-Jobs mit Zeitstempel
local activeCrafts = {}

-- Funktion um Crafting zu starten
local function craftItem(itemName, amount)
    local item = bridge.getItem({name = itemName})
    if item and item.isCraftable then
        -- Nur CPUs mit Namen "ac" verwenden
        bridge.craftItem({name = itemName, count = amount}, "ac")
        activeCrafts[itemName] = os.clock()
        return true
    end
    return false
end

-- Funktion um zu prüfen ob noch Crafting-Jobs laufen
local function isCrafting(itemName)
    if not activeCrafts[itemName] then
        return false
    end
    
    -- Mindestens 30 Sekunden warten seit letztem Craft-Start
    local timeSinceStart = os.clock() - activeCrafts[itemName]
    if timeSinceStart < 30 then
        return true
    end
    
    local cpus = bridge.getCraftingCPUs()
    for _, cpu in pairs(cpus) do
        -- Nur CPUs mit Namen "ac" prüfen
        if cpu.name == "ac" and cpu.isBusy then
            -- CPU ist noch beschäftigt, Zeit zurücksetzen
            activeCrafts[itemName] = os.clock()
            return true
        end
    end
    
    -- Kein CPU mehr beschäftigt und Wartezeit vorbei
    activeCrafts[itemName] = nil
    return false
end

-- Monitor Setup
local function setupMonitor()
    monitor.setTextScale(0.5)
    monitor.clear()
    monitor.setCursorPos(1, 1)
end

-- Display auf Monitor aktualisieren
local function updateDisplay()
    setupMonitor()
    monitor.setTextColor(colors.white)
    monitor.write("======== AE2 Auto-Crafter ========")
    monitor.setCursorPos(1, 2)
    monitor.write("----------------------------------")
    
    local line = 3
    for _, itemConfig in ipairs(items) do
        local current = getItemCount(itemConfig.name)
        local target = itemConfig.target
        
        monitor.setCursorPos(1, line)
        
        -- Farbe setzen
        if current >= target then
            monitor.setTextColor(colors.lime)
        else
            monitor.setTextColor(colors.red)
        end
        
        -- Anzeige formatieren
        local text = string.format("%s: %d/%d", itemConfig.displayName, current, target)
        monitor.write(text)
        
        line = line + 1
    end
    
    monitor.setTextColor(colors.white)
end

-- Hauptschleife
local function main()
    print("AE2 Auto-Crafter gestartet...")
    print("Drücke Strg+T zum Beenden")
    
    while true do
        -- Display aktualisieren
        updateDisplay()
        
        -- Items prüfen und ggf. craften
        for _, itemConfig in ipairs(items) do
            local current = getItemCount(itemConfig.name)
            local target = itemConfig.target
            
            -- Nur craften wenn unter Ziel UND kein Job läuft
            if current < target and not isCrafting(itemConfig.name) then
                local needed = target - current
                print("Crafte " .. needed .. "x " .. itemConfig.displayName)
                local success = craftItem(itemConfig.name, needed)
                if not success then
                    print("Warnung: " .. itemConfig.displayName .. " kann nicht gecraftet werden!")
                end
            end
        end
        
        -- Kurze Pause vor nächstem Update
        sleep(5)
    end
end

-- Fehlerbehandlung
local function run()
    local success, err = pcall(main)
    if not success then
        print("Fehler: " .. tostring(err))
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.setTextColor(colors.red)
        monitor.write("FEHLER!")
        monitor.setCursorPos(1, 2)
        monitor.write(tostring(err))
    end
end

-- Programm starten
run()

