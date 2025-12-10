-- ore.lua
-- Batch-Steuerung für Slurries aus AE2 -> Mekanism Chemical Tank
-- 16 Crystallizer -> 3200 mB pro Batch

-------------------------
-- Einstellungen
-------------------------

local NUM_CRYST = 16
local MB_PER_CRYST = 200
local BATCH_SIZE = NUM_CRYST * MB_PER_CRYST   -- = 3200

local TANK_EMPTY_THRESHOLD = 50   -- unter 50 mB betrachten wir den Tank als "leer"
local LOOP_SLEEP = 2              -- Sekunden zwischen den Checks
local EXPORT_TARGET = "right"     -- Seite der ME-Bridge, an der der Tank/Tube sitzt

-------------------------
-- Peripherals finden
-------------------------

local me = peripheral.find("meBridge")
if not me then
    error("Keine meBridge gefunden! Ist die Bridge mit Modem am Computer?")
end

local tank = peripheral.find("basicChemicalTank")
if not tank then
    tank = peripheral.wrap("basicChemicalTank_1")
end
if not tank then
    error("Kein basicChemicalTank gefunden! Tank mit Modem verbinden.")
end

print("ME Bridge: " .. peripheral.getName(me))
print("Chemical Tank: " .. peripheral.getName(tank))
print("Batch-Größe: " .. BATCH_SIZE .. " mB")

-------------------------
-- passende list*/export*-Funktionen suchen
-------------------------

-- 1) list-Funktion (Chemicals/Fluids)
local listFuncName = nil
local listCandidates = { "listChemicals", "listFluids", "listFluid" }

for _, name in ipairs(listCandidates) do
    if type(me[name]) == "function" then
        listFuncName = name
        break
    end
end

if not listFuncName then
    error("meBridge hat weder listChemicals, listFluids noch listFluid – Version zu alt für dieses Script.")
end

print("Nutze ME-Bridge-Funktion: " .. listFuncName .. "() für Ressourcenliste")

-- 2) export-Funktion (Chemicals/Fluids)
local exportFuncName = nil
local exportCandidates = { "exportChemical", "exportFluid" }

for _, name in ipairs(exportCandidates) do
    if type(me[name]) == "function" then
        exportFuncName = name
        break
    end
end

if not exportFuncName then
    error("meBridge hat weder exportChemical noch exportFluid – kann nichts exportieren.")
end

print("Nutze ME-Bridge-Funktion: " .. exportFuncName .. "() für Export")

-------------------------
-- Hilfsfunktionen
-------------------------

-- Tank-Füllstand lesen
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

-- Alle Chemicals/Fluids aus ME holen
local function listResources()
    -- Versuche erst mit Filter-Tabelle, wenn das crasht dann ohne
    local ok, res, err = pcall(me[listFuncName], me, {})
    if not ok then
        ok, res, err = pcall(me[listFuncName], me)
        if not ok then
            print("Fehler beim Aufruf von " .. listFuncName .. ": " .. tostring(res))
            return {}
        end
    end

    -- ältere Versionen: nur Tabelle, neuere: table,err
    if type(res) == "table" then
        return res
    elseif type(err) == "table" then
        return err
    else
        return {}
    end
end

-- Slurry mit >= BATCH_SIZE finden
local function pickSlurry()
    local resources = listResources()
    local best = nil

    for _, chem in pairs(resources) do
        -- typische Felder: name, amount, displayName
        if chem.name and chem.amount and chem.amount >= BATCH_SIZE then
            -- Nur Mekanism-Slurries
            if string.find(chem.name, "slurry", 1, true) then
                if not best or chem.amount > best.amount then
                    best = chem
                end
            end
        end
    end

    return best
end

-- Einen Batch exportieren
local function exportBatch(chem)
    local filter = {
        name  = chem.name,
        count = BATCH_SIZE
    }

    local display = chem.displayName or chem.name or "unbekannt"
    print(("Exportiere %d mB von %s (%s)"):format(BATCH_SIZE, display, chem.name or "?"))

    local ok, res, err = pcall(me[exportFuncName], me, filter, EXPORT_TARGET)
    if not ok then
        print("Lua-Fehler beim Export: " .. tostring(res))
        return false
    end

    -- neuere Versionen: { exportedCount, errString }
    if type(res) == "table" then
        local exported = res[1]
        local e = res[2]
        if not exported or exported == 0 then
            print("Export hat nichts bewegt: " .. tostring(e))
            return false
        end
    end

    return true
end

-------------------------
-- Hauptloop
-------------------------

while true do
    local amount, name = getTankAmount()

    if amount <= TANK_EMPTY_THRESHOLD then
        -- Tank ist praktisch leer => neuer Batch erlaubt
        local chem = pickSlurry()
        if chem then
            exportBatch(chem)
        else
            print("Kein Slurry >= " .. BATCH_SIZE .. " mB im ME-System. Warte...")
            sleep(LOOP_SLEEP)
        end
    else
        -- Tank noch nicht leer
        -- print(("Tank noch befüllt: %d mB (%s)"):format(amount, name or "unbekannt"))
        sleep(LOOP_SLEEP)
    end
end
