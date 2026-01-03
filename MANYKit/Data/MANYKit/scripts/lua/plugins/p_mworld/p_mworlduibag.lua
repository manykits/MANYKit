-- p_mworlduibag.lua

-------------------------------------------------------------------------------
function p_mworld:_CreateFrameBag(w, h)
	local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(w, h, "")
    btnClose:SetName("BtnBagClose")
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local frameBagItem = self:_CreateFrameBagItems()
    uiFrame:AttachChild(frameBagItem)
    frameBagItem:LLY(-1.0)
    frameBagItem:SetAnchorHor(0.0, 1.0)
    frameBagItem:SetAnchorVer(0.0, 1.0)
    frameBagItem:SetAnchorParamVer(0.0, 0.0)

    uiFrameBack:SetScriptHandlerNodePicked("_NodePicked", self._scriptControl)

    return uiFrameBack, uiFrame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameBagItems()
    local frame = UIFrame:New()
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    local top = self._bh + 5.0
    local sd = 0.0

    -- bar
    local frameBar = self:_CreateBarItems(true)
    self._frameBagBar = frameBar
    frame:AttachChild(frameBar)
    frameBar:LLY(-2.0)
    frameBar:SetAnchorHor(0.0, 0.0)
    frameBar:SetAnchorParamHor(sd, sd)
    frameBar:SetPivot(0.0, 0.5)
    frameBar:SetAnchorVer(1.0, 1.0)
	frameBar:SetAnchorParamVer(-top * 0.5, -top * 0.5)

    -- cnt
    local frameCnt = self:_CreateFrameBagItemCnts()
    self._frameBagItemsCnt = frameCnt
    frame:AttachChild(frameCnt)
    frameCnt:LLY(-2.0)
    frameCnt:SetAnchorHor(0.0, 0.0)
    frameCnt:SetAnchorParamHor(sd, sd)
    frameCnt:SetAnchorVer(0.0, 0.0)
	frameCnt:SetAnchorParamVer(sd, sd)
    frameCnt:SetPivot(0.0, 0.0)

    local fcw = frameCnt:GetWidth()
    local fch = frameCnt:GetHeight()

    -- select
    local frameSelect = self:_CreateFrameBagItemCntsSelect()
    frame:AttachChild(frameSelect)
    frameSelect:LLY(-2.0)
    frameSelect:SetAnchorHor(0.0, 0.0)
    frameSelect:SetAnchorParamHor(0.0, 0.0)
    frameSelect:SetAnchorVer(0.0, 0.0)
    frameSelect:SetAnchorParamVer(fch + 32.0, fch + 32.0)
    frameSelect:SetPivot(0.0, 0.5)    
    
    -- me
    local frameMe = self:_CreateFrameMe(5, 6)
    self._frameMe = frameMe
    frame:AttachChild(frameMe)
    frameMe:LLY(-2.0)
    frameMe:SetAnchorHor(0.0, 0.0)
    frameMe:SetAnchorParamHor(sd + fcw + sd, sd + fcw + sd)
    frameMe:SetAnchorVer(0.0, 0.0)
	frameMe:SetAnchorParamVer(sd, sd)
    frameMe:SetPivot(0.0, 0.0)
    --frameMe:CreateAddBackgroundPicBox()

    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_ShowBag(show)
	print("p_mworld:_ShowBag")
	print_i_b(show)
	self._frameBag:Show(show)
