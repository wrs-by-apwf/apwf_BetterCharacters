PlayerControllerExtension = PlayerControllerExtension or {}
local PlayerControllerExtensionClass = Class(PlayerControllerExtension)


---------------------------------------------------------------------------------------------------
-------------------- MAGIC STUFF (overwritting but with some logic) -------------------------------
---------------------------------------------------------------------------------------------------

PlayerControllerExtension.appendingRegistry = {} -- store the function to call by the original function name 

function PlayerControllerExtension:appendFunction(originalFunctionName, pc, toAppend)

    if pc[originalFunctionName] == nil then print("cannot append function " .. originalFunctionName .. ", default function does not exist") end

    if not self.appendingRegistry[originalFunctionName] then 

        PlayerControllerExtension.appendingRegistry[originalFunctionName] = {}

        -- deep copy the original function 
        local originalFunction = pc[originalFunctionName]

        -- set the new modified function
        pc[originalFunctionName] = function(self, ...)

            -- local return args
            local rargs = {}

            -- call the original function and get the return value 
            local originalArgs = originalFunction(self, ...)
        
            -- call the sub script and get the return values
            local ExtensionArgs = PlayerControllerExtension:callAllExtension(originalFunctionName, self, ...)

            -- construct the final return values for original function
            if originalArgs then
                for i, j in pairs(originalArgs) do
                    table.insert(rargs, j)
                end
            end

            -- construct the final return values for extended function
            if ExtensionArgs then
                for k, v in pairs(ExtensionArgs) do
                    table.insert(rargs, v)
                end
            end
            
            -- finally give back everything
            return unpack(rargs)
        end
    end

    table.insert(PlayerControllerExtension.appendingRegistry[originalFunctionName], toAppend)
end

function PlayerControllerExtension:callAllExtension(functionName, pc, ...)

    -- make sure the table exist
    if PlayerControllerExtension.appendingRegistry[functionName] == nil then return end

    -- local return args
    args = {}

    -- call all the binded functions
    for k, func in ipairs(PlayerControllerExtension.appendingRegistry[functionName]) do
        args[k] = func(pc, ...)
    end

    -- avoid to return a table if nil
    if #args == 0 then 
        return nil
    else
        return unpack(args)
    end
end

function PlayerControllerExtension:init()

    if g_scenario.player then 
        self:Patcher(g_scenario.player)
    end

    self:Patcher(PlayerController)
end

function PlayerControllerExtension:Patcher(LocalPlayerController)

    local excludedFunctions = { "new", "init", "parentClass", "clone", "inheritsFrom", "class", "emptyNew", "isInstance", "AfterInjectionCallbacks" }
    local PlayerControllerFunctions = {}
    local AfterInjectionCallbacks = {}
    local InsertedFunctions = {}
    local ExtensionsScripts = {
        { ref = CineCPCE, name = "CineCPCE" },
        --{ ref = SmoothCPCE, name = "SmoothCPCE" },
    }

    print("LocalPlayerController reference " ..  tostring(LocalPlayerController))
    
    for _, Root in ipairs(ExtensionsScripts) do

        local script = Root.ref

        -- add the simple add function
        if script.addFunc ~= nil then
            for functionName, func in pairs(script.addFunc) do
                if LocalPlayerController[functionName] ~= nil then
                    print("[BetterCharacters] PlayerController, function : " .. functionName .. " already registered")
                else
                    LocalPlayerController[functionName] = func
                    print("[BetterCharacters] PlayerController, new function added : " .. functionName)
                end
            end
        end

        -- add all the functions from all the scripts (hard overwrite)
        if script.overwritesFunc ~= nil then

            for functionName, func in pairs(script.overwritesFunc) do

                -- avoid to register the same function twice (always overwrite)
                if not InsertedFunctions[functionName] then

                    local isExcluded = false
                    if excludedFunctions[functionName] then
                        isExcluded = true
                        break
                    end

                    if not isExcluded then
                        print("[BetterCharacters] PlayerController, function : " .. functionName .. " had been overwritten")
                        LocalPlayerController[functionName] = func
                        InsertedFunctions[functionName] = true
                    end
                else
                    print("[BetterCharacters] PlayerController, function : " .. functionName .. " already registered")
                end
            end
        end

        -- add all the additionnals functions from all the scripts (appending to the existing function a new function)
        if script.additionnalsFunc ~= nil then
            for functionName, func in pairs(script.additionnalsFunc) do
                self:appendFunction(functionName, LocalPlayerController, func)
            end
        end

        -- add all the variables from all the scripts (hard overwrite)
        if script.overwritesVar ~= nil then
            for varName, varValue in pairs(script.overwritesVar) do
                LocalPlayerController[varName] = varValue
                print("[BetterCharacters] PlayerController, variable : " .. varName .. " had been overwritten with value : " .. varValue)
            end
        end

        -- add all the additionnals variables from all the scripts (set the value if the variable don't exist )
        if script.additionnalsVar ~= nil then
            for varName, varValue in pairs(script.additionnalsVar) do
                if LocalPlayerController[varName] ~= nil then
                    print("[BetterCharacters] PlayerController, variable : " .. varName .. " already registered")
                else
                    LocalPlayerController[varName] = varValue
                end
            end
        end

        -- add finally call all the injection callback 
        if script.AfterInjectionCallbacks ~= nil then
            for functionName, useless in pairs(script.AfterInjectionCallbacks) do
                LocalPlayerController[functionName](LocalPlayerController)
            end
        end

        
        print("[BetterCharacters] PlayerController, script : " .. Root.name .. " had been used to overwrite PlayerController")
    end
end
---------------------------------------------------------------------------------------------------
---------------------------------------- BASE EXTENSION -------------------------------------------
---------------------------------------------------------------------------------------------------
BasePCE = BasePCE or {}
local BasePCEClass = Class(BasePCE)

function BasePCE:load()

    local ExtensionsScripts = {
        { ref = ThirdPerCamPCE, name = "ThirdPerCamPCE" },
        { ref = SmoothCPCE, name = "SmoothCPCE" },
    }

    for k, v in ipairs(ExtensionsScripts) do 
        
        if v.ref.load then
            v.ref:load()
        end

    end


end
----------------------------------------------------------------------------------------------------------------
---------------- modification of the playerController that must be shared between script -----------------------
----------------------------------------------------------------------------------------------------------------
