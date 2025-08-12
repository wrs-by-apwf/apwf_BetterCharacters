CharactersHUD            = CharactersHUD or {}
local HelicopterHUDClass = Class(CharactersHUD, BaseHUD)


function CharactersHUD:load()
    CharactersHUD:parentClass().loadFromMod(self, "apwf_bettercharacters", "CharactersHUD")

    self.SelectCharacterUI = getChild(self.id, "SelectCharacter_GUI")
    self.CharacterContentRoot = getChild(self.id, "SelectCharacter_GUI/Category_Menu/Scroll View/Viewport/Content")
    self.CharacterTemplate = getChild(self.id, "SelectCharacter_GUI/Category_Menu/Scroll View/Viewport/Content/character_card_Template")

    setActive(self.CharacterTemplate, false)
end

function CharactersHUD:rebuildList(charactersTable)

    -- first clear the list
    self:ClearList()

   
    for bundleName, bundle in pairs(charactersTable) do

        for PrefabName, t in pairs(bundle) do

            local newUIEntry = instantiate(self.CharacterTemplate, true)
            local button =     getChildAt(newUIEntry, 0)

            -- activate the new entry
            setActive(newUIEntry, true)

            -- sprite custom
            local customSprite = Utils.loadBundleSprite(getBundleId(bundleName), t.sprite)
            if customSprite ~= nil then
                UI.setImageSprite(button, customSprite)
            end

            -- setup the button 
            UI.setOnClickCallback(button, 
            
            function()
                g_GUI:closeHUD(self)
                CustomCharacters:SubmitCharacter(PrefabName, bundleName)
            end)

            
        end
    end
end

function CharactersHUD:ClearList()

    for k, v in getChildren(self.CharacterContentRoot) do
        if not v == self.CharacterTemplate then destroy(v) end
    end
end
