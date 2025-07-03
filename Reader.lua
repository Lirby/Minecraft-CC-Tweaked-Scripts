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

    local amount = (stored and stored.amount) or 0
    local gasName = (stored and stored.gas) or "Leer"
    local capacity = gasTank.capacity or 0

    return {
        amount = amount,
        gasName = gasName,
        capacity = capacity,
    }
end

for side, reader in pairs(tanks) do
    local tankData = readChemicalTank(reader)
    if tankData then
        print(string.format(
            "%s Tank: %s - %d  / %d mB",
            side,
            tankData.gasName,
            tankData.amount,
            tankData.capacity
        ))
    else
        print(side .. " Tank: Keine Daten gefunden")
    end
end
