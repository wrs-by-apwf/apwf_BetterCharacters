BaseBetterCharacters = BaseBetterCharacters or {}
addModListener(BaseBetterCharacters)

local mod
mod, abm_bettercharactersBundleId = ModLoader.getModByName("abm_bettercharacters")
mod = nil

function BaseBetterCharacters:preLoad()

    self.savegameKey = "bettercharacters"

    --------------- Player Controller Extension ----------------------
    PlayerControllerExtension:init()

    --------------- Custom Characters Script ----------------------


    --------------- Cinematic Camera Script ----------------------


    --------------- Better Walking Camera Script ------------------


end

function BaseBetterCharacters:load()
    BasePCE:load()
    CustomCharacters:load()
    self:prepareDashMenu()
end

function BaseBetterCharacters:loadFromTable(tbl)

    -- protect savegames
    if tbl == nil then return end
    local SavegameData = tbl[self.savegameKey]
    if SavegameData == nil then return end

    -- Custom Characters load 
    if SavegameData.CustomChara ~= nil then 
        CustomCharacters:loadFromTable(SavegameData.CustomChara)
    end

end

function BaseBetterCharacters:saveToTable(tbl)

    local SavegameData = {}

    SavegameData.CustomChara = CustomCharacters:saveToTable()

    tbl[self.savegameKey] = SavegameData
    return tbl
end

function BaseBetterCharacters:prepareDashMenu()
    local dashMenu

    if AirborneDashMenu ~= nil then
        self:pushDashMenu(AirborneDashMenu)
        print("dash menu found AirborneDashMenu")
        return
    end
 
    if abm_dashmenu ~= nil then
        self:pushDashMenu(abm_dashmenu.AirborneDashMenu)
        print("dash menu found abm_dashmenu.AirborneDashMenu")
        return
    end

    if mods ~= nil and mods.abm_dashmenu ~= nil then
        self:pushDashMenu(mods.abm_dashmenu.AirborneDashMenu)
        print("dash menu found mods.abm_dashmenu.AirborneDashMenu")
        return
    end

    if mod ~= nil and mod.abm_dashmenu ~= nil then
        self:pushDashMenu(mod.abm_dashmenu.AirborneDashMenu)
        print("dash menu found mod.abm_dashmenu.AirborneDashMenu")
        return
    end

    print("dash menu not found")
end

function BaseBetterCharacters:pushDashMenu(DashMenuScript)
    DashMenuScript:RegisterLoadCallback(self)
end

function BaseBetterCharacters:onDashMenuLoaded(DashMenuScript)
    print("dash menu loaded on BaseBetterCharacters")
    DashMenuScript:addMod("abm_bettercharacters", false, "DashMenuLogo", function() local player = g_scenario.player player:selectCustomController(player.PLAYMODE_CINEMATIC) end, "right_right")
end