CustomCharacters            = CustomCharacters or {}
local CustomCharactersClass = Class(CustomCharacters, NetworkEntity)

if not g_isHotReload then
    InitModEntityType(CustomCharacters, "CustomCharacters")
end

function CustomCharacters:registerCloset(id)

    print("[CustomCharacters] Registering closet " .. id)

    if self.closets == nil then
        self.closets = {}
    end

    -- make sure the closet id is not already existing
    if self.closets[id] == nil then
        -- register all the relevants informations of the closet
        self.closets[id] = {
            typesAvailables = "all"
        }
    end

    print("[CustomCharacters] Adding trigger to closet " .. id)
    
    -- register the callback
    Trigger.addTrigger(
        id,
        function(idin) if idin == g_scenario.player.transformId then self.canOpenMenu = true end end,
        function() self.canOpenMenu = false end,
        false,
        true
    );

    -- add destroy listener
    addDestroyListener(id, function()
        self.closets[id] = nil
        Trigger.removeTrigger(id)
    end)
end

function CustomCharacters:addCustomCharacters(bundleName, prefabName, characterlabel, sprite, creatorName, type)

    -- make sure the bundleName is existing
    if self.ModsCharacters[bundleName] == nil then
        self.ModsCharacters[bundleName] = {}
    end

    -- init the table for the prefab
    if self.ModsCharacters[bundleName][prefabName] == nil then
        self.ModsCharacters[bundleName][prefabName] = {
            label = characterlabel,
            prefabname = prefabName,
            bundleName = bundleName,
            sprite = sprite,
            creator = creatorName,
            type = type
        }

        print("[APWF_CustomCharacter] Prefab " .. prefabName .. " added to the characters list.")
    else
        print("Prefab " .. prefabName .. " already exist in the bundle")
        return
    end
end

-- the core of the mod, called when the player select a character, handle the multiplayer and local game
function CustomCharacters:SubmitCharacter(prefab, bundleName)
    local playerController

    if g_isMultiplayer then
        if g_isServer then
            playerController = g_networkGame.serverPlayer

            -- prevent nil playerController
            if playerController == nil then
                print("[CC] Error: playerController is nil")
                return
            end

            -- then, send the event to all clients that he changed character
            ChangeCharacter_Events:send(self, playerController, prefab, bundleName)
            self:changeCharacterPrefab(playerController, prefab, bundleName)
        end

        if g_isClient then
            playerController = g_networkGame.localPlayer

            -- prevent nil playerController
            if playerController == nil then
                print("[CC] Error: playerController is nil")
                return
            end

            ChangeCharacter_ClientEvents:send(prefab, bundleName)
            self:changeCharacterPrefab(playerController, prefab, bundleName)
        end
    else
        playerController = g_scenario.player

        -- prevent nil playerController
        if playerController == nil then
            print("[CC] Error: playerController is nil")
            return
        end

        self:changeCharacterPrefab(playerController, prefab, bundleName)
    end
end

function CustomCharacters:changeCharacterPrefab(playerController, Prefab, bundleName)

    print("[CustomCharacters] was asked Changing character to " .. Prefab .. " from bundle " .. bundleName)
    -------------------------------------------------------------------------------------
    --------------------------------------- Define --------------------------------------
    ---------------------------------------------------------------------------------
    local isLocalPlayer = (playerController == g_scenario.player) or (playerController == g_networkGame.localPlayer)

    -------------------------------------------------------------------------------------
    ------------------------------------- Base init -------------------------------------
    -------------------------------------------------------------------------------------

    -- then, load the new prefab
    local newCharacterId = ModSpawnPrefab(Prefab, bundleName)

    if newCharacterId == nil then
        print("Error: prefab " .. Prefab .. " not found in bundle " .. bundleName)
        return
    end

    -- check if the character is already in use
    if self.currentCharacter == bundleName .. "." .. Prefab then
        return
    end

    -- save the current character informations
    self.currentCharacter = bundleName .. Prefab

    ----------------------------------------------------------------------------------------------------------------
    ------------------------------------- modification of the playerController ------------------------------------- (temporary)
    ----------------------------------------------------------------------------------------------------------------

    -- first, deactivate the default characters (both gender work the same way)
    setActive(playerController.playerCharacter, false)
    setActive(playerController.playerCharacterSit, false) -- may cause issue where the default character come back onEnter and OnLeave vehicles
    setActive(newCharacterId, not isLocalPlayer)          -- activate only if not local player (other players can see the prefab but not the local player)


    -- get the parent of the player character
    local parent = getParent(playerController.playerCharacter)

    -- then, set the new character as child
    setParent(newCharacterId, parent)

    -- set the position of the new character
    setPosition(newCharacterId, 0, -1, 0)
    setRotation(newCharacterId, 0, 0, 0)

    -- save the new character id in the playerController
    playerController.CustomPlayerCharacter = newCharacterId

    -- save the old character
    playerController.vanillaplayerCharacter = playerController.playerCharacter
    -- playerController.vanillaplayerCharacterSit = playerController.playerCharacterSit


    -- now override the playerCharacter
    playerController.playerCharacter = newCharacterId
end