end
-------------------------------------------------------------------------------
function p_mworld:_ShowCompass()
	print("p_mworld:_ShowCompass")

    if self._fPicCompass then
        local isshow = self._fPicCompass:IsShow()
        self._fPicCompass:Show(not isshow)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameBagItemCntsSelect()
    local frame = UIFrame:New()

    local sz = 40.0

    for i=0, 6, 1 do
        local btn = UIButton:New("BagIndex")
        manykit_uiProcessBtn(btn)
        frame:AttachChild(btn)
        btn:LLY(-2.0)
        btn:SetAnchorHor(0.0, 0.0)
        btn:SetAnchorVer(0.5, 0.5)
        local hor = sz * (i + 0.5)
        btn:SetAnchorParamHor(hor, hor)
        btn:SetSize(sz-5, sz-5)
        btn:CreateAddFText(""..(i+1))
        btn:SetUserDataInt("index", i)

        btn:SetScriptHandler("_UICallback", self._scriptControl)
    end

    local fw = sz * 7
    frame:SetSize(fw, sz)

    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameMe(numw, numh)
    local frameMeItems = UIFrame:New()

    local num = numw
    for i=0, num-1, 1 do
        local frame = self:_CreateBagGrid(false)
        frameMeItems:AttachChild(frame)
        frame:LLY(-5.0)
        frame:SetSize(self._bh-5, self._bh-5)
        frame:SetAnchorHor(0.0, 0.0)
        local phor = self._bh*0.5 + self._bh*i
        frame:SetAnchorParamHor(phor, phor)
        frame:SetAnchorParamVer(self._bh*0.5, self._bh*0.5)
        frame:SetAnchorVer(0.0, 0.0)
        frame:SetUserDataInt("index", i)
        frame:SetUserDataInt("isbar", 0)
        frame:SetUserDataInt("isbag", 0)
        frame:SetUserDataInt("isactorequip", 1)
    end

    frameMeItems:SetSize(self._bh * numw, self._bh * numh)
    self._frameMeEquipItems = frameMeItems

    return frameMeItems
end
-------------------------------------------------------------------------------
function p_mworld:_OnCallBagItemIndex(obj)
	print("p_mworld:_OnCallBagItemIndex")

    local idx = obj:GetUserDataInt("index")
    print("index:"..idx)

    self:_SetBagItems(idx * 60)
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameBagItemCnts()
    local frame = UIFrame:New()

    for i=0, 5, 1 do
        for j=0, 9, 1 do
            local grid = self:_CreateBagGrid(true)
            frame:AttachChild(grid)
            grid:LLY(-3.0)

            local h = self._bh * (j + 0.5)
            local v = self._bh * (i + 0.5) * -1.0

            grid:SetAnchorHor(0.0, 0.0)
            grid:SetAnchorVer(1.0, 1.0)
            grid:SetAnchorParamHor(h, h)
            grid:SetAnchorParamVer(v, v)
            grid:SetUserDataInt("isbag", 1)
        end
    end

    local w = self._bh * 10
    local h = self._bh * 6

    frame:SetSize(w, h)

    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateBagGrid(isbag)
    local frame = UIFrame:New()
    frame:LLY(-2.0)
    local back = frame:CreateAddBackgroundPicBox(false)
    back:UseAlphaBlend(true)
    back:SetTexture(self:_imgpthmworld("ui/roundsquare2.png"))
    frame:SetSize(self._bh-5, self._bh-5)
    back:SetPicBoxType(UIPicBox.PBT_NINE)
    back:SetTexCornerSize(16.0, 16.0, 16.0, 16.0)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.9)
    back:SetColor(Float3:MakeColor(41, 41, 54))
    frame:RegistToScriptSystem()

    local btn = UIButton:New("BtnItem")
    frame:AttachChild(btn)
    btn:LLY(-2.0)
    btn:SetAnchorHor(0.0, 1.0)
    btn:SetAnchorVer(0.0, 1.0)
    btn:SetSelfCtrled(true)
    manykit_uiProcessBtn(btn)
    btn:SetID(101)
    btn:SetScriptHandler("_UICallback", self._scriptControl)
    btn:SetAlpha(0.1)

    -- pic txt
    local f = UIFrame:New()
    f:SetAnchorHor(0.0, 1.0)
    f:SetAnchorVer(0.0, 1.0)
    f:SetID(10)
    f:RegistToScriptSystem()
    f:Show(false)

    local fPicBox = UIFPicBox:New()
    f:AttachChild(fPicBox)
    fPicBox:SetID(102)
    fPicBox:LLY(-2.0)
    fPicBox:SetAnchorHor(0.0, 1.0)
    fPicBox:SetAnchorVer(0.0, 1.0)
    fPicBox:SetAnchorParamHor(5, -5)
    fPicBox:SetAnchorParamVer(5, -5)
    fPicBox:RegistToScriptSystem()

    local fText = UIFText:New("Name")
    f:AttachChild(fText)
    fText:SetID(103)
    fText:LLY(-3.0)
    fText:SetAnchorHor(0.0, 1.0)
    fText:SetAnchorParamHor(0.0, -5.0)
    fText:SetAnchorVer(0.0, 0.0)
    fText:SetPivot(0.5, 0.0)
    fText:SetHeight(24.0)
    fText:GetText():SetFontColor(Float3.WHITE)
    fText:GetText():SetFontSize(24)
    fText:GetText():SetFontScale(0.7)
    fText:GetText():SetDrawStyle(FD_BORDER)
    fText:GetText():SetBorderShadowColor(Float3(0, 0, 0))
    fText:GetText():SetBorderShadowAlpha(0.4)
    fText:GetText():SetAligns(TEXTALIGN_RIGHT + TEXTALIGN_VCENTER)
    fText:GetText():SetText("0")

    local btnO = UIButton:New("BtnOperator")
    f:AttachChild(btnO)
    btnO:LLY(-4.0)
    btnO:SetAnchorHor(0.0, 1.0)
    btnO:SetAnchorVer(1.0, 1.0)
    btnO:SetAnchorParamHor(5.0, -5.0)
    btnO:SetAnchorParamVer(-20.0, -20.0)
    btnO:SetSize(40.0, 20.0)
    local fTextOperator = btnO:CreateAddFText("8")
    btnO:Show(false)
    btnO:SetScriptHandler("_UICallback", self._scriptControl)
    if fTextOperator then
        fTextOperator:GetText():SetFontScale(0.6)
    end

    frame:AttachChild(f)
    f:LLY(-5.0)
    f:SetAnchorHor(0.0, 1.0)
    f:SetAnchorVer(0.0, 1.0)

    if isbag then
        btn:SetScriptHandlerWidgetPicked("_BagItemTouch", self._scriptControl)
    end
   
    return frame
