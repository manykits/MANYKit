-- p_mworldedit.lua

-- pick
-------------------------------------------------------------------------------
function p_mworld:_PickMapCallback(pickobj, worldPos, worldNormal, ptype, isMoved, mouseTag)
    print(self._name.." p_mworld:_PickMapCallback")

    local scene = PX2_PROJ:GetScene()
    local ter = scene:GetTerrain()
    
    local pickname = ""
    if pickobj then
        pickname = pickobj:GetName()
    end

    if self._isediting then
        if self._curSelectActorID>0 then
            local scene = PX2_PROJ:GetScene()
            if scene then
                local actor = scene:GetActorFromMap(self._curSelectActorID)
                if actor then
                    if not isMoved and ptype==2 then
                        local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
                        if scCtrl then
                            scCtrl:_OnEditPick(pickobj, worldPos, worldNormal, ptype, isMoved, mouseTag)
                        end
                    end
                end
            end
        else
            if PX2_EDIT:GetTerrainEdit():IsEditEnabled() then
                PX2_EDIT:GetTerrainEdit():GetBrush():SetPos(worldPos)
                
                if 1==ptype then
                    -- pressed
                    PX2_EDIT:GetTerrainEdit():GetBrush():SelectPage()
                    self._isTerrainEditApplyed = false
                    self._isTerrainEditStarting = true
                elseif 2==ptype then
                    if PX2_EDIT.IsCtrlDown then
                        if not isMoved and 1==mTag then
                            PX2_EDIT:GetTerrainEdit():Apply(true)
                        end
                    end
                    self._isTerrainEditStarting = false
                elseif 3==ptype then
                    if PX2_EDIT.IsCtrlDown and self._isTerrainEditStarting then
                        if not self._isTerrainEditApplyed then
                            PX2_EDIT:GetTerrainEdit():Apply(true)
                            self._isTerrainEditApplyed = true
                        else
                            PX2_EDIT:GetTerrainEdit():Apply(false)
                        end
                    end
                end
            end

            if self._vs then
                local pw = g_manykit:GetPluginTreeInstanceByName("p_mworld")
                local bt = pw:_GetBarSelectBlockType()

                local targetPos = worldPos + worldNormal * 0.01
                self._vs:SetBlock(targetPos, bt, nil)
            end
        end
    else
        if not isMoved and ptype==2 then
            print("pickname:")
            print(pickname)

            if pickobj then
                local mov = Cast:ToMovable(pickobj)
                if mov then
                    local par = mov:GetParent()
                    if par then
                        local tp = Cast:ToTerrainPage(par)
                        if tp then
                            local lons = tp:GetLonStart()
                            local lone = tp:GetLonEnd()
                            local lats = tp:GetLatStart()
                            local late = tp:GetLatEnd()
        
                            print("lons:"..lons)
                            print("lone:"..lone)
                            print("lats:"..lats)
                            print("late:"..late)

                            --tp:GetHeightWorld(worldPos:X(), worldPos:Y())
                        end
                    end
                end
            end
            
            if "ModelModelPick"==pickname then
                local idstr = pickobj:GetUserDataString("id")
                local idi = tonumber(idstr)
        
                self:_TrySelectObj(idi, false)
            else
                if self._curSelectActorID > 0 then
                    self:_OnDisSelectObj(true)
                    
                    if self._frameAdjFText then
                        self._frameAdjFText:GetText():SetText("当前选择的角色信息：\n 无")
                    end
                end
                
                local scene = PX2_PROJ:GetScene()
                local meActor = scene:GetMeActor()
                if meActor then
                    local skillChara = meActor:GetSkillChara()
                    local itemID = self._curSelectBarItemIDForPutting
                    if itemID>0 then
                        local item = skillChara:GetItemByID(itemID)
                        if item then
                            local typeID = item:GetTypeID()
                            local itemDef = item:GetDefItem()
                            if itemDef then
                                local charaID = itemDef.CharaID

                                if DefItem.T_NORMAL==itemDef.TheType then
                                    self:_RequestAddObject(itemID, charaID, worldPos:ToString(), 0)
                                elseif DefItem.T_BLOCK==itemDef.TheType then
                                    local targetPos = worldPos + worldNormal * 0.01
                                    local bt = StringHelp:StringToInt(itemDef.Mtl)
                                    self._vs:SetBlock(targetPos, bt, nil)
                                end
                            end
                        end
                        self._curSelectBarItemIDForPutting = 0
                    else
                        self:_RegistPropertyOnScene()
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------

