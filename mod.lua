return {
    author              = "Jérôme (APWF)",
    version             = "dev-00.00.00.02",
    title               = "  - [APWF] Better Characters",
    description         = "this mod include 3 major enhancement : \r\n - Customizable Characters \r\n - Third Person Camera - \r\n - Improved First Person Camera",
    targetGame          = "WRS-S2",
    supportsMultiplayer = true,

    scripts             = {
        ------------------- Custom Characters Script ----------------------
        "ChangeCharacter_Events.lua",
        "CharactersHUD.lua",
        "CustomCharacters.lua",
        "CustomCharactersInputs.lua",
        "CustomCharactersPrefabs.lua",
        "CustomCharactersToolKit.lua",

        ------------------- Third Person Camera Script ----------------------
        -- 

        ------------------- Better Walking Camera Script ------------------
        "PlayerControllerCamera.lua",
        "SmoothCameraPlayerControllerExtension.lua",

        ------------------------------- Common ----------------------------
        "MasterInputs.lua",
        "toolkit.lua",
        "PlayerControllerExtension.lua",
        "ModEntry.lua", -- entry for mod listener
    },
}
