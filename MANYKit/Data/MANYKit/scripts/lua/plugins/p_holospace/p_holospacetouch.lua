-- p_holospacetouch.lua

function p_holospace:_HoloSpaceTouch(ptr)
    local obj = Cast:ToO(ptr)
    if obj then
        local scene = PX2_PROJ:GetScene()
        local radius = scene.WorldBound:GetRadius()
        local wRecParent = obj:GetWorldRect(nil)
        local wRecParentHalf = Rectf(wRecParent.Left, wRecParent.Bottom, wRecParent.Right*0.5, wRecParent.Top)

        local camera = scene:GetMainCameraNode():GetCamera()     

        local lastPickData = obj:GetLastPickData()
        local moveDetail = lastPickData.MoveDelta
        local moveDetailLength = moveDetail:Length()
        local logicPos = lastPickData.LogicPos

        local x = logicPos:X() - wRecParent.Left
        local z = logicPos:Z() - wRecParent.Bottom
        local xx = x/wRecParent:Width()
        local yy = z/wRecParent:Height()

        self._lastPickPos = self._curPickPos
        self._curPickPos = APoint(x, logicPos:Y(), z)

        local useRect = wRecParent
        if g_manykit._isMRMode then
            useRect = wRecParentHalf

            if xx >= 0.5 then
                xx = (xx-0.5)/0.5
                self._curPickPos = APoint(x-wRecParent:Width()*0.5, logicPos:Y(), z)
            else
                xx = xx/0.5
                self._curPickPos = APoint(x, logicPos:Y(), z)
            end
        end

        if UIPT_PRESSED == lastPickData.PickType then
            self._moveDeltaLengthAll = 0.0
            self._isPressed = true
            self._isMoved = false
            if lastPickData.TheMouseTag == 1 then
                self._isLeftPressed = true
                self:_OnLeftDown(camera, xx, yy, useRect, lastPickData.TheMouseTag)
            elseif lastPickData.TheMouseTag == 2 then
                self._isRightPressed = true
                self:_OnRightDown(camera, xx, yy, useRect, lastPickData.TheMouseTag)
            end
        elseif UIPT_RELEASED == lastPickData.PickType then
            self._isPressed = false
            if lastPickData.TheMouseTag == 1 then
                self._isLeftPressed = false
                self:_OnLeftUp(camera, xx, yy, useRect, lastPickData.TheMouseTag)
            elseif lastPickData.TheMouseTag == 2 then
                self._isRightPressed = false
                self:_OnRightUp(camera, xx, yy, useRect, lastPickData.TheMouseTag)
            end
        elseif UIPT_MOVED == lastPickData.PickType then
            self._moveDeltaLengthAll = self._moveDeltaLengthAll + moveDetailLength
            if self._moveDeltaLengthAll>5.0 then
                self._isMoved = true
            end
            self:_OnMove(camera, xx, yy, useRect, lastPickData.TheMouseTag)
        elseif UIPT_WHELLED == lastPickData.PickType then   
		end
	end
end
-------------------------------------------------------------------------------
function p_holospace:_OnLeftDown(camera, xx, yy, wRecParent, mTag)
    p_holospace._g_mouse_x = xx
    p_holospace._g_mouse_y = yy
    p_holospace._g_wRecParent = wRecParent
    p_holospace._g_mTag = mTag

    local w = wRecParent:Width()
    local h = wRecParent:Height()
    local x = w * xx
    local y = h * yy   

    if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
    else
        if PX2_SELECTM_D:GetNumObjects() > 0 then
            if p_holospace._g_curSceneNodeCtrl then
                p_holospace._g_curSceneNodeCtrl:OnLeftDown(camera, self._curPickPos, Sizef(wRecParent:Width(), wRecParent:Height()))
            end
        end
        
        self:_PickFire(false)
    end

    self:_PickMap(xx, yy, wRecParent, 1, 0.0, mTag)
