

ChangeCharacter_Events                = ChangeCharacter_Events or ExtensionOf(BaseEvent)
InitModEvent(ChangeCharacter_Events, "ChangeCharacter_Events")


-- sent by the server
function ChangeCharacter_Events:sendData(Script, Player, prefab, bundleName)

    if g_isClient then return end

    print("server sent a event to clients")

    -- print the values sent
    print('sent an event ', "prefab : " .. prefab, "bundleName : " .. bundleName)

    streamWriteEntityId(Script)
    streamWriteEntityId(Player)
    streamWriteString(prefab)
    streamWriteString(bundleName)
end

-- received by the client
function ChangeCharacter_Events:receiveData(connection)

    if g_isServer then return end

    print("client received a event from a client ChangeCharacter_Events")

    local Script                    = streamReadEntityId()
    local Player                    = streamReadEntityId()
    local prefab                    = streamReadString()
    local bundleName                = streamReadString()

    -- print the value received
    print('received an event ', "prefab : " .. prefab, "bundleName : " .. bundleName)

    
    -- update the local game of the server/client 
    if Script ~= nil and Player ~= nil then
        Script:changeCharacterPrefab(Player, prefab, bundleName)
    end

end

ChangeCharacter_ClientEvents                = ChangeCharacter_ClientEvents or ExtensionOf(BaseEvent)
InitModEvent(ChangeCharacter_ClientEvents, "ChangeCharacter_ClientEvents")

-- sent by the client
function ChangeCharacter_ClientEvents:sendData(prefab, bundleName)

    if g_isServer then return end

    print("client sent a event to server")

    -- print the values sent
    print('sent an event ', "prefab : " .. prefab, "bundleName : " .. bundleName)

    streamWriteString(prefab)
    streamWriteString(bundleName)
end

-- received by the server
function ChangeCharacter_ClientEvents:receiveData(connection)

    if g_isClient then return end

    print("server received a event from a client")


    local prefab                    = streamReadString()
    local bundleName                = streamReadString()

    -- print the value received
    print('received an event ', "prefab : " .. prefab, "bundleName : " .. bundleName)

    local senderPlayer                = g_networkGame:getPlayerByConnection(connection)

    
    -- update the local game of the server
    if CustomCharacters ~= nil and senderPlayer ~= nil then
        CustomCharacters:changeCharacterPrefab(senderPlayer, prefab, bundleName)
    end

    -- broadcast the event to all clients
    ChangeCharacter_Events:broadcastEvent(connection, CustomCharacters, senderPlayer, prefab, bundleName)

end