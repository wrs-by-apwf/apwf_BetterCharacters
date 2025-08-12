ToolKit = ToolKit or {};
local ToolKitClass = Class(ToolKit);

-------------------------------------------------------------------------------------------------
function getBundleId(BundleName)
    local Mod, bundleModId	= ModLoader.getModByName(BundleName)
    return bundleModId
end

function IdModSpawnPrefab(prefabName, bundleId)
    print("[Toolkit] called IdModSpawnPrefab for prefab name : " .. prefabName .. " with bundleId : " .. bundleId)


    local id = Utils.loadBundleGameObject(bundleId, prefabName)
    
    if id == nil then print("[Tollkit] failed to load prefab : " .. prefabName) return 0 end

    return id
end

function ModSpawnPrefab(prefabName, BundleName)
    print("[Toolkit] called ModspawnPrefab for prefab name : " .. prefabName .. " with BundleName : " .. BundleName)


    local id = Utils.loadBundleGameObject(getBundleId(BundleName), prefabName)
    
    if id == nil then print("[Tollkit] failed to load prefab : " .. prefabName) return 0 end

    return id
end



