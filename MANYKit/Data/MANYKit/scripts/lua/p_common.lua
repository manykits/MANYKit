-- p_common.lua

function manykit_createCommonDlg(frameWidth, frameHeight, titleText)
	local uiFrameBack = UIFrame:New()
	local backPic = uiFrameBack:CreateAddBackgroundPicBox(true, Float3:MakeColor(0, 0, 0))
	backPic:SetAlpha(0.7)
	backPic:UseAlphaBlend(true)
	uiFrameBack:SetWidget(true)
	uiFrameBack:SetAnchorHor(0.0, 1.0)
    uiFrameBack:SetAnchorVer(0.0, 1.0)
	uiFrameBack:SetAnchorParamHor(0.0, 0.0)
	uiFrameBack:SetAnchorParamVer(0.0, 0.0)

	local uiFrame = UIFrame:New()
	uiFrameBack:AttachChild(uiFrame)
	uiFrame:LLY(-2.0)
	local picBox = uiFrame:CreateAddBackgroundPicBox(true, Float3:MakeColor(255, 255, 255))
	picBox:SetPicBoxType(UIPicBox.PBT_NINE)
	picBox:SetTexCornerSize(4.0, 4.0, 4.0, 4.0)
	picBox:UseAlphaBlend(true)
	picBox:SetAlpha(0.3)

	if frameWidth>0 and frameHeight>0 then
		uiFrame:SetAnchorHor(0.5, 0.5)
		uiFrame:SetAnchorVer(0.5, 0.5)
		uiFrame:SetSize(frameWidth, frameHeight)
	else
		uiFrame:SetAnchorHor(0.0, 1.0)
		uiFrame:SetAnchorVer(0.0, 1.0)
		uiFrame:SetAnchorParamHor(-frameWidth, frameWidth)
		uiFrame:SetAnchorParamVer(-frameHeight, frameHeight)
	end
    
    local textTitle = UIFText:New("TextTitle")
	uiFrame:AttachChild(textTitle)
	textTitle:LLY(-6.0)
	textTitle:SetAnchorHor(0.0, 1.0)
    textTitle:SetAnchorParamHor(5.0, 0.0)
	textTitle:SetAnchorVer(1.0, 1.0)
	textTitle:SetAnchorParamVer(-8.0, -8.0)
	textTitle:SetPivot(0.5, 1.0)
	textTitle:SetHeight(20.0)
	textTitle:GetText():SetFontColor(Float3.WHITE)
	textTitle:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
	textTitle:GetText():SetText(titleText)
	textTitle:GetText():SetFontScale(0.8)

	local btnClose = UIButton:New("BtnDlgClose")
	uiFrame:AttachChild(btnClose)
	btnClose:LLY(-5.0)
	btnClose:SetStateColorDefaultWhite()
	btnClose:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/close1.png")
	btnClose:AutoMakeSizeFixable()
	btnClose:SetSize(g_manykit._hBtn, g_manykit._hBtn)
	btnClose:SetAnchorHor(1.0, 1.0)
	btnClose:SetAnchorVer(1.0, 1.0)
	btnClose:SetPivot(1.0, 1.0)

	return uiFrameBack, uiFrame, btnClose, textTitle, backPic
end

function manykit_uiProcessTextFont(text, fontSize)
	text:SetFont("engine/font.ttf", fontSize, fontSize)
end

function manykit_uiProcessFText(fText)
	if fText then
		fText:GetText():SetFontColor(Float3.WHITE)
		fText:GetText():SetDrawStyle(FD_SHADOW)
		fText:GetText():SetShadowBorderSize(1)
		fText:GetText():SetBorderShadowAlpha(0.7)
		fText:GetText():SetBorderShadowColor(Float3.BLACK)
	end
end

