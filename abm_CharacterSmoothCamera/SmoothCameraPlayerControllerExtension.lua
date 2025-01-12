SmoothCPCE = {}
local SmoothCPCEClass = Class(SmoothCPCE)

SmoothCPCE.overwritesFunc = {}
SmoothCPCE.overwritesVar = {}
SmoothCPCE.additionnalsFunc = {}
SmoothCPCE.additionnalsVar = {}
SmoothCPCE.AfterInjectionCallbacks = {}

SmoothCPCE.AfterInjectionCallbacks["loadPrefab"] = function() 
    local player
    
    if g_isSingleplayer then
         
        player = g_scenario.player

    end

    if g_isMultiplayer then

        player = g_networkGame.localPlayer

    end

    if player == nil then return print("player is nil, can't load prefab") end

    player:loadPrefab()

    if player:getIsPlaymodeWalking() then
        player.camera:activate()
    end
end

SmoothCPCE.overwritesFunc["loadPrefab"] = function()

    local id = Utils.spawnDefaultPrefab("internal/playerController")

    if self.characterGender == 1 then

        self.playerCharacter = getChild(id, "playerCharacterMale")

        self.playerCharacterSit = getChild(id, "playerCharacterMale_IK")

        setActive(getChild(id, "female_animations_generic"), false)

        setActive(getChild(id, "female_animations_humanoid"), false)

        self.passengerHandIkTargetLeft = getChild(self.playerCharacterSit,
            "male_rig/root/DEF-spine/PassengerIkTargetLeft")

        self.passengerHandIkTargetRight = getChild(self.playerCharacterSit,
            "male_rig/root/DEF-spine/PassengerIkTargetRight")

    else

        self.playerCharacter = getChild(id, "female_animations_generic")

        self.playerCharacterSit = getChild(id, "female_animations_humanoid")

        setActive(getChild(id, "playerCharacterMale"), false)

        setActive(getChild(id, "playerCharacterMale_IK"), false)

        self.passengerHandIkTargetLeft = getChild(self.playerCharacterSit, "rig/root/DEF-spine/PassengerIkTargetLeft")

        self.passengerHandIkTargetRight = getChild(self.playerCharacterSit, "rig/root/DEF-spine/PassengerIkTargetRight")

    end

    self:applyCharacterColors(self.characterColors, self.playerCharacter)

    self:applyCharacterColors(self.characterColors, self.playerCharacterSit)

    setActive(self.playerCharacter, not self.isLocalPlayer)

    setActive(self.playerCharacterSit, false)

    self.transformId = id

    self.playerNameLabelWalk = getChild(id, "animRoot/NameLabel")

    self.playerNameLabel = self.playerNameLabelWalk

    self.pickupRoot = getChild(id, "animRoot/PickupRoot")

    self.pickupDestination = getChild(id, "animRoot/PickupRoot/PickupDestination")

    -- for local players so no vehicles will be shot around!

    Controller.setDetectCollision(self.transformId, self.isLocalPlayer)

    Rigidbody.setColliderEnabled(self.transformId, self.isLocalPlayer)

    if not self.isLocalPlayer then

        Rigidbody.disableAllColliders(self.transformId)

    end

    self.animId = getChildAt(self.transformId, 0)

    Animator.setBool(self.animId, "isWalking", false)

    self.cameraId = getChild(self.animId, "playerCameraRoot")

    self.trueCameraId = getChildAt(self.cameraId, 0)

    self.pocketLampId = getChildAt(self.trueCameraId, 0)

    self.solidStepSounds = {getChild(id, "SolidStepSound1"), getChild(id, "SolidStepSound2"),

                            getChild(id, "SolidStepSound3"), getChild(id, "SolidStepSound4")}

    self.snowStepSounds = {getChild(id, "SnowStepSound1"), getChild(id, "SnowStepSound2"),

                           getChild(id, "SnowStepSound3"), getChild(id, "SnowStepSound4")}

    self.lastStepSound = 0

    self.stepSoundTimer = 0

    self.camera = PlayerControllerCamera:new(self.cameraId)

    self.camera.enableRotY = false

    self.camera.trueCameraId = self.trueCameraId

    self.playerDummyPrefab = nil

    self.rotateHands = true

    self.handIkTargetLeft = nil

    self.handIkTargetRight = nil

    self.footIkTargetLeft = nil

    self.footIkTargetRight = nil

    self:setIkCallback()

    -- if self.isLocalPlayer then

    AnchorPoint.onCreatePlayer(getChild(id, "animRoot/PickupRoot/WinchRoot"), self)

    -- end

    -- player controller is disabled per default

    setActive(self.transformId, false)

end