end
-------------------------------------------------------------------------------
function p_mworld:_AddBagItem(skillItem)
    local id = skillItem:GetID()    
    local frame = self:_GetAEmptyBagGrid()
    if frame then
        local id = skillItem:GetID()
        local typeID = skillItem:GetTypeID()

        self:_RefreshItem(frame, skillItem, false)
    end   
end
-------------------------------------------------------------------------------
function p_mworld:_GetAEmptyBagGrid()    
    local numItems = self._frameBagItemsCnt:GetNumChildren()
    for i=0, numItems-1, 1 do
        local c = self._frameBagItemsCnt:GetChild(i)
        local sz = Cast:ToSizeNode(c)
        if sz then
            local id = sz:GetUserDataInt("id")
            if 0==id then
                return sz
            end
        end
    end

    return nil
end
-------------------------------------------------------------------------------
function p_mworld:_GetBagGridByItemID(itemid)  
    local numItems = self._frameBagItemsCnt:GetNumChildren()
    for i=0, numItems-1, 1 do
        local c = self._frameBagItemsCnt:GetChild(i)
        local sz = Cast:ToSizeNode(c)
        if sz then
            local id = sz:GetUserDataInt("id")
            if itemid==id then
                return sz
            end
        end
    end

    return nil
end
-------------------------------------------------------------------------------
function p_mworld:_SetBagItems(from)
    self:_ClearBagGrid()

    local scene = PX2_PROJ:GetScene()
    if scene then
        local meActor = scene:GetMainActor()
        if meActor then
            local skillChara = meActor:GetSkillChara()
            if skillChara then
                local numItems = skillChara:GetNumItems()
                for i=from, numItems-1, 1 do
                    local item = skillChara:GetItem(i)
                    local isFixed = item:IsFixed()
                    local isAllEquipped = item:IsAllEquipped()
                    if not isFixed and not isAllEquipped then
                        self:_AddBagItem(item)
                    end
                end
            end
        end        
    end