function manykit_uiProcessList(list, dark)
	if dark then
		list:SetItemBackColor(Float3.BLACK)
	else
    	list:SetItemBackColor(Float3.WHITE)
	end
    list:SetItemBackAlpha(0.2)
    list:SetFontSize(16)
    list:SetSliderSize(40.0)
    list:SetItemHeight(50.0)

    local slider = list:GetSlider()
    slider:GetFPicBoxBack():GetUIPicBox():SetPicBoxType(UIPicBox.PBT_NINE)
	slider:GetFPicBoxBack():GetUIPicBox():SetTexture("engine/white.png")
	slider:GetFPicBoxBack():GetUIPicBox():SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetFPicBoxBack():GetUIPicBox():SetAlpha(0.5)
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/white.png")
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetButSlider():SetStateColor(UIButtonBase.BS_HOVERED, Float3.WHITE)
	slider:GetButSlider():SetStateColor(UIButtonBase.BS_NORMAL, Float3.WHITE)
	slider:GetButSlider():SetStateColor(UIButtonBase.BS_PRESSED, Float3.WHITE)
    slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_HOVERED, 0.6)
	slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_NORMAL, 0.6)
	slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_PRESSED, 0.6)

	return slider
end

function manykit_uiProcessTree(tree, dark)
	tree:SetItemBackColor(Float3.WHITE)
	tree:SetItemBackAlpha(0.1)
    tree:SetSliderSize(40.0)
    tree:SetItemHeight(g_manykit._hBtn)
	tree:SetTextColor(Float3.WHITE)
	tree:SetIconArrowSpace(24.0)
    tree:SetLevelSpace(20.0)

    local slider = tree:GetSlider()
    slider:GetFPicBoxBack():GetUIPicBox():SetPicBoxType(UIPicBox.PBT_NINE)
	slider:GetFPicBoxBack():GetUIPicBox():SetTexture("engine/white.png")
	slider:GetFPicBoxBack():GetUIPicBox():SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetFPicBoxBack():GetUIPicBox():SetAlpha(0.5)
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/white.png")
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetButSlider():SetStateColor(UIButtonBase.BS_HOVERED, Float3.WHITE)
	slider:GetButSlider():SetStateColor(UIButtonBase.BS_NORMAL, Float3.WHITE)
	slider:GetButSlider():SetStateColor(UIButtonBase.BS_PRESSED, Float3.WHITE)
    slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_HOVERED, 0.6)
	slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_NORMAL, 0.6)
	slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_PRESSED, 0.6)
end

function manykit_uiProcessBtn(btn)
	if btn then
		btn:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
		btn:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/white.png")
		btn:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)

		btn:SetStateColor(UIButtonBase.BS_NORMAL, Float3.WHITE)
		btn:SetStateColor(UIButtonBase.BS_PRESSED, Float3.WHITE)
		btn:SetStateColor(UIButtonBase.BS_HOVERED, Float3.WHITE)

		btn:SetStateAlpha(UIButtonBase.BS_NORMAL, 0.5)
		btn:SetStateAlpha(UIButtonBase.BS_PRESSED, 0.5)
		btn:SetStateAlpha(UIButtonBase.BS_HOVERED, 0.5)

		local fText = btn:GetFText()
		if fText then
			fText:GetText():SetFontColor(Float3.WHITE)
			fText:GetText():SetDrawStyle(FD_SHADOW)
			fText:GetText():SetShadowBorderSize(1)
			fText:GetText():SetBorderShadowAlpha(0.7)
			fText:GetText():SetBorderShadowColor(Float3.BLACK)
		end
	end
end

function manykit_uiProcessCheck(check)
	if check then
		check:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/square.png")
		check:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetTexture("common/images/ui/check.png")
		check:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetAlpha(0.5)
		check:GetPicBoxAtState(UIButtonBase.BS_PRESSED):SetAlpha(0.5)

		local fText = check:GetFText()
		if fText then
			fText:GetText():SetFontScale(0.6)
			fText:GetText():SetFontColor(Float3.WHITE)
			fText:GetText():SetDrawStyle(FD_SHADOW)
			fText:GetText():SetShadowBorderSize(1)
			fText:GetText():SetBorderShadowAlpha(0.7)
			fText:GetText():SetBorderShadowColor(Float3.BLACK)
		end
	end
