--play.lua

require("scripts/lua/p_ctrl.lua")
require("scripts/lua/p_common.lua")
require("scripts/lua/p_project.lua")
require("scripts/lua/p_gmanykit.lua")
require("scripts/lua/p_gmanykitfun.lua")

-------------------------------------------------------------------------------
function engine_project_preload() 
    print("engine_project_preload")

	g_manykit:CheckSystemConfig()

    if Application.PLT_LINUX == PX2_APP:GetPlatformType() then
        if PX2_APP:IsARM() then
            if PX2_APP:IsARMAARCH64() then
                print("load dlls : armaarch64");
            else
                print("load dlls : arm");
            end
        else
            print("load dlls : pc linux");
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_calib3d.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_core.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_dnn.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_features2d.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_flann.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_highgui.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_imgcodecs.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_imgproc.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_ml.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_objdetect.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_photo.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_stitching.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_video.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libopencv_videoio.so")

            PX2_DYNLIBM:Load("/usr/local/lib/libvlc.so")
            PX2_DYNLIBM:Load("/usr/local/lib/libvlccore.so")
    
            PX2_DYNLIBM:Load("./PAim/dlls/x64/libSimple.so")
            PX2_DYNLIBM:Load("./PAim/dlls/x64/libthermometry.so")
        end
    end		

    VLC:Initlize()
end
-------------------------------------------------------------------------------
function engine_project_preplay() 
    collectgarbage("collect")
    PX2_APP:SetShowInfo(false)

    PX2_APP:InitlizeNetEngine()
    PX2_SRMM:SetCharacterAffectCalculate(true)
end
-------------------------------------------------------------------------------
function engine_project_play()
	PX2_ENGINECANVAS:SetClearColor(Float4:MakeColor(255, 255, 255, 255))
	PX2_ENGINESCENECANVAS:SetClearColor(Float4:MakeColor(255, 255, 255, 255))

	manykit_start()
end
-------------------------------------------------------------------------------
function engine_project_update(appseconds, elapsedseconds)	 
	PX2_ENGINESCENECANVAS:ClearDebugLine()
	       
	if g_manykit._systemControlMode == 1 then
		manykit_UpdateMRTranslate()
	end
	manykit_UpdateGunTranslate()

    -- nav mesh debug
	local scene = PX2_PROJ:GetScene()
    if scene then
		local aw = scene:GetAIAgentWorld()
        if aw then
			local nav = aw:GetNavigationMesh("Nav")
			if nav then
				local numP = nav:GetNumPathPoints()
				for i=0, numP-2, 1 do
					local p = nav:GetPathPoint(i)
					local pNext = nav:GetPathPoint(i+1)	
					PX2_ENGINESCENECANVAS:AddDebugLine(p, pNext, Float4(1.0, 1.0, 0.0, 1.0))
				end
			end
		end
    end
end
-------------------------------------------------------------------------------
function engine_project_cmd(cmd, param0, param1, param2) 
end
-------------------------------------------------------------------------------