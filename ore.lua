-- =========================
--  Slurry-Batcher für Mekanism
--  16 Crystalizer -> 3200 mB pro Batch
-- =========================

local NUM_CRYST          = 16       -- Anzahl deiner Crystalizer
local MB_PER_CRYST       = 200      -- Verbrauch pro Tick/Operation
local BATCH_SIZE         = NUM_CRYST * MB_PER_CRYST  -- = 3200 mB

local CHECK_DELAY_EMPTY  = 2        -- Sekunden zwischen Checks wenn Tank nicht leer ist
local WAIT_AFTER_EMPTY   = 5        -- Extra-Wartezeit, nachdem Tank 0 hat (Pipes leer laufen lassen)

-- ==== Peripherals suchen ====

local me = peripheral.find("meBridge")
if not me then
  error("Kein meBridge gefunden! Bitte ME Bridge mit Modem verbinden.")
end

local tank = peripheral.find("basicChemicalTank")
if not tank then
  error("Kein basicChemicalTank gefunden! Tank bitte mit Modem verbinden.")
end

print("ME Bridge gefunden:", peripheral.getName(me))
print("Chemical Tank gefunden:", peripheral.getName(tank))
print("Batch-Größe:", BATCH_SIZE, "mB")

-- ==== Hilfsfunktionen ====

local function getTankInfo()
  local stored = tank.getStored()
  if not stored or not stored.amount then
    return nil, 0
  end
  return stored.name, stored.amount
end

local function isTankEmpty()
  local name, amount = getTankInfo()
  return (not name) or amount == 0
end

-- Optional: Nur Slurries benutzen
local function isSlurryName(name)
  if not name then return false end
  -- Name sieht z.B. so aus: "mekanism:clean_iron_slurry"
  return name:find("slurry", 1, true) ~= nil
end

-- Nächste Chemikalie (Slurry) mit >= BATCH_SIZE aus dem ME suchen
local function findNextChemical()
  -- Leerer Filter -> alle Chemicals
  local chemicals, err = me.listChemicals({})
  if not chemicals then
    print("Fehler bei listChemicals:", err or "unbekannt")
    return nil
  end

  -- listChemicals gibt meist eine Map zurück: key -> { name=..., amount=... }
  for _, chem in pairs(chemicals) do
    if chem.name and chem.amount then
      if isSlurryName(chem.name) and chem.amount >= BATCH_SIZE then
        return chem
      end
    end
  end

  return nil
end

local function exportBatch(chem)
  local filter = {
    name  = chem.name,
    type  = "chemical", -- wichtig: als Mekanism-Chemical interpretieren
    count = BATCH_SIZE  -- genau 3200 mB
  }

  print(("Exportiere %d mB von %s ..."):format(BATCH_SIZE, chem.name))

  -- Zielrichtung: zum Tank hin (relativ zum ME Bridge!)
  -- Wenn dein Tank z.B. rechts vom ME Bridge steht, dann "right" usw.
  local ok, err = me.exportChemical(filter, "right")
  if not ok then
    print("Export fehlgeschlagen:", err or "unbekannt")
  else
    print("Export angestoßen.")
  end
end

-- ==== Hauptloop ====

while true do
  -- 1) Warten bis Tank leer + kurze Nachlaufzeit
  if not isTankEmpty() then
    local name, amount = getTankInfo()
    print(("Tank belegt: %s (%d mB) – warte..."):format(name or "??", amount or 0))
    sleep(CHECK_DELAY_EMPTY)
  else
    -- Tank ist leer -> Pipes noch kurz leer laufen lassen
    print("Tank leer, warte noch", WAIT_AFTER_EMPTY, "Sekunden für Pipes...")
    sleep(WAIT_AFTER_EMPTY)

    -- Sicherstellen, dass Tank immer noch leer ist
    if isTankEmpty() then
      -- 2) Nächsten passenden Slurry im ME suchen
      local chem = findNextChemical()
      if chem then
        exportBatch(chem)
      else
        print("Kein Slurry mit mindestens", BATCH_SIZE, "mB im ME. Warte 10 Sekunden...")
        sleep(10)
      end
    end
  end
end