end
-------------------------------------------------------------------------------
function p_mworld:_RefreshItem(uiItem, skillItem, isdosend)
    local frame = uiItem:GetObjectByID(10)
    local isbar = uiItem:GetUserDataInt("isbar")==1
    local isbag = uiItem:GetUserDataInt("isbag")==1
    local isactorequip = uiItem:GetUserDataInt("isactorequip")==1
    local index = uiItem:GetUserDataInt("index")

    local btnOperator = frame:GetObjectByName("BtnOperator")

    -- print("isbar:")
    -- print_i_b(isbar)

    -- print("isbag:")
    -- print_i_b(isbag)

    if skillItem then
        local def = skillItem:GetDefItem()
        local id = skillItem:GetID()
        local isfixed = skillItem:IsFixed()
        local num = skillItem:GetNum()
        local numMax = skillItem:GetNumMax()
        local name = "NoName"
        if def then
            name = def.Name
        end

        uiItem:SetUserDataInt("id", id)    

        frame:Show(true)
        
        local fPicBox = frame:GetChild(0)
    
        local nametext = name.."x"..num.."/"..numMax
        if isfixed then
            nametext = nametext.."_f"
        end
        local fText = frame:GetChild(1)
        if fText then
            fText:GetText():SetText(nametext)
            fText:GetText():SetFontScale(0.5)
        end

        if def then
            local pth = self:_GetItemIconPath(def)
            fPicBox:GetUIPicBox():SetTexture(pth)
        else
            fPicBox:GetUIPicBox():SetTexture("engine/defalut.png")
        end

        if btnOperator then
            btnOperator:SetUserDataInt("id", id)

            btnOperator:Show(skillItem:GetNumSubObjectTypes()>0)

            local textOption = btnOperator:GetText()
            local tid = skillItem:GetCurrentUseSubObjectTypeID()
            if tid>0 then
                local numMax = skillItem:GetSubObjectNumMax(tid)
                local numSub = skillItem:GetSubObjectNum(tid)

                textOption:SetText(""..tid..":"..numSub.."/"..numMax)
            else
                textOption:SetText("nosub")
            end
        end
    else
        if isactorequip then
            local itemid = uiItem:GetUserDataInt("id")
            if 0~=itemid then
                local scene = PX2_PROJ:GetScene()
                local mainActor = scene:GetMainActor()
                local skillChara = mainActor:GetSkillChara()
                local skillItem = skillChara:GetItemByID(itemid)
                if skillItem then
                    local beforeIndex = skillItem:GetEquipIndex()

                    skillChara:UnEquipItem("def", skillItem)          
                    if mainActor then
                        local ctrl ,scCtrl = g_manykit_GetControllerDriverFrom(mainActor, "p_chara")
                        if scCtrl then
                            scCtrl:_CheckViewMode()
                        end
                    end
                    skillItem:SetEquipIndex(-1)

                    p_net._g_net:_SendItemEquipOrUnEquip(skillChara, "def", beforeIndex, skillItem, false)

                    local charaid = skillChara:GetID()
                    PX2_GH:SendGeneralEvent("SkillCharaEquipItems", ""..charaid)
                end
            end
        end

        uiItem:SetUserDataInt("id", 0)    
        frame:Show(false)
    end

    if isactorequip then
        if isdosend then
            local scene = PX2_PROJ:GetScene()
            local meActor = scene:GetMainActor()
            if meActor then
                local skillChara = meActor:GetSkillChara()
                if skillChara then
                    if skillItem then
                        skillChara:EquipItem("def", skillItem)
                        skillItem:SetEquipIndex(index)

                        p_net._g_net:_SendItemEquipOrUnEquip(skillChara, "def", index, skillItem, true)

                        local charaid = skillChara:GetID()
                        PX2_GH:SendGeneralEvent("SkillCharaEquipItems", ""..charaid)
                    end
                end
            end
        end
    else       
        if isbar and isbag then
            local uiItemBar = self._frameBar:GetChild(index)
            self:_RefreshItem(uiItemBar, skillItem, false)

            if isdosend then
                local scene = PX2_PROJ:GetScene()
                local mainActor = scene:GetMainActor()
                if mainActor then
                    local skillChara = mainActor:GetSkillChara()
                    if skillChara then
                        skillChara:SetQuickBarItem(index, skillItem)

                        p_net._g_net:_SendQuickBarItem(skillChara, "bar", index, skillItem)
                    end
                end
            end
        end 
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ClearFrameBar()
    print(self._name.." p_mworld:_ClearQuickBarItems")

    if self._frameBar then
        local numItems = self._frameBar:GetNumChildren()
        for i=0, numItems-1, 1 do
            local objCnt = self._frameBar:GetChild(i)
            local frameCnt = Cast:ToSizeNode(objCnt)
            if frameCnt then
                frameCnt:SetUserDataInt("id", 0)
                local f = frameCnt:GetObjectByID(10)
                if f then
                    f:Show(false)
                end 
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ClearBagGrid()
    local numItems = self._frameBagItemsCnt:GetNumChildren()
    for i=0, numItems-1, 1 do
        local c = self._frameBagItemsCnt:GetChild(i)
        local sz = Cast:ToSizeNode(c)
        if sz then
            self:_RefreshItem(sz, nil, false)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_NodePicked(ptr)
    if self._itemSelectIDBagOrEquip > 0 then
        local obj = Cast:ToO(ptr)
        if obj then
            local lastPickData = obj:GetLastPickData()
            local moveDetail = lastPickData.MoveDelta
            local moveDetailLength = moveDetail:Length()
            local lp = lastPickData.LogicPos
            
            if UIPT_PRESSED == lastPickData.PickType then

            elseif UIPT_RELEASED == lastPickData.PickType then

            elseif UIPT_MOVED == lastPickData.PickType then
                self._uifPicBoxSelectItem:SetAnchorParamHor(lp:X(), lp:X())
                self._uifPicBoxSelectItem:SetAnchorParamVer(lp:Z(), lp:Z())
            elseif UIPT_WHELLED == lastPickData.PickType then

            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_BagItemTouch(ptr)
    local obj = Cast:ToO(ptr)
    if obj then
        local lastPickData = obj:GetLastPickData()
        local moveDetail = lastPickData.MoveDelta
        local moveDetailLength = moveDetail:Length()
        local logicPos = lastPickData.LogicPos
        
        if UIPT_PRESSED == lastPickData.PickType then
        elseif UIPT_RELEASED == lastPickData.PickType then
        elseif UIPT_MOVED == lastPickData.PickType then
            local par = obj:GetParent()
            if par then
                local id = par:GetUserDataInt("id")
                self:_ShowBagItemTouch(id, obj)
            end
        elseif UIPT_WHELLED == lastPickData.PickType then
        end

        if self._itemSelectIDBagOrEquip==0 then
            self:_ShowGridSelectIcon(obj)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ShowBagItemTouch(id, btnObj)
    self._bagItemTouchID = id

    if id>0 then
        if self._frameSelectInfo then
            self._frameSelectInfo:DetachFromParent()
        end

        local par = btnObj:GetParent()
        local parNode = Cast:ToSizeNode(par)
        parNode:AttachChild(self._frameSelectInfo)

        coroutine.wrap(function()
            self._frameSelectInfo:Show(true)
            sleep(3.0)
            self._frameSelectInfo:Show(false)
        end)()

        local scene = PX2_PROJ:GetScene()
        local mainActor = scene:GetMainActor()
        if mainActor then
            local skillChara = mainActor:GetSkillChara()
            if skillChara then
                local item = skillChara:GetItemByID(id)
                if item then
                    local itemDef = item:GetDefItem()
                    if itemDef then
                        local id = itemDef.ID
                        local des = itemDef.Desc
                        local userData = itemDef.UserData
                        local name = itemDef.Name
                        local itemInfoText = "物品ID:"..id.."\n描述:"..des.."\n协议ID:"..userData.."\n姓名:"..name

                        local fText = self._frameSelectInfo:GetChildByName("ItemInfo")
                        fText:GetText():SetText(itemInfoText)
                    end
                end
            end
        end
    else
        self._frameSelectInfo:Show(false)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_ShowGridSelectIcon(btnObj)
    local par = btnObj:GetParent()
    if par then
        local id = par:GetUserDataInt("id")
        local parNode = Cast:ToSizeNode(par)
        if parNode then
            self._frameSelectBox:DetachFromParent()
            parNode:AttachChild(self._frameSelectBox)
            self._frameSelectBox:Show(true)
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_BagItemSelect(obj)
    print(self._name.." p_mworld:_BagItemSelect")

    local scene = PX2_PROJ:GetScene()
    local actorMain = scene:GetMainActor()

    if actorMain then
        local skillChara = actorMain:GetSkillChara()

        local par = obj:GetParent()
        if par then
            local id = par:GetUserDataInt("id")
            local isbag = par:GetUserDataInt("isbag")==1
            local isbar = par:GetUserDataInt("isbar")==1
            local isactorequip = par:GetUserDataInt("isactorequip")==1

            print("isbag:")
            print_i_b(isbag)

            print("isbar:")
            print_i_b(isbar)

            print("isactorequip:")
            print_i_b(isactorequip)

            if isbag or isactorequip then
                if self._itemSelectIDBagOrEquip==0 then
                    self._itemSelectIDBagOrEquip = id
                    self._uiitemSelectBagOrEquip = par

                    print("self._itemSelectIDBagOrEquip:")
                    print(self._itemSelectIDBagOrEquip)

                    -- set select item icon
                    if self._itemSelectIDBagOrEquip > 0 then
                        self._uifPicBoxSelectItem:Show(true)
                        local fPicBox = self._uifPicBoxSelectItem
                        if skillChara then
                            local item = skillChara:GetItemByID(id)
                            if item then
                                local def = item:GetDefItem()
                                if def then
                                    local pth = self:_GetItemIconPath(def)
                                    fPicBox:GetUIPicBox():SetTexture(pth)
                                end
                            end
                        end
                    end

                else
                    if par ~= self._uiitemSelectBagOrEquip then
                        self:_ExchangeItem(self._uiitemSelectBagOrEquip, par)
                    end

                    self._itemSelectIDBagOrEquip = 0    
                    self._uifPicBoxSelectItem:Show(false)
                end
            else
                self._itemSelectBar = par
                self._itemSelectIDBar = id

                self._curSelectBarItemIDForPutting = id
                print("_curSelectBarItemIDForPutting:"..self._curSelectBarItemIDForPutting)

                self:_ShowGridSelectIcon(obj)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_mworld:_GetItemIconPath(def)
    local pth = "engine/default.png"

    if def.Icon~="" and string.len(def.Icon) > 16 then
        pth = def.icon
    else
        if DefItem.T_BLOCK==def.TheType then
            pth = self:_imgpthmworld("blocks/"..def.Icon..".png")
        elseif DefItem.T_NORMAL==def.TheType then
            if def.CharaID and def.CharaID>0 then
                local defChara = PX2_SDM:GetDefChara(def.CharaID)
                if defChara then
                    if defChara.ModelID>0 then
                        local defModel = PX2_SDM:GetDefModel(defChara.ModelID)
                        if defModel then
                            if ""~=defModel.Icon then
                                pth = defModel.Icon
                            else
                                if ""~=def.Icon then
                                    pth = self:_imgpthmworld("items/"..def.Icon..".png")
                                else
                                    pth = "engine/default.png"
                                end
                            end
                        else
                            pth = "engine/default.png"
                        end
                    else
                        if ""~=def.Icon then
                            pth = self:_imgpthmworld("items/"..def.Icon..".png")
                        else
                            pth = "engine/default.png"
                        end
                    end
                else
                    pth = "engine/default.png"
                end
            else
                pth = "engine/default.png"
            end
        end
    end

    return pth
end
-------------------------------------------------------------------------------
function p_mworld:_ExchangeItem(uiItemFrom, uiItemTo)
    local scene = PX2_PROJ:GetScene()
    local actorMain = scene:GetMainActor()
    local skillChara = actorMain:GetSkillChara()

    local idFrom = uiItemFrom:GetUserDataInt("id")
    local idTo = uiItemTo:GetUserDataInt("id")

    local skillItemFrom = skillChara:GetItemByID(idFrom)
    local skillItemTo = skillChara:GetItemByID(idTo)

    self:_RefreshItem(uiItemFrom, skillItemTo, true)

    self:_RefreshItem(uiItemTo, skillItemFrom, true)
end
-------------------------------------------------------------------------------