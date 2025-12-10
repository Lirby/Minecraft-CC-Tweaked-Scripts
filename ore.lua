-------------------------------
-- Slurry Batch Controller
-- 16 Crystalizer = 3200 mB
-- Tank  = blockReader_4
-- Tube  = blockReader_5
-- Tube Redstone auf "right"
-------------------------------

local BATCH = 3200                 -- mB pro Batch
local REDSTONE_SIDE = "right"      -- Tube Redstone-Seite
local CHECK_DELAY = 0.2            -- Sekunden zwischen Checks

-- Peripherals
local tankReader = peripheral.wrap("blockReader_4")
local tubeReader = peripheral.wrap("blockReader_5")

if not tankReader or not tubeReader then
    error("BlockReader_4 oder BlockReader_5 nicht gefunden!")
end

-----------------------------------------
-- Hilfsfunktionen
-----------------------------------------

-- Menge im Chemical Tank lesen
local function tankAmount()
    local data = tankReader.getBlockData()
    if not data or not data.ChemicalTanks then return 0 end
    local c = data.ChemicalTanks[1]
    if not c then return 0 end
    return c.amount or 0
end

-- Menge in der ersten Tube lesen
local function tubeAmount()
    local data = tubeReader.getBlockData()
    if data and data.contents and data.contents.amount then
        return data.contents.amount
    end
    return 0
end

-- Tube öffnen (Slurry darf fließen)
local function openTube()
    redstone.setOutput(REDSTONE_SIDE, false)
end

-- Tube schließen (Slurry STOP)
local function closeTube()
    redstone.setOutput(REDSTONE_SIDE, true)
end

-----------------------------------------
-- Hauptloop
-----------------------------------------

print("Starte Slurry Batch Controller...")
print("Batch = "..BATCH.." mB")
print("Redstone auf Tube = "..REDSTONE_SIDE)

while true do

    ------------------------------------------------------
    -- 1) Warten bis Tank + Pipe komplett LEER sind
    ------------------------------------------------------
    while tankAmount() > 0 or tubeAmount() > 0 do
        closeTube()   -- Sicherheit: wir wollen NICHT mischen
        sleep(CHECK_DELAY)
    end

    print("Tank & Tube leer → nächster Batch bereit.")

    ------------------------------------------------------
    -- 2) Tube ÖFFNEN → Slurry fließt in den Tank
    ------------------------------------------------------
    openTube()
    print("Tube geöffnet – Slurry fließt...")

    ------------------------------------------------------
    -- 3) Warten bis EXACT BATCH mB erreicht sind
    ------------------------------------------------------
    while tankAmount() < BATCH do
        -- wenn Slurry langsam kommt → warten
        sleep(CHECK_DELAY)
    end

    ------------------------------------------------------
    -- 4) Batch erreicht → Tube SCHLIESSEN
    ------------------------------------------------------
    closeTube()
    print("Batch erreicht ("..tankAmount().." mB). Tube geschlossen.")

    ------------------------------------------------------
    -- 5) Warten bis Crystalizer den Tank komplett LEEREN
    ------------------------------------------------------
    while tankAmount() > 0 or tubeAmount() > 0 do
        sleep(CHECK_DELAY)
    end

    print("Batch verarbeitet. Wiederhole.")
end
