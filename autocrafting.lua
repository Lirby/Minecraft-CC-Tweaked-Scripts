-- AE2 Auto-Crafter für CC:Tweaked mit Lua 5.2
-- ME Bridge unten, Monitor rechts

local bridge = peripheral.wrap("bottom")
local monitor = peripheral.wrap("right")

-- Items die überwacht werden sollen
local items = {
    {name = "minecraft:glass", target = 500, displayName = "Glass"},
    {name = "minecraft:iron_ingot", target = 300, displayName = "Iron Ingot"},
    {name = "minecraft:stick", target = 1000, displayName = "Stick"},
    -- Füge hier weitere Items hinzu
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

-- Funktion um Crafting zu starten
local function craftItem(itemName, amount)
    local item = bridge.getItem({name = itemName})
    if item and item.isCraftable then
        bridge.craftItem({name = itemName, count = amount})
        return true
    end
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
    monitor.write("=== AE2 Auto-Crafter ===")
    monitor.setCursorPos(1, 2)
    monitor.write("------------------------")
    
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
            
            if current < target then
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