end

function manykit_uiProcessTable(tab)
	tab:SetTabLayoutType(UITabFrame.TLT_FIX)
	tab:SetTabWidth(80.0)
    tab:SetTabBarHeight(g_manykit._hBtn)
    tab:SetTabHeight(g_manykit._hBtn)    
    tab:SetFontColor(Float3.WHITE)
    tab:GetTitleBarFrame():GetBackgroundPicBox():SetColor(Float3.WHITE)
    tab:GetTitleBarFrame():GetBackgroundPicBox():SetAlpha(0.5)
    tab:GetTitleBarFrame():GetBackgroundPicBox():UseAlphaBlend(true)

	for i=0, tab:GetNumTabs()-1, 1 do
		local btnTab = tab:GetTabButton(i)
		manykit_uiProcessBtn(btnTab)
	end
end

function manykit_uiProcessSlider(slider, dark)
	slider:GetFPicBoxBack():GetUIPicBox():SetPicBoxType(UIPicBox.PBT_NINE)
	slider:GetFPicBoxBack():GetUIPicBox():SetTexture("engine/white.png")
	slider:GetFPicBoxBack():GetUIPicBox():SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetFPicBoxBack():GetUIPicBox():SetAlpha(0.5)
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/white.png")
	slider:GetButSlider():GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    slider:GetButSlider():SetStateColor(UIButtonBase.BS_HOVERED, Float3.WHITE)
	slider:GetButSlider():SetStateColor(UIButtonBase.BS_NORMAL, Float3.WHITE)
	slider:GetButSlider():SetStateColor(UIButtonBase.BS_PRESSED, Float3.WHITE)
    slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_HOVERED, 0.6)
	slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_NORMAL, 0.6)
	slider:GetButSlider():SetStateAlpha(UIButtonBase.BS_PRESSED, 0.6)

	if dark then
		local fText = slider:GetButSlider():GetFText()
		fText:GetText():SetFontColor(Float3.BLACK)
	end
end

function manykit_CreateFramePopUpInfo()
    local frameBack = UIFrame:New()
    frameBack:SetAnchorHor(0.0, 1.0)
    frameBack:SetAnchorVer(0.0, 1.0)
    frameBack:SetWidget(true)

    local frameBackBack = frameBack:CreateAddBackgroundPicBox()
    frameBackBack:SetColor(Float3.BLACK)    
    frameBackBack:UseAlphaBlend(true)
    frameBackBack:SetAlpha(0.7)

    local frame = UIFrame:New()    
    frameBack:AttachChild(frame)
    frame:LLY(-1.0)
    local back = frame:CreateAddBackgroundPicBox()
    back:SetColor(Float3.BLACK)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.4)

    frame:SetAnchorHor(0.5, 0.5)
	frame:SetAnchorParamHor(0.0, 0.0)
    frame:SetAnchorVer(0.5, 0.5)
	frame:SetAnchorParamVer(0.0, 0.0)
    frame:SetPivot(0.5, 0.5)
    frame:SetSize(400.0, 300)
    frame:SetWidget(true)

    -- title bar
    local frameTitle = UIFrame:New("FrameTitle")
    frame:AttachChild(frameTitle)
    frameTitle:RegistToScriptSystem()
    frameTitle:LLY(-5.0)
    frameTitle:SetAnchorHor(0.0, 1.0)
    frameTitle:SetAnchorVer(1.0, 1.0)
    frameTitle:SetPivot(0.5, 1.0)
    frameTitle:SetHeight(40.0)
    local back = frameTitle:CreateAddBackgroundPicBox()
    back:SetColor(Float3.WHITE)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.6)

    local txt = UIFText:New("Msg")
    frame:AttachChild(txt)
    txt:LLY(-5.0)
    txt:SetAnchorParamVer(10.0, 10.0)
    txt:SetSize(300.0, 50.0)
    txt:GetText():SetFontColor(Float3.RED)
    txt:GetText():SetFontSize(24)
	txt:GetText():SetFontScale(0.9)
    txt:GetText():SetText("确定这样做么？")

	local frameList = UIList:New("ListMsg")
	frame:AttachChild(frameList)
	frameList:LLY(-10.0)
	frameList:SetAnchorHor(0.0, 1.0)
	frameList:SetAnchorParamHor(10.0, -10.0)
	frameList:SetAnchorVer(0.0, 1.0)
	frameList:SetAnchorParamVer(80.0, -50.0)
	frameList:SetItemHeight(40.0)
	frameList:CreateAddBackgroundPicBox(true, Float3.BLACK)
	frameList:SetSliderSize(40.0)
	frameList:Show(false)

    local btnOK = UIButton:New("BtnOKCheck")
    frame:AttachChild(btnOK)
    btnOK:LLY(-5.0)
    btnOK:SetAnchorHor(0.5, 0.5)
    btnOK:SetAnchorParamHor(-75.0, -75.0)
    btnOK:SetAnchorVer(0.12, 0.12)
    btnOK:SetSize(120.0, 35.0)
    btnOK:CreateAddFText("确定")
    btnOK:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
	btnOK:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    btnOK:SetScriptHandler("")
    manykit_uiProcessBtn(btnOK)

    local btnCancel = UIButton:New("BtnCancelCheck")
    frame:AttachChild(btnCancel)
    btnCancel:LLY(-5.0)
    btnCancel:SetAnchorHor(0.5, 0.5)
    btnCancel:SetAnchorParamHor(75.0, 75.0)
    btnCancel:SetAnchorVer(0.12, 0.12)
    btnCancel:SetSize(120.0, 35.0)
    btnCancel:CreateAddFText("取消")
    btnCancel:SetScriptHandler("")
    manykit_uiProcessBtn(btnCancel)

    return frameBack
