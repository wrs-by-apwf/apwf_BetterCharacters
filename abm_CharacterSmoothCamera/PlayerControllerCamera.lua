PlayerControllerCamera = PlayerControllerCamera or {}
local PlayerControllerCameraClass = Class(PlayerControllerCamera)

-- Constants for spring-damping effect
local SPRING_CONSTANT = 0.2
local DAMPING_CONSTANT = 2

function PlayerControllerCamera:load(cameraId)
    print("loading custom camera script")

    self.cameraId = cameraId
    self.trueCameraId = cameraId
    self.zoomLevel = 1
    self.zoomFOV = GameplaySettings.fieldOfView
    self.cameraFrozen = false
    self.blockInput = false

    self.cx = 0
    self.cy = 0
    self.fakeCx = 0
    self.fakeCy = 0

    self.minRotX = -85
    self.maxRotX = 85

    -- Variables for spring-damping effect
    self.velocityX = 0
    self.velocityY = 0
end

function PlayerControllerCamera:activate()
    if not self.dontActivateCamera then
        GameControl.setCamera(self.trueCameraId)
    end
    self.cameraFrozen = false
    self.blockInput = false

    PlayerControllerCamera.activeCamera = self
end

function PlayerControllerCamera:getRotateFactor()
    return GameplaySettings.mouseSensitivity * lerp(0.2, 1, self.zoomLevel)
end

function PlayerControllerCamera:getCameraFrozen()
    return self.cameraFrozen or (Input.getMouseButton(0) and self.enableSelector)
end

function PlayerControllerCamera:setIsFrozen(isFrozen)
    self.cameraFrozen = isFrozen
    g_GUI:wrapMouse(not self.cameraFrozen)
end

function PlayerControllerCamera:setBlockInput(block)
    self.blockInput = block
    g_GUI:wrapMouse(not self.cameraFrozen)
end

function PlayerControllerCamera:update(dt)
    if g_GUI:getAnyGuiActive() or self.blockInput then return end

    self.zoomLevel = clamp01(self.zoomLevel - InputMapper:getAxis(InputMapper.Axis_Look_Zoom) * GameplaySettings.zoomSensitivity)
    local targetFOV = lerp(20, GameplaySettings.fieldOfView, self.zoomLevel)
    self.zoomFOV = 0.5 * (self.zoomFOV + targetFOV)
    GameControl.setCameraFOV(self.trueCameraId, self.zoomFOV)

    if not self:getCameraFrozen() then
        local movX = InputMapper:getAxis(InputMapper.Axis_Look_LeftRight)
        local movY = InputMapper:getAxis(InputMapper.Axis_Look_UpDown)

        local rotateFactor = self:getRotateFactor()

        -- Calculate target rotation
        local targetCx = self.fakeCx - movY * rotateFactor
        local targetCy = self.fakeCy + movX * rotateFactor

        -- Clamp the target rotation for pitch (X axis)
        targetCx = clamp(targetCx, self.minRotX, self.maxRotX)

        -- Apply spring-damping effect only on the pitch (X axis) if not at rotation limits
        if self.fakeCx > self.minRotX and self.fakeCx < self.maxRotX then
            self.velocityX = self.velocityX + SPRING_CONSTANT * (targetCx - self.fakeCx) - DAMPING_CONSTANT * self.velocityX
            self.cx = self.fakeCx + self.velocityX
            self.cx = clamp(self.cx, self.minRotX, self.maxRotX)
        else
            -- If at limits, apply rotation directly and reset velocity
            self.cx = targetCx
            self.velocityX = 0
        end

        -- Directly update yaw (Y axis) without damping
        self.cy = targetCy

        -- Update fake values to track actual rotation
        self.fakeCx = self.cx
        self.fakeCy = self.cy

        setRotation(self.cameraId, self.cx, self.cy, 0)
    end
end

function PlayerControllerCamera:getRotation()
    return self.fakeCx, self.fakeCy
end

function PlayerControllerCamera:setRotation(cx, cy)
    self.fakeCx = cx
    self.fakeCy = cy
    self.cx = cx
    self.cy = cy
end

function PlayerControllerCamera:fixedUpdate(dt)
    -- No need for fixed update in first person camera spring-damping implementation
end

function PlayerControllerCamera:resetWorldReferenceMovement()
    -- No need for world reference reset in first person camera
end

function PlayerControllerCamera:generateCameraShake(factor)
    local cameraShakeX, cameraShakeY, cameraShakeZ = Utils.randomInsideUnitSphere()
    local cameraShake = Vector3:new(cameraShakeX, cameraShakeY, cameraShakeZ)
    cameraShake = Vector3.multiply(cameraShake, factor)
    setRotation(self.trueCameraId, cameraShake.x, cameraShake.y, cameraShake.z)
end
