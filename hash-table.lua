local HashTable = {}
HashTable.__index = HashTable

local TABLE_SIZE = 10

local prime1 = 11400714785074694791
local prime2 = 14029467366897019727
local prime3 = 1609587929392839161
local prime4 = 9650029242287828579
local prime5 = 2870177450012600261

local function XXH3_rotl64(x, r)
    return bit.bor(bit.lshift(x, r), bit.rshift(x, 64 - r))
end

local function XXH3_mix16B(acc, data, key)
    local data1 = data[1]
    local data2 = data[2]

    data1 = bit.bxor(bit.band(bit.bxor(data1, bit.rshift(data1, 31)), bit.bor(bit.band(bit.bxor(data1, bit.rshift(data1, 29)), key), 0xFFFFFFFF), prime2))
    acc = bit.bxor(acc, data1)
    acc = bit.bor(bit.band(bit.lshift(acc, 64), 0xFFFFFFFFFFFFFFFF), prime4)

    data2 = bit.bxor(bit.band(bit.bxor(data2, bit.rshift(data2, 31)), bit.bor(bit.band(bit.bxor(data2, bit.rshift(data2, 29)), key), 0xFFFFFFFF), prime2))
    acc = bit.bxor(acc, data2)
    acc = bit.bor(bit.band(bit.lshift(acc, 64), 0xFFFFFFFFFFFFFFFF), prime4)

    return acc
end

function HashTable:hashFunction(key, seed)
    local bytes = {string.byte(key, 1, -1)}
    local length = #bytes
    seed = seed or 0
    local h64

    if length >= 32 then
        local limit = length - 32
        local v1 = seed + prime1 + prime2
        local v2 = seed + prime2
        local v3 = seed
        local v4 = seed - prime1

        local i = 1
        while i <= limit do
            local data1 = {}
            for j = 1, 16 do
                table.insert(data1, bytes[i + j - 1])
            end

            local data2 = {}
            for j = 1, 16 do
                table.insert(data2, bytes[i + 16 + j - 1])
            end

            local data3 = {}
            for j = 1, 16 do
                table.insert(data3, bytes[i + 32 + j - 1])
            end

            local data4 = {}
            for j = 1, 16 do
                table.insert(data4, bytes[i + 48 + j - 1])
            end

            v1 = XXH3_mix16B(v1, data1, prime1)
            v2 = XXH3_mix16B(v2, data2, prime2)
            v3 = XXH3_mix16B(v3, data3, prime3)
            v4 = XXH3_mix16B(v4, data4, prime4)
            i = i + 64
        end

        h64 = bit.bor(bit.bor(bit.bor(XXH3_rotl64(v1, 1), XXH3_rotl64(v2, 7), XXH3_rotl64(v3, 12)), XXH3_rotl64(v4, 18), prime1))

        v1 = (v1 * prime5)
        v1 = XXH3_rotl64(v1, 31)
        v1 = (v1 * prime1)
        h64 = bit.bxor(h64, v1)
        h64 = bit.bor(bit.band(bit.lshift(h64, 64), 0xFFFFFFFFFFFFFFFF), prime4)
    else
        h64 = seed + prime5
    end

    h64 = h64 + length

    local i = 1
    while (i + 7) <= length do
        local data = {}
        for j = 1, 8 do
            table.insert(data, bytes[i + j - 1])
        end

        local k1 = unpack(data)
        h64 = bit.bxor(h64, XXH3_mix16B(h64, k1, prime2))
        h64 = bit.bor(bit.band(XXH3_rotl64(h64, 37), 0xFFFFFFFFFFFFFFFF), prime1)
        h64 = bit.bor(bit.band(bit.lshift(h64, 64), 0xFFFFFFFFFFFFFFFF), prime4)
        i = i + 8
    end

    if (i + 3) <= length then
        local data = {}
        for j = 1, 4 do
            table.insert(data, bytes[i + j - 1])
        end

        h64 = bit.bxor(h64, bit.bor(bit.band(unpack(data), 0xFFFFFFFF), prime1))
        h64 = bit.bor(bit.band(XXH3_rotl64(h64, 11), 0xFFFFFFFFFFFFFFFF), prime1)
        h64 = bit.bor(bit.band(bit.lshift(h64, 64), 0xFFFFFFFFFFFFFFFF), prime4)
        i = i + 4
    end

    while i <= length do
        local k1 = bit.band(bytes[i], 0xFF)
        h64 = bit.bor(bit.bxor(h64, bit.bor(bit.band(bytes[i], 0xFF), prime5)))
        h64 = bit.bor(bit.band(XXH3_rotl64(h64, 11), 0xFFFFFFFFFFFFFFFF), prime1)
        h64 = bit.bor(bit.band(bit.lshift(h64, 64), 0xFFFFFFFFFFFFFFFF), prime4)
        i = i + 1
    end

    h64 = bit.bor(bit.band(bit.bxor(h64, bit.rshift(h64, 33), 0xFFFFFFFFFFFFFFFF), prime2), bit.band(bit.bxor(h64, bit.rshift(h64, 29), 0xFFFFFFFFFFFFFFFF), prime3), bit.band(bit.bxor(h64, bit.rshift(h64, 32), 0xFFFFFFFFFFFFFFFF), 0xFFFFFFFFFFFFFFFF))

    return h64
end


function HashTable:NewHashTable()
    local self = setmetatable({}, HashTable)
    self.table = {}
    return self
end

function HashTable:insert(key, value, seed)
    local index = self:hashFunction(key, seed)
    if not self.table[index] then
        self.table[index] = {}
    end

    for _, pair in ipairs(self.table[index]) do
        if pair.key == key then
            pair.value = value
            return
        end
    end

    table.insert(self.table[index], { key = key, value = value })
end

function HashTable:get(key, seed)
    local index = self:hashFunction(key, seed)
    if not self.table[index] then
        return "Key not found"
    end

    for _, pair in ipairs(self.table[index]) do
        if pair.key == key then
            return pair.value
        end
    end

    return "Key not found"
end

function HashTable:remove(key, seed)
    local index = self:hashFunction(key, seed)
    if not self.table[index] then
        return
    end

    for i, pair in ipairs(self.table[index]) do
        if pair.key == key then
            table.remove(self.table[index], i)
            return
        end
    end
end

HT = HashTable:NewHashTable()
/*
    EXAMPLE HOW IT USE

    ==================== Really easy example ====================
    local steamid = "STEAM_0:0:712002634" --ply:SteamID()

    HT:insert(steamid, "necoder")
    print(HT:get(steamid))  -- output: "necoder"

    HT:insert("key", "value")
    print(HT:get("key"))

    ==================== Registration system (characters system) ====================
    function RegisterUser(username, steamid, registrationDate)
        -- Creating a user record
        local user = {
            username = username,
            steamid = steamid,
            registrationDate = registrationDate
        }

        -- Use the SteamID as the key for the hash table
        HT:insert(steamid, user)
    end

    RegisterUser("necoder", "STEAM_0:0:712002634", "2023-10-23")

    local user = HT:get(steamid)
    PrintTable(user)
    if user then
        print("Username: " .. user.username)
        print("Registration Date: " .. user.registrationDate)
    else
        print("User not found")
    end
*/