end
-------------------------------------------------------------------------------
function p_holospace:_PickFire(isQ)
    local scene = PX2_PROJ:GetScene()
    local camera = scene:GetMainCameraNode():GetCamera() 
    local mainActor = scene:GetMainActor()
    if mainActor then
        local agent = mainActor:GetAIAgent()
        if agent and agent:IsAlive() then
            local ctrl, scCtrlChara = g_manykit_GetControllerDriverFrom(mainActor, "p_chara")
            local ctrl, scCtrlHumain = g_manykit_GetControllerDriverFrom(mainActor, "p_human")
            local ctrl, scCtrlVehicle = g_manykit_GetControllerDriverFrom(mainActor, "p_vehicle")
            local ctrl, scCtrlWeapon = g_manykit_GetControllerDriverFrom(mainActor, "p_weapon")
            if scCtrlVehicle then
                if isQ then
                    scCtrlVehicle:_Fire()
                end
            elseif scCtrlHumain then
                if scCtrlChara and scCtrlChara._isOnFirstView then
                    local tm = scCtrlChara._agent:GetHumanTakePossessed()
                    if tm~=AIAgent.HTPM_NONE then
                        scCtrlChara:_CheckSetAimingPos(camera,  p_holospace._g_mouse_x, p_holospace._g_mouse_y, p_holospace._g_wRecParent, p_holospace._g_mTag)
                        scCtrlChara:_Fire()
                    end
                end
            elseif scCtrlWeapon then
                if isQ then
                    scCtrlWeapon:_Fire()
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_PickGetScreenPos(x, y)
    local posPick = APoint(0, 0, 0)

    local scene = PX2_PROJ:GetScene()
    local cameraNode = scene:GetMainCameraNode()
    local camera = cameraNode:GetCamera() 

    local objSky = scene:GetObjectByID(p_holospace._g_IDNodeSky)
    objSky:SetDoPick(true)
    scene:GetNodeSky():SetDoPick(true)
    scene:GetMeshSky():SetDoPick(true)

    local origin = APoint(0.0, 0.0, 0.0)
    local direction = AVector(0.0, 0.0, 0.0)
    
    camera:GetPickRay(x, y, origin, direction)

    origin = camera:GetLastPickOrigin()
    direction = camera:GetLastPickDirection()
    local pickMov = scene
    local picker = Picker()
    picker:Execute(pickMov, origin, direction, 0.0, Mathf.MAX_REAL)
    local picRec = picker:GetClosestNonnegative()
    if picRec.Intersected then
        local trans = picRec.Intersected.WorldTransform
        posPick = picRec.WorldPos
    end

    scene:GetNodeSky():SetDoPick(false)
    scene:GetMeshSky():SetDoPick(false)
    objSky:SetDoPick(false)

    return posPick
end
-------------------------------------------------------------------------------
function p_holospace:_OnLeftUp(camera, xx, yy, wRecParent, mTag) 
    p_holospace._g_mouse_x = xx
    p_holospace._g_mouse_y = yy
    p_holospace._g_wRecParent = wRecParent
    p_holospace._g_mTag = mTag

    self:_PickMap(xx, yy, wRecParent, 2, mTag)

    if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
    else
        if PX2_SELECTM_D:GetNumObjects() > 0 then
            if p_holospace._g_curSceneNodeCtrl then
                local dt = p_holospace._g_curSceneNodeCtrl:GetDragType()
                p_holospace._g_curSceneNodeCtrl:OnDragClose()

                if p_holospace._g_curSceneNodeCtrl:IsEnable() then
                    if dt == SceneNodeCtrl.DT_NONE then
                        -- not draged
                        PX2_GH:SendGeneralEvent("OnDragClose", "0")
                    else
                        PX2_GH:SendGeneralEvent("OnDragClose", "1")
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_OnRightDown(camera, xx, yy, wRecParent, mTag)
    p_holospace._g_mouse_x = xx
    p_holospace._g_mouse_y = yy
    p_holospace._g_wRecParent = wRecParent
    p_holospace._g_mTag = mTag

    if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
    else
        self:_PickAim(true)
    end