-- select
-------------------------------------------------------------------------------
function p_mworld:_OnSelectObj(idi, fromlistmap)
    print(self._name.." p_mworld:_OnSelectObj:"..idi)

    local scene = PX2_PROJ:GetScene()
    local actor = scene:GetActorFromMap(idi)
    if actor then
        PX2_SELECTM_D:AddObject(actor)

        if PX2_SS then
            PX2_SS:PlayASound(g_manykit._media.scene_select, g_manykit._soundVolume, 1.0)
        end
        self._curSelectActorID = idi

        -- property
        self:_RegistPropertyOnActor(actor)
        
        -- select box           
        if not fromlistmap then
            -- items
            if self._listMapItems then
                self._listMapItems:ClearAllSelectItems()
                local item = self._listMapItems:GetItemByUserDataString("id", ""..idi)
                if item then
                    self._listMapItems:AddSelectItem(item)
                end
            end
        end

        local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
        if scCtrl then
            scCtrl:_OnSelected("edit")
        end

        -- 当前选择的角色信息
        local orglevel = actor:GetUserDataString("orglevel")
        local orgid = actor:GetUserDataString("orgid")
        local feature = actor:GetUserDataString("feature")
        local entityid = actor:GetUserDataString("entityid")
        --local idii = act:GetUserDataString("id")
        local pos = actor.LocalTransform:GetTranslate()
        local x = string.format("%.1f", pos:X())
        local y = string.format("%.1f", pos:Y())
        local z = string.format("%.1f", pos:Z())

        local skillChara = actor:GetSkillChara()
        if skillChara then
            --local id = skillChara:GetID()--idi
            local typeID = skillChara:GetTypeID()--CharaID

            local defModel = skillChara:GetDefModel()
            if defModel then
                --local modelID = defModel.ID
                local modelName = defModel.Name

                local Bullet = ""
                local Group = "" 
                local Anim = ""
                local Anim1 = ""
                local curHP = ""
                local curap = ""
                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
                if scCtrl then
                    local BulletPropertyObj = scCtrl._node:GetPropertyByName("Bullet")
                    if BulletPropertyObj then
                        Group = scCtrl._group
                        Anim = scCtrl._anim
                        Anim1 = scCtrl._anim1
                        curHP = skillChara:GetCurHP()
                        curap = skillChara:GetCurAP()
                    end
                end

                if self._frameAdjFText then
                    --当前选择的角色信息:导弹
                    local text = "id:"..idi..", typeID:"..typeID..", pos:["..x..", "..y..", "..z.."]"
                    if curHP~="" then
                        text = text..",\ncurHP:"..curHP..", Bullet:"..Bullet..", curap:"..curap
                        text = text..",\nGroup:"..Group..", Anim:"..Anim..", Anim1:"..Anim1
                    end
                    text = text..",\nName:"..modelName..",\norglevel:"..orglevel..", orgid:"..orgid..", feature:"..feature..", "
                    self._frameAdjFText:GetText():SetText(text)
                end
            end
        end
        local dtrb = {
            id = idi,
            entityId = entityid
        }
        local dtstr = PX2JSon.encode(dtrb)
        if gframeCEF then
            gframeCEF:CallJS("window.slectActor(" .. dtstr .. ")")
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_OnDisSelectObj(playsound)
    print(self._name.." p_mworld:_OnDisSelectObj")

    local scene = PX2_PROJ:GetScene()

    if not self._isediting then
        if self._curSelectActorID > 0 then
            local actor = scene:GetActorFromMap(self._curSelectActorID)
            if actor then
                if playsound then
                    if PX2_SS then
                        PX2_SS:PlayASound(g_manykit._media.scene_unselect, g_manykit._soundVolume, 1.0)
                    end
                end

                local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
                if scCtrl then
                    scCtrl:_OnDisSelected("edit")
                end
            end

            PX2_SELECTM_D:Clear()
        end

        self._curSelectActorID = -1

        if gframeCEF then
            gframeCEF:CallJS("window.slectActor(-1)")
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_TrySelectObj(idi, fromlistmap)
    if not self._isediting then
        if idi~=self._curSelectActorID then
            self:_OnDisSelectObj(false)
            self:_OnSelectObj(idi, fromlistmap)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_DeleteCurSelectObj()
    if self._curSelectActorID>0 then
        if self._isediting then
            local scene = PX2_PROJ:GetScene()
            if scene then
                local actor = scene:GetActorFromMap(self._curSelectActorID)
                if actor then
                    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(actor, "p_actor")
                    if scCtrl then
                        --scCtrl:_DeleteSelectCtrlPoint()
                    end
                end
            end
        else
            self:_RequestDeleteObj(self._curSelectActorID)
        end
    end
end
-------------------------------------------------------------------------------