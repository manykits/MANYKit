-- p_mworlduibat.lua

-------------------------------------------------------------------------------
function p_mworld:_UIRefreshSkill(frame, skill)
    local sid = skill:GetID()
    local skillTypeID = skill:GetTypeID()
    
    local btn = frame:GetObjectByName("BtnItem")
    local frame = frame:GetObjectByID(10)
    local fText = frame:GetObjectByID(103)
    local fPicBox = frame:GetObjectByID(102)

    if btn and frame and fText and fPicBox then
        btn:SetName("BtnItemSkill")
        btn:SetUserDataInt("skilltypeid", skillTypeID)
        btn:SetColor(Float3:MakeColor(41, 41, 54))

        frame:Show(true)

        local defSkill = skill:GetDefSkill()
        if defSkill then
            fText:GetText():SetText(defSkill.Title)

            local icon = defSkill.Icon
            if icon then
                print("icon:"..icon)
                local pth = self:_imgpthmworld("items/"..icon..".png")
                fPicBox:GetUIPicBox():SetTexture(pth)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_UITakeCtrlActorRefreshItem(frame, item)
    local iid = item:GetID()
    local itemTypeID = item:GetTypeID()
    local isfixed = item:IsFixed()

    local btn = frame:GetObjectByName("BtnItem")
    local btnOperator = frame:GetObjectByName("BtnOperator")
    local frame = frame:GetObjectByID(10)
    local fText = frame:GetObjectByID(103)
    local fPicBox = frame:GetObjectByID(102)

    if btn and frame and fText and fPicBox then
        btn:SetName("BtnItemItem")
        btn:SetUserDataInt("itemtypeid", itemTypeID)
        btn:SetColor(Float3:MakeColor(41, 41, 54))

        frame:Show(true)

        if btnOperator then
            btnOperator:SetUserDataInt("id", iid)

            local numSubObjects = item:GetNumSubObjectTypes()
            btnOperator:Show(numSubObjects>0)

            for i=0, numSubObjects-1, 1 do
                local tid = item:GetSubObjectTypeID(i)
                local numMax = item:GetSubObjectNumMax(tid)
                local num = item:GetSubObjectNum(tid)

                local tOption = btnOperator:GetText()
                tOption:SetText(""..itemTypeID..":"..num.."/"..numMax)
            end
        end

        local defItem = item:GetDefItem()
        if defItem then
            local name = defItem.Name
            if isfixed then
                name = name .. "_f"
            end
            fText:GetText():SetText(name)
            fText:GetText():SetFontScale(0.5)

            local pth = self:_GetItemIconPath(defItem)
            fPicBox:GetUIPicBox():SetTexture(pth)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_SkillItemSelect(obj)
    print(self._name.." p_mworld:_SkillItemSelect")

    local scene = PX2_PROJ:GetScene()
    local act = scene:GetMainActor()

    local skillTypeID = obj:GetUserDataInt("skilltypeid")
    print("skillTypeID:"..skillTypeID)

    if act then
        local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
        if scCtrl then
            local skillChara = act:GetSkillChara()
            local skill = skillChara:GetSkillByTypeID(skillTypeID)
            if skill then
                scCtrl:_CheckSkillActivate(skill, nil, nil, true)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_SkillItemItem(obj)
    print(self._name.." p_mworld:_SkillItemItem")

    local scene = PX2_PROJ:GetScene()
    local act = scene:GetMainActor()

    local itemTypeID = obj:GetUserDataInt("itemtypeid")
    print("itemTypeID:"..itemTypeID)    

    local par = obj:GetParent()
    if par then
        -- local id = par:GetUserDataInt("id")
        -- print("select item:"..id)
        local parNode = Cast:ToSizeNode(par)
        if parNode then
            self._frameSelectBoxOfEquip:DetachFromParent()
            parNode:AttachChild(self._frameSelectBoxOfEquip)
            self._frameSelectBoxOfEquip:Show(true)
        end
    end

    local skillChara = act:GetSkillChara()
    if skillChara then
        local item = skillChara:GetItemByTypeID(itemTypeID)
        if item then
            skillChara:TakeControlOfItem(item)
        end

        print("using item:"..itemTypeID)
    end
end
-------------------------------------------------------------------------------