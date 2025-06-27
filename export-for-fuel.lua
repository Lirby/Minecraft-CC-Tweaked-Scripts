local meBridge = peripheral.wrap("left")
local chest = peripheral.wrap("right")

local items = {
    { name = "thermal:sulfur", count = 1 },
    { name = "mekanism:ingot_uranium", count = 1 },
    { name = "mekanism:fluorite", count =1 },
}

local function isItemAvailable(itemName, amount)
    local details = meBridge.getItem({ name = itemName })
    return details and details.amount >= amount
end

while true do
    local allAvailable = true
    
    for _, item in ipairs(items) do
        if not isItemAvailable(item.name, item.count) then
            print("nicht genug vorhanden:" .. item.name .. "Warte auf Nachschub")
            allAvailable = false
            break
        end
    end
    
    if allAvailavle then
        for _, item in ipairs(items) do
            local exported = meBridge.exportItemFormSystem(item, chest)
            if exported then
                print("Exportiert: " .. item.count .. " von " .. item.name)
            else
                print("Fehler beim Export von: " .. item.name)
            end
            sleep(0.5)
        end
        sleep(5)
    else 
        sleep(10)
    end
end
