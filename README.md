# Library with various solutions
## Hash-Tables

1. **Key Lookup:** Hash tables are usually faster to find an element by key, since they allow you to find an element directly by the key hash, which makes the search operation (on average) constant O(1). While the array search is performed linearly, O(n) if a brute force occurs.

1. **Insertion and Deletion:** Inserting and deleting elements is also more efficient in hash tables. In an array, you have to shift all the elements after insertion/deletion, which can take O(n) time, while hash tables allow you to perform operations on average in O(1) time.
### Really easy example
```lua
    local steamid = "STEAM_0:0:712002634" --ply:SteamID()
    local query = "STEAM_0:0:712002634", "necoder"
  
    print(HashTable:hashFunction(steamid))
  
    HashTable:insert(steamid, "necoder")
    print(HashTable:get(steamid))  -- output: "necoder"
  
    HashTable:insert("key", "value")
    print(HashTable:get("key"))
```
### Registration system (characters system)
```lua
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
```
