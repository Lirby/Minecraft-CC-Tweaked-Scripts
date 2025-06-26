local reactor = peripheral.wrap("fissionReactorLogicAdapter_0")
local monitor = peripheral.wrap("top")

monitor.setTextScale(1)
monitor.setBackgroundColor(colors.black)
monitor.clear()

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
    
    local status = reactor.getStatus()
    local temp = reactor.getTemperature()
    local coolantData = reactor.getCoolant() or { amount = 0 }
    local coolant = coolantData.amount
    local maxCoolant = 17500000
    local coolantPercent = (coolant / maxCoolant) * 100

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
    
    if status == true and (temp > 900 or coolantPercent <40) then
        redstone.setOutput("back", false)
    elseif status == false and temp < 250 and coolantPercent > 75 then
        redstone.setOutput("back", true)
    end

    sleep(1)
end
    
