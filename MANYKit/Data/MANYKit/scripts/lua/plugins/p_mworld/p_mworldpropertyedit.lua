-- p_p_mworldpropertyedit.lua

-------------------------------------------------------------------------------
function p_mworld:_RegistPropertyOnSet()
    print(self._name.." p_mworld:_RegistPropertyOnSet")

    local iswf = false
    local scene = PX2_PROJ:GetScene()
    if scene then
        local terrain = scene:GetTerrain()
        if terrain then
            iswf = terrain:IsShowWireFrame()       
        end
    end

    local iddebugphy = PX2_GH:IsDebugPhysics()
    local iddebugskin = PX2_GH:IsDebugSkin()

    self._scriptControl:RemoveProperties("Set")

    self._scriptControl:BeginPropertyCata("Set")

    self._scriptControl:AddPropertyClass("Setting", "设置")
    local issnaptoterrain = PX2_EDIT.IsSnapToTerrain==1
    self._scriptControl:AddPropertyBool("IsDragToTerrain", "贴齐地形", issnaptoterrain)
    local issnaptogrid = PX2_EDIT.IsSnapToGrid==1
    self._scriptControl:AddPropertyBool("IsSnapToGrid", "贴齐网格", issnaptogrid)
    self._scriptControl:AddPropertyFloat("SnapGridSize", "网格大小", PX2_EDIT.DragMoveSpace)
    self._scriptControl:AddPropertyBool("Wireframe", "线框模式", self._wireframe)
    self._scriptControl:AddPropertyBool("IsDebugPhysics", "调试物理", iddebugphy, true, false)
    self._scriptControl:AddPropertyButton("CreatesPhysics", "生成物理")

    self._scriptControl:AddPropertyBool("IsDebugSkin", "调试皮肤", iddebugskin, true, false)

    local ftstr = PX2_PROJ:GetConfig("framerate")
    local rate = StringHelp:StringToInt(ftstr)
    if 0==rate then
        PX2_APP:SetFixFrameRate(-1)
    elseif 1==rate then
        PX2_APP:SetFixFrameRate(30)
    elseif 2==rate then
        PX2_APP:SetFixFrameRate(40)
    elseif 3==rate then
        PX2_APP:SetFixFrameRate(60)
    end
    PX2Table2Vector({ "-1", "30", "40", "60"})
    self._scriptControl:AddPropertyEnum("FrameRate", "帧率", rate, PX2_GH:Vec(), true, false)    

    self._scriptControl:AddPropertyClass("CtrlParam", "鼠标控制参数")
    self._scriptControl:AddPropertyFloatSlider ("HorAdjust", "水平移动调节", g_manykit._mouseHorAdjust, 0.0, 3.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("VerAdjust", "垂直移动调节", g_manykit._mouseVerAdjust, 0.0, 3.0, true, false)
    self._scriptControl:AddPropertyFloatSlider ("HorAdjustR", "水平旋转调节", g_manykit._mouseHorAdjust_r, 0.0, 3.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("VerAdjustR", "垂直旋转调节", g_manykit._mouseVerAdjust_r, 0.0, 3.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("WheelAdjust", "滚轮调节", g_manykit._mouseWheelAdjust, 0.0, 3.0, true, false)

    self._scriptControl:AddPropertyFloatSlider("FirstViewHorAdjust", "第一人称水平旋转", g_manykit._mouseHorDragAdjust, 0.0, 3.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("FirstViewVerAdjust", "第一人称垂直旋转", g_manykit._mouseVerDragAdjust, 0.0, 3.0, true, false)

    self._scriptControl:AddPropertyClass("CtrlCam", "MR控制参数")
    self._scriptControl:AddPropertyFloatSlider("cam_sw", "sw", g_manykit._mrCameraScreenWidth, 1.0, 2500.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("cam_sh", "sh", g_manykit._mrCameraScreenHeight, 1.0, 2500.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("cam_near", "near", g_manykit._mrCameraNear, 0.1, 3.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("cam_far", "far", g_manykit._mrCameraFar, 1.0, 1000.0, true, false)
    -- self._scriptControl:AddPropertyFloatSlider("cam_scale", "scale", g_manykit._slamPosScale, 0.1, 2.0, true, false)

    self._scriptControl:AddPropertyFloatSlider("heightadjust", "启动高度", g_manykit._mrHeightAdjust, 0.0, 2.0, true, false)

    self._scriptControl:AddPropertyFloatSlider("slameyetransscale", "slameyetransscale", g_manykit._slamEyeTransScale, 0.1, 2.0, true, false)

    local str = PX2_PROJ:GetConfig("maprotoffset")
    g_manykit._mapRotOffset = AVector:SFromString(str)
    self._scriptControl:AddPropertyFloatSlider("cam_rot_x", "cam_rot_x", g_manykit._mapRotOffset:X(), -30, 30.0, true, false)
    
    self._scriptControl:AddPropertyFloatSlider("cam_obj_offset_x", "cam_obj_offset_x", g_manykit._camObjOffset:X(), -0.1, 0.1, true, false)
    self._scriptControl:AddPropertyFloatSlider("cam_obj_offset_y", "cam_obj_offset_y", g_manykit._camObjOffset:Y(), -0.1, 0.1, true, false)
    self._scriptControl:AddPropertyFloatSlider("cam_obj_offset_z", "cam_obj_offset_z", g_manykit._camObjOffset:Z(), -0.1, 0.1, true, false)

    self._scriptControl:AddPropertyFloatSlider("cam_obj_offset_rot_x", "cam_obj_offset_rot_x", g_manykit._camObjOffsetRot:X(), -10, 10.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("cam_obj_offset_rot_y", "cam_obj_offset_rot_y", g_manykit._camObjOffsetRot:Y(), -10, 10.0, true, false)
    self._scriptControl:AddPropertyFloatSlider("cam_obj_offset_rot_z", "cam_obj_offset_rot_z", g_manykit._camObjOffsetRot:Z(), -10, 10.0, true, false)

    self._scriptControl:AddPropertyClass("Other", "其他")
    self._scriptControl:AddPropertyButton("Exit", "退出")

    self._scriptControl:EndPropertyCata()

    if self._propertyGridSet then
        self._propertyGridSet:RegistOnObject(self._scriptControl, "Set")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnPropertyChangedSet(pObj)
    if "IsDragToTerrain"==pObj.Name then
        local isDragToTerrain =  self._scriptControl:PBool(pObj.Name)
        if isDragToTerrain then
            print("isDragToTerrain 1")

            PX2_EDIT.IsSnapToTerrain = 1
            PX2_PROJ:SetConfig("snaptoterrain", "1")
        else
            print("isDragToTerrain 0")

            PX2_EDIT.IsSnapToTerrain = 0
            PX2_PROJ:SetConfig("snaptoterrain", "0")
        end
    elseif "IsSnapToGrid"==pObj.Name then
        local isDragToGrid = self._scriptControl:PBool(pObj.Name)
        if isDragToGrid then
            PX2_EDIT.IsSnapToGrid = 1
            PX2_PROJ:SetConfig("snaptogrid", "1")
        else
            PX2_EDIT.IsSnapToGrid = 0
            PX2_PROJ:SetConfig("snaptogrid", "0")
        end
    elseif "SnapGridSize"==pObj.Name then
        PX2_EDIT.DragMoveSpace = pObj:PFloat()
    elseif "Wireframe"==pObj.Name then
        local wireframe = self._scriptControl:PBool(pObj.Name)
        self:_ShowWireframe(wireframe)
    elseif "IsDebugPhysics"==pObj.Name then
        local isdebugphy = pObj:PBool()
        print("IsDebugPhysics:")
        print_i_b(isdebugphy)
        PX2_GH:SetDebugPhysics(isdebugphy)
    elseif "CreatesPhysics"==pObj.Name then
        local scene = PX2_PROJ:GetScene()
        if scene then
            scene:CreatePhysics()
        end
    elseif "IsDebugSkin"==pObj.Name then
        local isdebugskin = pObj:PBool()
        PX2_GH:SetDebugSkin(isdebugskin)
    elseif "HorAdjust"==pObj.Name then
        g_manykit._mouseHorAdjust = pObj:PFloat()
        self:_UpdateCfgParam(true)
    elseif "VerAdjust"==pObj.Name then
        g_manykit._mouseVerAdjust = pObj:PFloat()   
        self:_UpdateCfgParam(true)
    elseif "HorAdjustR"==pObj.Name then
        g_manykit._mouseHorAdjust_r = pObj:PFloat()     
        self:_UpdateCfgParam(true)
    elseif "VerAdjustR"==pObj.Name then
        g_manykit._mouseVerAdjust_r = pObj:PFloat()      
        self:_UpdateCfgParam(true)
    elseif "WheelAdjust"==pObj.Name then
        g_manykit._mouseWheelAdjust = pObj:PFloat()     
        self:_UpdateCfgParam(true)
    elseif "FirstViewHorAdjust"==pObj.Name then
        g_manykit._mouseHorDragAdjust = pObj:PFloat()      
        self:_UpdateCfgParam(true)
    elseif "FirstViewVerAdjust"==pObj.Name then
        g_manykit._mouseVerDragAdjust = pObj:PFloat()   
        self:_UpdateCfgParam(true)
    elseif "cam_sw"==pObj.Name then
        g_manykit._mrCameraScreenWidth = pObj:PFloat()
        self:_SaveCameraMRCfg()
        p_holospace._g_holospace:_AdjustCameraMR()
    elseif "cam_sh"==pObj.Name then
        g_manykit._mrCameraScreenHeight = pObj:PFloat()
        self:_SaveCameraMRCfg()
        p_holospace._g_holospace:_AdjustCameraMR()
    elseif "cam_near"==pObj.Name then
        g_manykit._mrCameraNear = pObj:PFloat()
        self:_SaveCameraMRCfg()
        p_holospace._g_holospace:_AdjustCameraMR()
    elseif "cam_far"==pObj.Name then
        g_manykit._mrCameraFar = pObj:PFloat()
        self:_SaveCameraMRCfg()
        p_holospace._g_holospace:_AdjustCameraMR()
    elseif "cam_scale"==pObj.Name then
        g_manykit._slamPosScale = pObj:PFloat()
        self:_SaveCameraMRCfg()
    elseif "slameyetransscale"==pObj.Name then
        g_manykit._slamEyeTransScale = pObj:PFloat()
        self:_SaveCameraMRCfg()
        p_holospace._g_holospace:_AdjustCameraMR()
    elseif "heightadjust"==pObj.Name then
        g_manykit._mrHeightAdjust = pObj:PFloat()
        PX2_PROJ:SetConfig("mrheightadjust", ""..g_manykit._mrHeightAdjust)
    elseif "cam_rot_x"==pObj.Name then
        local v = pObj:PFloat()
        g_manykit._mapRotOffset = AVector(v, 0.0, 0.0)
        PX2_PROJ:SetConfig("maprotoffset", g_manykit._mapRotOffset:ToString())

    elseif "cam_obj_offset_x"==pObj.Name then
        local v = pObj:PFloat()
        g_manykit._camObjOffset = AVector(v, g_manykit._camObjOffset:Y(), g_manykit._camObjOffset:Z())
        PX2_PROJ:SetConfig("camobjoffset", g_manykit._camObjOffset:ToString())
    elseif "cam_obj_offset_y"==pObj.Name then
        local v = pObj:PFloat()
        g_manykit._camObjOffset = AVector( g_manykit._camObjOffset:X(), v, g_manykit._camObjOffset:Z())
        PX2_PROJ:SetConfig("camobjoffset", g_manykit._camObjOffset:ToString())
    elseif "cam_obj_offset_z"==pObj.Name then
        local v = pObj:PFloat()
        g_manykit._camObjOffset = AVector( g_manykit._camObjOffset:X(), g_manykit._camObjOffset:Y(), v)
        PX2_PROJ:SetConfig("camobjoffset", g_manykit._camObjOffset:ToString())

    elseif "cam_obj_offset_rot_x"==pObj.Name then
        local v = pObj:PFloat()
        g_manykit._camObjOffsetRot = AVector(v, g_manykit._camObjOffsetRot:Y(), g_manykit._camObjOffsetRot:Z())
        PX2_PROJ:SetConfig("camobjoffsetrot", g_manykit._camObjOffsetRot:ToString())
    elseif "cam_obj_offset_rot_y"==pObj.Name then
        local v = pObj:PFloat()
        g_manykit._camObjOffsetRot = AVector( g_manykit._camObjOffsetRot:X(), v, g_manykit._camObjOffsetRot:Z())
        PX2_PROJ:SetConfig("camobjoffsetrot", g_manykit._camObjOffsetRot:ToString())
    elseif "cam_obj_offset_rot_z"==pObj.Name then
        local v = pObj:PFloat()
        g_manykit._camObjOffsetRot = AVector( g_manykit._camObjOffsetRot:X(), g_manykit._camObjOffsetRot:Y(), v)
        PX2_PROJ:SetConfig("camobjoffsetrot", g_manykit._camObjOffsetRot:ToString())

    elseif "FrameRate"==pObj.Name then
        local rate = pObj:PInt()
        if 0==rate then
            PX2_APP:SetFixFrameRate(-1)
        elseif 1==rate then
            PX2_APP:SetFixFrameRate(30)
        elseif 2==rate then
            PX2_APP:SetFixFrameRate(40)
        elseif 3==rate then
            PX2_APP:SetFixFrameRate(60)
        end
        PX2_PROJ:SetConfig("framerate", ""..rate)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_SaveCameraMRCfg()
    PX2_PROJ:SetConfig("cam_sw", g_manykit._mrCameraScreenWidth)
    PX2_PROJ:SetConfig("cam_sh", g_manykit._mrCameraScreenHeight)
    PX2_PROJ:SetConfig("cam_near", g_manykit._mrCameraNear)
    PX2_PROJ:SetConfig("cam_far", g_manykit._mrCameraFar)
    PX2_PROJ:SetConfig("cam_scale", g_manykit._slamPosScale)
    PX2_PROJ:SetConfig("slameyetransscale", g_manykit._slamEyeTransScale)

    local wRecParent = g_manykit._frameTouch:GetWorldRect(nil)
    local w = wRecParent:Width()
    local h = wRecParent:Height()
    print("w,h:"..w..","..h)
end
-------------------------------------------------------------------------------
function p_mworld:_ShowWireframe(wireframe)
    print(self._name.." p_mworld:_ShowWireframe")
    print_i_b(wireframe)

    local canvas = PX2_ENGINESCENECANVAS
    if canvas then
        if wireframe then
            canvas:SetOverWireframe(true)
        else
            canvas:SetOverWireframe(false)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_UpdateCfgParam(iswrite)
    print(self._name.." p_mworld:_UpdateCfgParam")

    if iswrite then
        g_manykit._inputControlParam.mhor = g_manykit._mouseHorAdjust
        g_manykit._inputControlParam.mver = g_manykit._mouseVerAdjust
        g_manykit._inputControlParam.mhor_r = g_manykit._mouseHorAdjust_r
        g_manykit._inputControlParam.mver_r = g_manykit._mouseVerAdjust_r
        g_manykit._inputControlParam.mwheel = g_manykit._mouseWheelAdjust
        g_manykit._inputControlParam.mhor_f = g_manykit._mouseHorDragAdjust
        g_manykit._inputControlParam.mver_f = g_manykit._mouseVerDragAdjust
    else
        g_manykit._mouseHorAdjust = g_manykit._inputControlParam.mhor
        g_manykit._mouseVerAdjust = g_manykit._inputControlParam.mver
        g_manykit._mouseHorAdjust_r = g_manykit._inputControlParam.mhor_r
        g_manykit._mouseVerAdjust_r = g_manykit._inputControlParam.mver_r
        g_manykit._mouseWheelAdjust = g_manykit._inputControlParam.mwheel
        g_manykit._mouseHorDragAdjust = g_manykit._inputControlParam.mhor_f
        g_manykit._mouseVerDragAdjust = g_manykit._inputControlParam.mver_f
    end

    local retstr = PX2JSon.encode(g_manykit._inputControlParam)
    print("retstr:"..retstr)
    if PCEFPlugin then
        PCEFPlugin:SetGlobal("cfg", retstr)
    end

    PX2_PROJ:SetConfig("mousehoradjust", "".. g_manykit._mouseHorAdjust)
    PX2_PROJ:SetConfig("mouseveradjust", "".. g_manykit._mouseVerAdjust)
    PX2_PROJ:SetConfig("mousehoradjust_r", "".. g_manykit._mouseHorAdjust_r)
    PX2_PROJ:SetConfig("mouseveradjust_r", "".. g_manykit._mouseVerAdjust_r)
    PX2_PROJ:SetConfig("mousewheeladjust", "".. g_manykit._mouseWheelAdjust)
    PX2_PROJ:SetConfig("firstviewhoradjust", "".. g_manykit._mouseHorDragAdjust)
    PX2_PROJ:SetConfig("firstviewveradjust", "".. g_manykit._mouseVerDragAdjust)

    if not iswrite then
       
        self._scriptControl:BeginPropertyCata("Set")
    
        self._scriptControl:AddPropertyClass("CtrlParam", "鼠标控制参数")
        self._scriptControl:AddPropertyFloatSlider ("HorAdjust", "水平移动调节", g_manykit._mouseHorAdjust, 0.0, 3.0, true, false)
        self._scriptControl:AddPropertyFloatSlider("VerAdjust", "垂直移动调节", g_manykit._mouseVerAdjust, 0.0, 3.0, true, false)
        self._scriptControl:AddPropertyFloatSlider ("HorAdjustR", "水平旋转调节", g_manykit._mouseHorAdjust_r, 0.0, 3.0, true, false)
        self._scriptControl:AddPropertyFloatSlider("VerAdjustR", "垂直旋转调节", g_manykit._mouseVerAdjust_r, 0.0, 3.0, true, false)
        self._scriptControl:AddPropertyFloatSlider("WheelAdjust", "滚轮调节", g_manykit._mouseWheelAdjust, 0.0, 3.0, true, false)
    
        self._scriptControl:EndPropertyCata()

        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "HorAdjust")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "VerAdjust")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "HorAdjustR")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "VerAdjustR")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "WheelAdjust")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "FirstViewHorAdjust")
        self._propertyGridSet:UpdateOnObject(self._scriptControl, "Set", "FirstViewVerAdjust")
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnPropertyEditChangedScene(pObj)
    print(self._name.." p_mworld:_OnPropertyEditChangedScene")
    
end
-------------------------------------------------------------------------------