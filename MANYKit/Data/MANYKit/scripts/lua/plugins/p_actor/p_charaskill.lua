-- p_charaskill.lua

-------------------------------------------------------------------------------
function p_chara:_SetItemRot(typeid, rot)
    print(self._name.." p_chara:_SetItemRot")    
end
-------------------------------------------------------------------------------
function p_chara:_CheckViewMode(message)
    print(self._name.." p_chara:_CheckViewMode") 
    local pw = g_manykit:GetPluginTreeInstanceByName("p_mworld")
    if pw then
        if message == "" then
            pw:_SetViewMode(0)
            return 0
        end
        -- 检测身上的所有已经装备的装备，看是否有夜视仪，是否开启
        local skillChara = self._actor:GetSkillChara()
        if skillChara then
            local numItemEquipped = skillChara:GetNumEquippedItem("def")
            if numItemEquipped > 0 then
                for i=0, numItemEquipped, 1 do
                    local skillItem = skillChara:GetEquippedItem("def", i)
                    if skillItem then
                        local isUsing = skillItem:IsUsing()
                        if isUsing then
                            skillChara:UseItem(skillItem,false)
                            pw:_SetViewMode(0)
                        else
                            skillChara:UseItem(skillItem,true)
                            local defItem = skillItem:GetDefItem()
                            local id = defItem.ID
                            if id == 43293 and message == "weiguang" then
                                pw:_SetViewMode(1)
                            elseif id == 43294 and message == "rechengxiang" then
                                pw:_SetViewMode(2)
                            elseif i == numItemEquipped-1 then
                                pw:_SetViewMode(0)
                            end
                        end
                    end
                end
            else
                pw:_SetViewMode(0)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_chara:_Fire()
    print("p_chara:_Fire ID:"..self._agent:GetID() )

    local skillChara = self._actor:GetSkillChara()
    if skillChara then
        local controlingItem = skillChara:GetControllingItem()
        if controlingItem then
            local skillTypeId = controlingItem:GetDefItem().SkillTypeID
			local skill = skillChara:GetSkillByTypeID(skillTypeId)
            if skill then
                self:_CheckSkillActivate(skill, nil, nil, true)
            end
        else
            local defSkill = skillChara:GetDefSkill()
            if defSkill then
                self:_CheckSkillActivate(defSkill, nil, nil, true)
            else
                local hpos = self:_HandPos()
                local pw = g_manykit:GetPluginTreeInstanceByName("p_mworld")
                if pw then
                    if pw._currentCatchObjectID > 0 then
                        pw._HandDrop()
                    else
                        pw:_HandCatch(self._id, -1, hpos)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_chara:_HandPos()
    local pos = self._agent:GetPosition()
    local dir = self._agent:GetDirection()
    local handPos = APoint(pos:X(), pos:Y(), 1.0)
    handPos = handPos + dir * 0.4

    return handPos
