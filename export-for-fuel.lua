local items = {
    "thermal:sulfur",
    "mekanism:ingot_uranium",
    "mekanism:fluorite_gem"
}

local meInterface = peripheral.wrap("left")

local function allItemsAvailable()
    local available = meInterface.list()
    local counts = {}
    for _, stack in pairs(available) do
        counts[stack.name] = stack.count
    end
    
    for _, name in ipairs(items) do
        if counts[name] == nil or counts[name] < 1 then
            return false
        end 
    end 
    return true
end 

local function exportAllItems()
    while true do 
        if allItemsAvailable() then
            for _, name in ipairs(items) do
                local available = meInterface.list()
                local slot = nil
                for s, stack in pairs(available) do
                    if stack.name == name then
                        slot = s
                        break
                end
            end
                if slot then
                    local success = meInterface.pushItems("left")
                    if not success then
                        print("Fehler beim Exportieren von " .. name)
                        return
                    end
                else
                    print("Item " .. name .. " nicht gefunden im ME System")
                    return
                end
            end
            print("Alle 3 Items exportiert.")
            sleep(1)
        else
            print("Mindestens ein Item fehlt, warte bis alle wieder da sind")
            repeat
                sleep(5)
            until allItemsAvailable()
            print("Alle Items sind wieder verfügbar. Der Export läuft jetzt wieder")
        end
    end
end

exportAllItems()