end

function manykit_ShowInfoPopUp(showtype, showmsg, okscript, cancelscript)

    local fTextMsg = g_manykit._frameInfoPopUp:GetObjectByName("Msg")
    fTextMsg:GetText():SetText(showmsg)

    local btnOK = g_manykit._frameInfoPopUp:GetObjectByName("BtnOKCheck")
    local btnCancel = g_manykit._frameInfoPopUp:GetObjectByName("BtnCancelCheck")
	btnOK:SetScriptHandler("manykit_UICallback")
	btnCancel:SetScriptHandler("manykit_UICallback")

    if "check" ==showtype then
        btnOK:Show(true)
        btnOK:SetAnchorParamHor(-75.0, -75.0)
        btnCancel:Show(true)
        btnCancel:SetAnchorParamHor(75.0, 75.0)

		if PX2_SS then
        	PX2_SS:PlayASound("media/system/warning.mp3", g_manykit._soundVolume, 2.0)
		end
    elseif "info"==showtype then
        btnOK:Show(false)
        btnCancel:Show(true)
        btnCancel:SetAnchorParamHor(0.0, 0.0)
    end

    g_manykit._frameInfoPopUp:Show(true)
    g_manykit._frameInfoPopUp:SetUserDataString("okscripthandler", okscript) 
	if cancelscript then
		g_manykit._frameInfoPopUp:SetUserDataString("cancelscripthandler", cancelscript)
	end
end

function manykit_HideInfoPopUp()
    g_manykit._frameInfoPopUp:Show(false)

	local listMsg = g_manykit._frameInfoPopUp:GetObjectByName("ListMsg")
	if listMsg then
		listMsg:Show(false)
	end
end

function manykit_GetNextSaveFileIndex()
	local nextfileindex = 0
	local nfistr = PX2_PROJ:GetConfig("pnight_NextSaveFileIndex")
	if ""==nfistr then 
		nextfileindex = 0
	else 
		nextfileindex = StringHelp:StringToInt(nfistr) 
	end	
	local nextfileindexp1 = nextfileindex + 1
	PX2_PROJ:SetConfig("pnight_NextSaveFileIndex", nextfileindexp1)

	return nextfileindex
end

