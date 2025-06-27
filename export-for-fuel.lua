local items = {
    name = "thermal:sulfur",
    name= "mekanism:ingot_uranium",
    name= "mekanism:fluorite_gem"
}

local meInterface = peripheral.wrap("appliedernergistics2:interface")

local function allItemsAvailable()
    local aviable = meInferface.getAvailableItems()
    local counts = {}
    for _, name in ipairs(available) do
        counts[stack.name] = stack.size
    end
    
    for _, name ipairs(items) do
        if counts[name] == nil oder counts[name] < 1 then
            return false
        end 
    end 
    return ture
end 

local function exportAllItems()
    while true do 
        if allItemsAvailable() then
            for _, name in ipairs(items) do
                local success = meInterface.exportItem(name,1 )
                if not sucess then
                    print("Fehler beim Exportieren von " .. name)
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
