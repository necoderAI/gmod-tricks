HashTable = {}
HashTable.__index = HashTable

local TABLE_SIZE = 10

function HashTable:hashFunction(key)
    local sum = 0
    for i = 1, #key do
        sum = sum + string.byte(key, i)
    end
    return sum % TABLE_SIZE
end

function HashTable:NewHashTable()
    local self = setmetatable({}, HashTable)
    self.table = {}
    return self
end

function HashTable:insert(key, value)
    local index = self:hashFunction(key)
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

function HashTable:get(key)
    local index = self:hashFunction(key)
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

function HashTable:remove(key)
    local index = self:hashFunction(key)
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


HashTable = HashTable:NewHashTable()


/*
    EXAMPLE HOW IT USE


    ==================== Really easy example ====================
    local steamid = "STEAM_0:0:712002634" --ply:SteamID()
    local query = "STEAM_0:0:712002634", "necoder"

    print(HashTable:hashFunction(steamid))

    HashTable:insert(steamid, "necoder")
    print(HashTable:get(steamid))  -- output: "necoder"

    HashTable:insert("key", "value")
    print(HashTable:get("key"))

    ==================== Registration system (characters system) ====================
    function RegisterUser(username, steamid, registrationDate)
        -- Creating a user record
        local user = {
            username = username,
            steamid = steamid,
            registrationDate = registrationDate
        }

        -- Use the SteamID as the key for the hash table
        HashTable:insert(steamid, user)
    end

    RegisterUser("necoder", "STEAM_0:0:712002634", "2023-10-23")

    local user = HashTable:get(steamid)
    PrintTable(user)
    if user then
        print("Username: " .. user.username)
        print("Registration Date: " .. user.registrationDate)
    else
        print("User not found")
    end

*/