end
-------------------------------------------------------------------------------
function p_chara:_CheckSkillActivate(skill, dosleep, jstr0, isActorAct, pathid)
    if skill then
        if isActorAct then
            if skill:IsSkillCurrentUseSubObjectZero() then
                self:_AutoCharge(skill, dosleep)
            else
                if skill:IsCanActiveSkillInstance() then
                    local ret = skill:MainActivateSkillInstance(true, "", false)
                end
                if skill:IsSkillCurrentUseSubObjectZero() then
                    self:_AutoCharge(skill, dosleep)
                end
            end
        else
            local jstr = ""
            if jstr0 then
                jstr = jstr0
            end

            local skillchara = skill:GetSkillChara()
            if skillchara then
                local act = skillchara:GetOwner()
                if act then
                      -- for weapon
                    act:GetNodeModel():Show(true)
                end
            end

            skill:SetDoCDing(false)

            if skill:IsSkillCurrentUseSubObjectZero() then
                self:_AutoCharge(skill, dosleep)
            else
                if skill:IsCanActiveSkillInstance() then
                    local showLine = g_manykit._isShowSkillLine
                    if pathid then
                        showLine = true
                    end
                    if nil==pathid then
                        print_e("pathid is nil")
                        pathid = "123456"
                    end
                    local ret = skill:MainActivateSkillInstance(true, jstr, false, pathid, true, true, showLine)
                end
                if skill:IsSkillCurrentUseSubObjectZero() then
                    self:_AutoCharge(skill, dosleep)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_chara:_CheckSetAimingPos(camera, x, y, wRecParent, pickType, mTag)
    local scene = PX2_PROJ:GetScene()
    local cameraNode = scene:GetMainCameraNode()

    local nodeSky = scene:GetNodeSky()
    if nodeSky then
        nodeSky:SetDoPick(true)
    end
    local nodeMeshSky = scene:GetMeshSky()
    if nodeMeshSky then
        nodeMeshSky:SetDoPick(true)
    end

    local objSky = scene:GetObjectByID(p_holospace._g_IDNodeSky)
    if objSky then
        objSky:SetDoPick(true)
    end
    local isActorDoPickBefore = self._actor:IsDoPick()
    self._actor:SetDoPick(false)

    local origin = APoint(0.0, 0.0, 0.0)
    local direction = AVector(0.0, 0.0, 0.0)
    
    --self._skillChara
    local hm = self._agent:IsOnHumainTakeProcessMode(AIAgent.HTPM_NONE)
    if hm then
        camera:GetPickRay(x, y, origin, direction)
    else
        camera:GetPickRay(0.5, 0.5, origin, direction)
    end

    origin = camera:GetLastPickOrigin()
    direction = camera:GetLastPickDirection()
    local pickMov = scene
    local picker = Picker()
    picker:Execute(pickMov, origin, direction, 0.0, Mathf.MAX_REAL)
    local picRec = picker:GetClosestNonnegative()
    if picRec.Intersected then
        local trans = picRec.Intersected.WorldTransform
        local worldPos = picRec.WorldPos
        self._skillChara:SetFlyObjectUseAimingPos(true)				
        self._skillChara:SetAimingPos(worldPos)
    else
        self._skillChara:SetFlyObjectUseAimingPos(false)	
    end

    if nodeSky then
        nodeSky:SetDoPick(false)
    end
    if nodeMeshSky then
        nodeMeshSky:SetDoPick(false)
    end

    if objSky then
        objSky:SetDoPick(false)
    end

    self._actor:SetDoPick(isActorDoPickBefore)
end
-------------------------------------------------------------------------------
function p_chara:_AutoCharge(skill, dosleep)
	print(self._name.." p_actor:_AutoCharge")

	local itemID = skill:GetCreatedByItemID()
	if itemID then
		local item = self._skillChara:GetItemByID(itemID)
		if item then
			self:_AutoChargeItem(item, dosleep)
		end
	end
end
-------------------------------------------------------------------------------
function p_chara:_AutoChargeItem(item, dosleep)
	if self._ischarging then
		return
	end

	local numSubObjTypes = item:GetNumSubObjectTypes()
	if numSubObjTypes>0 then
		local chargeSubObjTypeID = item:GetCurrentUseSubObjectTypeID()
		if chargeSubObjTypeID<=0 then
			item:SetCurrentUseSubObjectIndex(0)
		end
		chargeSubObjTypeID = item:GetCurrentUseSubObjectTypeID()
		if chargeSubObjTypeID>0 then
			coroutine.wrap(function()
				self._ischarging = true
                if PX2_SS then
				    PX2_SS:PlayASound("media/audio/bulletready.wav", g_manykit._soundVolume, 2.0)
                end
				
				if nil==dosleep or true==dosleep then
					sleep(2.0)
				end		
				
				self._skillChara:ChargeItemSubObj(item:GetID(), chargeSubObjTypeID)	
				self._ischarging = false
			end)()
		else
			self._ischarging = false
			print("chargeSubObjTypeID = 0")
		end
	else
		self._ischarging = false
	end
end
-------------------------------------------------------------------------------