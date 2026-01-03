--stop.lua
-------------------------------------------------------------------------------
function engine_project_prestop() 
    print("engine_project_prestop")

    -- unRegistEvents
    manykit_unRegistEvents()

    -- detach all children to release all script ctrl
    PX2_GH:SetVirtualKeyBoard(nil)

    local frameMenu = PX2_APP:GetFrameMenu()
    if frameMenu then
        frameMenu:DetachFromParent()
    end

    local ui = PX2_PROJ:GetUI()
    ui:DetachAllChildren()
end
-------------------------------------------------------------------------------
function engine_project_stop()    
	PX2_OPENCVM:Terminate()

    print("engine_project_stop")

    local beforeCanvas = PX2_ENGINECANVAS:GetBeforeCanvas()
    beforeCanvas:DetachAllChildren()

    -- clear _frameRoot first,
    -- let scriptctrl clear first
    PX2_PROJ:PoolSet("_frameRoot", nil)
    PX2_PROJ:PoolClear()

    VLC:Ternimate()

    if 1 == g_manykit._lessfullmode then
        PX2_APP:ClosePlugin("PExt")
    end
end
-------------------------------------------------------------------------------