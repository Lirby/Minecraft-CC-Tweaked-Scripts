-- ore.lua
-- Steuerung der Slurry-Batches aus AE2 -> Mekanism Chemical Tank
-- Benötigt: CC:Tweaked, Advanced Peripherals (meBridge), AE2 Additions, Mekanism Chemical Tank

-------------------------
-- Einstellungen
-------------------------

-- 16 Crystallizer * 200 mB = 3200 mB pro Batch
local BATCH_SIZE = 3200          -- mB pro Export
local TANK_EMPTY_THRESHOLD = 50  -- Tank gilt als "leer" unter diesem Wert
local LOOP_SLEEP = 2             -- Sekunden Pause zwischen den Checks

-- Seite des ME Bridge, an der Tank/Pipe sitzt
-- ANPASSEN falls nötig: "left", "right", "top", "bottom", "front", "back"
local EXPORT_TARGET = "right"

-------------------------
-- Peripherals finden
-------------------------

local me = peripheral.find("meBridge")
if not me then
    error("meBridge nicht gefunden (ist sie mit Modem am Computer angeschlossen?).")
end

local tank = peripheral.find("basicChemicalTank") or peripheral.wrap("basicChemicalTank_1")
if not tank then
    error("basicChemicalTank nicht gefunden (Computer/Modem direkt am Tank?).")
end

-------------------------
-- Hilfsfunktionen
-------------------------

-- Suche passende Funktion, um alle Chemicals/Fluids zu bekommen
local listChemicalsFn = me.listChemicals or me.getChemicals or me.listFluids or me.getFluids
if not listChemicalsFn then
    error("meBridge hat weder listChemicals/getChemicals noch listFluids/getFluids – Version zu alt?")
end

-- Suche passende Export-Funktion (Chemicals oder Fluids)
local exportChemFn = me.exportChemical or me.exportFluid
if not exportChemFn then
    error("meBridge hat weder exportChemical noch exportFluid – kann nichts exportieren.")
end

-- Inhalt des Mekanism Chemical Tanks lesen
local function getTankAmount()
    local ok, stored = pcall(function()
        if tank.getStored then
            return tank.getStored()
        elseif tank.getContents then
            return tank.getContents()
        else
            return {}
        end
    end)

    if not ok or type(stored) ~= "table" then
        return 0, nil
    end

    local amount = stored.amount or 0
    local name = stored.name
    return amount, name
end

-- Wähle ein Chemical aus dem ME-System, das genug Menge hat (>= BATCH_SIZE)
local function pickChemical()
    local chemicals, err = listChemicalsFn({})
    if not chemicals then
        print("Fehler bei Chemical-Liste: " .. tostring(err))
        return nil
    end

    local best = nil

    for _, chem in pairs(chemicals) do
        -- Erwartete Felder: chem.name, chem.amount, chem.displayName
        if chem.name and chem.amount and chem.amount >= BATCH_SIZE then
            -- optional: auf Slurry einschränken
            if chem.name:find("slurry") then
                if not best or chem.amount > best.amount then
                    best = chem
                end
            end
        end
    end

    return best
end

-------------------------
-- Start-Info
-------------------------

print("ME Bridge gefunden.")
print("Chemical Tank gefunden.")
print("Batch-Größe: " .. BATCH_SIZE .. " mB")
print("Export-Ziel: " .. EXPORT_TARGET)
print("Warte auf freien Tank...")

-------------------------
-- Haupt-Loop
-------------------------

while true do
    local amount, currentName = getTankAmount()

    if amount <= TANK_EMPTY_THRESHOLD then
        -- Tank ist quasi leer, neuer Batch darf raus
        local chem = pickChemical()

        if chem then
            local display = chem.displayName or chem.name or "unbekannt"
            print(("Exportiere %d mB %s (%s)"):format(BATCH_SIZE, display, chem.name or "?"))

            -- Filter: exakt BATCH_SIZE mB von genau diesem Slurry
            local filter = {
                name = chem.name,
                count = BATCH_SIZE
            }

            local ok, resOrErr = pcall(function()
                return exportChemFn(filter, EXPORT_TARGET)
            end)

            if not ok then
                print("Export-Fehler (Lua): " .. tostring(resOrErr))
            else
                local exported, err = resOrErr[1], resOrErr[2]
                if not exported then
                    print("Export fehlgeschlagen: " .. tostring(err))
                end
            end
        else
            -- Kein Chemical mit genug Menge
            -- Kurze Meldung, dann wieder warten
            -- (Nicht spammen, wenn du willst, kommentier die nächste Zeile aus)
            print("Kein Slurry >= " .. BATCH_SIZE .. " mB im ME-System gefunden.")
            sleep(LOOP_SLEEP)
        end
    else
        -- Tank ist noch voll / Pipes laufen noch leer
        -- Wenn dir das zu spammy ist, diese Zeile auskommentieren
        -- print(("Tank noch voll: %d mB (%s)"):format(amount, currentName or "leer"))
        sleep(LOOP_SLEEP)
    end
end