function CustomCharacters:revertToDefaultPrefab(playerController)
    -- revert the character to the default one
    playerController.playerCharacter = playerController.vanillaplayerCharacter

    -- set the default character as active
    setActive(playerController.playerCharacter, true)

    -- deactivate the custom character
    setActive(playerController.CustomPlayerCharacter, false)
end

function CustomCharacters:CreateTCubeAtPos(Pos, Rot, Scale)
    -- create a cube gameobject
    local id = IdModSpawnPrefab("BaseClosetCol", apwf_bettercharactersBundleId)

    -- set the position, rotation and scale of the cube
    setWorldPosition(id, Pos.x, Pos.y, Pos.z)
    setWorldRotation(id, Rot.x, Rot.y, Rot.z)
    setScale(id, Scale.x, Scale.y, Scale.z)

    -- return the id of the cube
    return id
end

function CustomCharacters:saveToTable()
    local table = {}
    table.closets = {}

    -- save the closets informations to the table
    for k, t in pairs(self.closets) do
        local TempPosX, TempPosY, TempPosZ = getWorldPosition(k)
        local TempRotX, TempRotY, TempRotZ = getWorldRotation(k)
        local TempScaleX, TempScaleY, TempScaleZ = getScale(k)


        table.closets[k] = {
            pos = { x = TempPosX, y = TempPosY, z = TempPosZ },
            rot = { x = TempRotX, y = TempRotY, z = TempRotZ },
            scale = { x = TempScaleX, y = TempScaleY, z = TempScaleZ },
            typesAvailables = t.typesAvailables
        }
    end

    -- save the current character
    table.currentCharacter = self.currentCharacter

    return table
end

function CustomCharacters:loadFromTable(table)
    print("[CustomCharacters] Loading from table")
    self.savedTable = table  -- save the table for later use
end

function CustomCharacters:onDestroy()
    CustomCharacters:parentClass().onDestroy(self)
end

function CustomCharacters:destroy()
    CustomCharacters:parentClass().destroy(self)
end

---------------------------------------------------------------------------------
----------------------------------NETWORKING-------------------------------------
---------------------------------------------------------------------------------

function CustomCharacters:writeResync()

    print("[CustomCharacters] Writing resync")
    CustomCharacters:parentClass().writeResync(self)
    CustomCharacters:parentClass().finishWriteResync(self)

    -- set as dirty for the next frame (so the server sent informations to the clients)
    self:setDirty(true)
end

function CustomCharacters:readResync()

    print("[CustomCharacters] Reading resync")
    CustomCharacters:parentClass().readResync(self)
    CustomCharacters:parentClass().finishReadResync(self)
end

function CustomCharacters:load()
    print("[CustomCharacters] Loading CustomCharacters")
    -- call NetworkEntity's load function
    CustomCharacters:parentClass().load(self)

    self.closets = {}
    self.ModsCharacters = {}
    self.currentCharacter = "default"
    self.canOpenMenu = false
    self.MenuIsOpen = false
    self.HUD = nil

    -- load the prefabs of the characters
    print("[CustomCharacters] Loading Mod Prefabs")
    self:LoadModPrefabs()

    if self.savedTable ~= nil then 
        print("[CustomCharacters] Loading from saved table")
        -- load the savegame 
        self:delayedLoadFromTable(self.savedTable)
    end

    -- register the class for multiplayer (from networkEntity)
    self:register()
end

function CustomCharacters:delayedLoadFromTable(table)
    print("[CustomCharacters] Delayed loading from table")
    -- reload the closets from the table informations
    for k, t in pairs(table.closets) do
        local id = self:CreateTCubeAtPos(t.pos, t.rot, t.scale)
        print("[CustomCharacters] Closet loaded at position: ", t.pos)

        self.closets[id] = {
            typesAvailables = t.typesAvailables
        }
    end

    if table.currentCharacter ~= "default" then
        print("[CustomCharacters] Loading non-default character from table")
        -- split the message by the first dot and get the scripts Id
        local dotIndex = string.find(table.currentCharacter, ".", 1, true)
        local bundleName, prefab = string.sub(table.currentCharacter, 1, dotIndex - 1),
            string.sub(table.currentCharacter, dotIndex + 1)

        -- load the current character
        self:SubmitCharacter(prefab, bundleName)
    end

    -- throw the table to the garbage collector
    print("[CustomCharacters] Clearing saved table from memory")
    self.savedTable = nil
    table = nil
end

function CustomCharacters:LoadModPrefabs()
    print("[CustomCharacters] Adding Custom Characters")
    self:addCustomCharacters("apwf_bettercharacters", "TrexCharacter", "Trex", "TrexSprite",
        "APWF", "fantasy")
end

function CustomCharacters:update()
    -- check if menu can be opened
    if self.canOpenMenu then
        -- check for any user input
        if InputMapper:getKeyDown(InputMapper.CC_OpenCloset) then
            if not self.MenuIsOpen then
                print("[CustomCharacters] Opening Characters HUD")
                self.HUD = g_GUI:showHUD(CharactersHUD)
                self.HUD:rebuildList(self.ModsCharacters)
            else
                print("[CustomCharacters] Closing Characters HUD")
                g_GUI:closeHUD(CharactersHUD)
            end
            self.MenuIsOpen = not self.MenuIsOpen
        end
    end
end