end
-------------------------------------------------------------------------------
function p_holospace:_OnRightUp(camera, xx, yy, wRecParent, mTag)
    p_holospace._g_mouse_x = xx
    p_holospace._g_mouse_y = yy
    p_holospace._g_wRecParent = wRecParent
    p_holospace._g_mTag = mTag

    if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
    else
        self:_PickAim(false)
    end
end
-------------------------------------------------------------------------------
function p_holospace:_PickAim(doaim)
    local scene = PX2_PROJ:GetScene()
    local camera = scene:GetMainCameraNode():GetCamera() 
    local mainActor = scene:GetMainActor()
    if mainActor then
        local ctrl, scCtrlChara = g_manykit_GetControllerDriverFrom(mainActor, "p_chara")
        if scCtrlChara then
            scCtrlChara:_Aim(doaim)
        end
    end
end
-------------------------------------------------------------------------------
function p_holospace:_OnMove(camera, xx, yy, wRecParent, mTag)
    p_holospace._g_mouse_x = xx
    p_holospace._g_mouse_y = yy
    p_holospace._g_wRecParent = wRecParent
    p_holospace._g_mTag = mTag

    if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
        self:_PickMap(xx, yy, wRecParent, 3, mTag)
    else
        if PX2_SELECTM_D:GetNumObjects() > 0 then
            if p_holospace._g_curSceneNodeCtrl then
                p_holospace._g_curSceneNodeCtrl:OnMotionCalDragType(camera, self._curPickPos, Sizef(wRecParent:Width(), wRecParent:Height()))
    
                if self._isLeftPressed then
                    p_holospace._g_curSceneNodeCtrl:OnDragingOld(camera, self._curPickPos, self._lastPickPos, Sizef(wRecParent:Width(), wRecParent:Height()))
                end
            end
        end
    end
end
function p_holospace:_PickMap(x, y, wRecParent, pickType, mTag)
	--print(self._name.." p_holospace:_PickMap x:"..x.." y:"..y.." pt:"..pickType.." mTag:"..mTag)

    -- pick object
    local scene = PX2_PROJ:GetScene()
    local cameraNode = scene:GetMainCameraNode()
    local mainActor = scene:GetMainActor()
    local camera = cameraNode:GetCamera()
    local terrain = scene:GetTerrain()
    local nodeRoot = scene:GetNodeRoot()

    local pickself = true

    if mainActor then
        local ctrl, scCtrlChara = g_manykit_GetControllerDriverFrom(mainActor, "p_chara")
        if scCtrlChara then
            if scCtrlChara._isOnFirstView then
                return
            end
        end
    end

    if not pickself then
        if mainActor then
            mainActor:SetDoPick(false)
        end
    end

    local origin = APoint(0.0, 0.0, 0.0)
    local direction = AVector(0.0, 0.0, 0.0)
    camera:GetPickRay(x, y, origin, direction)
    origin = camera:GetLastPickOrigin()
    direction = camera:GetLastPickDirection()

    --print("origin:"..origin:ToString())
    --print("direction:"..direction:ToString())

    local pickMov = scene
    if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
        pickMov = terrain
    end

    local picker = Picker()
    picker:Execute(pickMov, origin, direction, 0.0, Mathf.MAX_REAL)
    local picRec = picker:GetClosestNonnegative()
    if picRec.Intersected then
        local interName = picRec.Intersected:GetName()
        local trans = picRec.Intersected.WorldTransform
        local worldPos = picRec.WorldPos
        local worldNormal = trans * picRec.LocalNormal

        local uniScale = nodeRoot.WorldTransform:GetUniformScale()
        if 1.0~=uniScale then
            local transInverse = nodeRoot.WorldTransform:InverseTransform()
            worldPos = transInverse * worldPos
        end

        --print("WorldPos:"..worldPos:ToString())

        for i=1, #self._pickCallbacks, 1 do
            local cb = self._pickCallbacks[i]
            if cb then
                cb.callback(cb.obj, picRec.Intersected, worldPos, worldNormal, pickType, self._isMoved, mTag)
            end
        end
    else
        --print("no Intersected!!!!!!!")
    end
    
    if not pickself then
        if mainActor then
            mainActor:SetDoPick(true)
        end
    end
end