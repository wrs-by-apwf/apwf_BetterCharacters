ThirdPerCamPCE = {}
local ThirdPerCamPCEClass = Class(ThirdPerCamPCE)

ThirdPerCamPCE.overwritesFunc = {}
ThirdPerCamPCE.overwritesVar = {}
ThirdPerCamPCE.additionnalsFunc = {}
ThirdPerCamPCE.additionnalsVar = {}
ThirdPerCamPCE.AfterInjectionCallbacks = {}

ThirdPerCamPCE.AfterInjectionCallbacks["loadPrefab"] = function() 
    
end

ThirdPerCamPCE.overwritesFunc["loadPrefab"] = function(class)


end