return {
    author              = "Jérôme (APWF)",
    version             = "WIP",
    title               = "  - [APWF] Better Characters",
    description         = "this mod include 3 major enhancement : \r\n - Customizable Characters \r\n - Cinematic Camera - \r\n - Better walking Camera",
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

        -------------------- Cinematic Camera Script ----------------------
        "CinematicController.lua",
        "CCChatCommands.lua",
        "CinematicCameraPlayerControllerExtension.lua",
        "CinematicHUD.lua",

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