function manykit_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

    if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

        if "BtnCancelCheck"==name then
            g_manykit._frameInfoPopUp:Show(false)
			local cancelscript = g_manykit._frameInfoPopUp:GetUserDataString("cancelscripthandler")
            if ""~=cancelscript then
                PX2_SC_LUA:CallString(cancelscript)
            end
        elseif "BtnOKCheck"==name then
            g_manykit._frameInfoPopUp:Show(false)
            local okscript = g_manykit._frameInfoPopUp:GetUserDataString("okscripthandler")
            if ""~=okscript then
                PX2_SC_LUA:CallString(okscript)
            end
        end
    end
end

function manykit_IsInArray(value, tbl)
	for k,v in pairs(tbl) do
	  if value == v then
	  	return true
	  end
	end

	return false
end

function manykit_IsInMap(value, tbl)
	for k,v in pairs(tbl) do
	  if value == k then
	  	return true
	  end
	end

	return false
end

function manykit_Soundbtnclick()
    local path = "media/audio/click3.mp3"
    if nil~=PX2_SS then
        PX2_SS:SetMaxNumPlaySameTime(path, 10)
        PX2_SS:SetPlaySameTimeRange(path, 0.0)
        PX2_SS:PlayASound(path, g_manykit._soundVolume, 3.0)
    end
end

function manykit_PickScenePos(origin, diff, movIngore)
	local isDoPick = true
	if movIngore then
		isDoPick = movIngore:IsDoPick()
		movIngore:SetDoPick(false)
	end

	local scene = PX2_PROJ:GetScene()

	local nodeSky = scene:GetObjectByID(p_holospace._g_IDNodeSky)
	if nodeSky then
		nodeSky:SetDoPick(false)
	end

	p_holospace._g_curSceneNodeCtrl:GetCtrlsGroup():SetDoPick(false)

	local direction = AVector(0.0, 0.0, -1.0)
	local worldPos = APoint(origin:X(), origin:Y(), origin:Z())
	local worldNormal = AVector(0.0, 0.0, 1.0)
	worldNormal:Normalize()
	local pickPos = APoint(origin:X(), origin:Y(), origin:Z() + diff)


	local picker = Picker()
	picker:Execute(scene, pickPos, direction, 0.0, Mathf.MAX_REAL)
	local picRec = picker:GetClosestNonnegative()
	if picRec.Intersected then
		worldPos = picRec.WorldPos
		worldNormal = picRec.WorldNormal
	end

	if movIngore then
		movIngore:SetDoPick(isDoPick)
	end

	local nodeSky = scene:GetObjectByID(p_holospace._g_IDNodeSky)
	if nodeSky then
		nodeSky:SetDoPick(true)
	end

	p_holospace._g_curSceneNodeCtrl:GetCtrlsGroup():SetDoPick(true)

	return worldPos, worldNormal
end
-------------------------------------------------------------------------------
function g_manykit_GetControllerDriverFrom(act, name)
	--print("g_manykit_GetControllerDriverFrom:"..name)
	if act then
		local numCtrls = act:GetNumControllers()
		--print("numCtrls:"..numCtrls)
		for i=0, numCtrls-1, 1 do
			local ctrl = act:GetController(i)
			local scCtrl = Cast:ToOSC(ctrl)
			if scCtrl then
				local scCtrlsc = gScriptTable[scCtrl:SelfP()]
				if scCtrlsc and scCtrlsc._name then
					--print("scCtrlsc.name:"..scCtrlsc._name)

					if scCtrlsc._name and scCtrlsc._name == name then
						return scCtrl, scCtrlsc
					end

					local cls = scCtrlsc.base
					while cls and cls._name do
						-- if cls._name then
						-- 	--print("cls.name:"..cls._name)
						-- else
						-- 	--print("aaaaaaaaa")
						-- end

						if cls._name and cls._name == name then 
							--print("cls.name:"..cls._name)
							return scCtrl, scCtrlsc
						end
						cls = cls.base
					end
				end
			end
		end
	end

	return nil, nil
end
-------------------------------------------------------------------------------