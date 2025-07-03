local tanks = {
    left = peripheral.wrap("left"),
    right = peripheral.wrap("right")
}

function readChemicalTank(reader)
    if not reader then return nil end
    local data = reader.getBlockData()
    if not data or not data.GasTanks or not data.GasTanks[0] then
        return nil
    end

    local gasTank = data.GasTanks[0]
    local stored = gasTank.stored

    if stored and stored.amount then
        return {
            amount = stored.amount,
            gasName= stored.gas or "Unbekannt",
            capacity = gasTank.capacity or 0
        }
    end

    return nil
end

for side, reader in pairs(tanks) do
    local tankData = readChemicalTank(reader)
    if tankData then
        print(string.format(
            "%s Tank: %s - %d mB",
            side,
            tankData.gasName,
            tankData.amount,
            tankData.capacity
        ))
    else
        print(side .. " Tank: Keine Daten gefunden")
    end
end
