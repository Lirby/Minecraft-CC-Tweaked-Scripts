-- AE2 Auto-Crafter für CC:Tweaked mit Lua 5.2
-- Lädt Konfiguration aus autocraft_config.lua

-- Config und Peripherals
local config
local bridge
local monitor
local items

-- Tabelle für laufende Crafting-Jobs mit Zeitstempel (bleibt beim Reload erhalten!)
local activeCrafts = {}

-- Funktion um Config neu zu laden
local function loadConfig()
    config = dofile("ac-config.lua")
    bridge = peripheral.wrap(config.bridge_side)
    monitor = peripheral.wrap(config.monitor_side)
    items = config.items
end

-- Erste Config laden
loadConfig()

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
        -- Nur CPUs mit konfiguriertem Namen verwenden
        bridge.craftItem({name = itemName, count = amount}, config.cpu_name)
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
    
    -- Mindestens konfigurierte Zeit warten seit letztem Craft-Start
    local timeSinceStart = os.clock() - activeCrafts[itemName]
    if timeSinceStart < config.craft_cooldown then
        return true
    end
    
    local cpus = bridge.getCraftingCPUs()
    for _, cpu in pairs(cpus) do
        -- Nur CPUs mit konfiguriertem Namen prüfen
        if cpu.name == config.cpu_name and cpu.isBusy then
            -- CPU ist noch beschäftigt, Zeit zurücksetzen
            activeCrafts[itemName] = os.clock()
            return true
        end
    end
    
    -- Kein CPU mehr beschäftigt und Wartezeit vorbei
    activeCrafts[itemName] = nil
    return false
end

-- Monitor Setup (nur einmal beim Start)
local function setupMonitor()
    monitor.setTextScale(config.monitor_scale)
    monitor.clear()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.setCursorPos(1, 1)
    monitor.write("=== AE2 Auto-Crafter ===")
    monitor.setCursorPos(1, 2)
    monitor.write("------------------------")
    
    -- Item-Namen einmalig schreiben
    local line = 3
    for _, itemConfig in ipairs(items) do
        monitor.setCursorPos(1, line)
        monitor.setTextColor(colors.white)
        monitor.write(itemConfig.displayName .. ":")
        line = line + 1
    end
end

-- Display auf Monitor aktualisieren (nur Zahlen)
local function updateDisplay()
    local line = 3
    for _, itemConfig in ipairs(items) do
        local current = getItemCount(itemConfig.name)
        local target = itemConfig.target
        
        -- Position für die Zahlen berechnen
        local nameLength = string.len(itemConfig.displayName) + 2
        monitor.setCursorPos(nameLength, line)
        
        -- Alte Zahlen überschreiben (mit Leerzeichen auffüllen)
        monitor.setTextColor(colors.black)
        monitor.write("                    ")
        
        -- Neue Zahlen schreiben
        monitor.setCursorPos(nameLength, line)
        
        -- Farbe setzen
        if current >= target then
            monitor.setTextColor(colors.lime)
        else
            monitor.setTextColor(colors.red)
        end
        
        -- Zahlen anzeigen
        local text = string.format("%d/%d", current, target)
        monitor.write(text)
        
        line = line + 1
    end
    
    monitor.setTextColor(colors.white)
end

-- Hauptschleife
local function main()
    print("AE2 Auto-Crafter gestartet...")
    print("Konfiguration geladen: " .. #items .. " Items")
    print("Drücke Strg+T zum Beenden")
    
    -- Monitor einmalig initialisieren
    setupMonitor()
    
    local lastItemCount = #items
    
    while true do
        -- Config neu laden
        loadConfig()
        
        -- Monitor nur neu aufbauen wenn sich Items geändert haben
        if #items ~= lastItemCount then
            setupMonitor()
            lastItemCount = #items
            print("Config neu geladen: " .. #items .. " Items")
        end
        
        -- Display aktualisieren (nur Zahlen)
        updateDisplay()
        
        -- Items prüfen und ggf. craften
        for _, itemConfig in ipairs(items) do
            local current = getItemCount(itemConfig.name)
            local target = itemConfig.target
            
            -- Nur craften wenn unter Ziel UND kein Job läuft
            if current < target and not isCrafting(itemConfig.name, current, target) then
                local needed = target - current
                print("Crafte " .. needed .. "x " .. itemConfig.displayName .. " (Ziel: " .. target .. ")")
                local success = craftItem(itemConfig.name, needed, target)
                if not success then
                    print("Warnung: " .. itemConfig.displayName .. " kann nicht gecraftet werden!")
                end
            end
        end
        
        -- Konfigurierte Pause vor nächstem Update
        sleep(config.update_interval)
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

