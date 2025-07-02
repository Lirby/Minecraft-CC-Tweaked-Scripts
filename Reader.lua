local reader = peripheral.wrap("back")

if not reader then
    print("Kein Reader gefunden!")
    return
end

local data = reader.getBlockData()

if data.tank_contents then
    local fluid = data.tank_contents[1]
    if fluid then
        print("Inhalt: " .. fluid.name)
        print("Menge:" .. fluid.amount)
        print("Kapazität: " .. data.tank_capacity[1])
    else
        print("Tank ist leer.")
    end
else
    print("Keine Daten verfügbar.")
end