local reactor = peripheral.wrap("fissionReactorLogicAdapter_0")
local monitor = peripheral.wrap("top")
local tanks = {
    {side = "left", reader = peripheral.wrap("left"), capacity = 8192000 },
    {side = "right", reader = peripheral.wrap("right"), capacity = 8192000},
}

-- Monitor
monitor.setTextScale(1)
monitor.setBackgroundColor(colors.black)
monitor.clear()

-- Chemical tank reader
function readChemicalTank(reader, defaultCap)
    if not reader then
        return { amount = 0, gasName = "Leer", capacity = defaultCap}
    end
    local data = reader.getBlockData()
    if not data or not data.GasTanks or not data.GasTanks[0] then
        return { amount = 0, gasName = "Leer", capacity = defaultCap }
    end
    local gasTank = data.GasTanks[0]
    local stored = gasTank.stored
    return {
        amount = (stored and stored.amount) or 0,
        gasName = (stored and stored.gas) or "Leer",
        capacity = gasTank.capacity or defaultCap,
    }
end

--color for monitor
local function statusColor(status)
    if status == true then 
        return colors.green
    else
        return colors.red
    end
end

while true do 
    monitor.clear()
    monitor.setCursorPos(1,1)
    monitor.setTextColor(colors.cyan)
    monitor.write("------ Fission Reactor Dashboard -------")
    
    -- Data by Reactor
    local status = reactor.getStatus()
    local temp = reactor.getTemperature()
    local coolantData = reactor.getCoolant() or { amount = 0 }
    local coolant = coolantData.amount
    local maxCoolant = 17500000
    local coolantPercent = (coolant / maxCoolant) * 100

    -- Data by Ultimate Tank
    local totalAmt, totalCap = 0, 0
    for i, t in ipairs(tanks) do
        local td = readChemicalTank(t.reader, t.capacity)
        t.data = td
        totalAmt = totalAmt + td.amount
        totalCap = totalCap + td.capacity
    end
    local fillPct = (totalCap>0) and (totalAmt/totalCap)*100 or 0
    local tankFull = fillPct >= 99
    local tankEmpty = fillPct <= 1

    -- Display status, Temp and Coolant
    monitor.setCursorPos(1,3)
    monitor.setTextColor(colors.white)
    monitor.write("Status: ")
    if status then 
        monitor.setTextColor(colors.green)
        monitor.write("AKTIVER BETRIEB")
    else
        monitor.setTextColor(colors.red)
        monitor.write("OFFLINE")
    end
    
    monitor.setCursorPos(1,4)
    monitor.setTextColor(colors.white)
    monitor.write(string.format("Temperatur: %.1f K", temp))
    
    monitor.setCursorPos(1,5)
    monitor.write(string.format("Kühlmittel: %d / %d mB (%.1f%%)", coolant, maxCoolant, coolantPercent))
    
    --Show both Tanks
    monitor.setCursorPos(1,6)
    monitor.write(string.format(
        "Tanks gesamt: %d / %d mB (%.1f%%)",
        totalAmt, totalCap, fillPct
    ))

    for i, t in ipairs(tanks) do
        monitor.setCursorPos(1, 6 + i)
        monitor.write(string.format(
            "%s: %s - %d / %d mB",
            t.side, t.data.gasName, t.data.amount, t.data.capacity
        ))
    end


    if status == true and (temp > 900 or coolantPercent <40 or tankFull) then
        redstone.setOutput("back", false)
    elseif status == false and temp < 700 and coolantPercent > 75 and tankEmpty then
        redstone.setOutput("back", true)
    end

    sleep(1)
end
    
