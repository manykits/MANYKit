-- p_robotface.lua

-------------------------------------------------------------------------------
p_robotface = class(p_ctrl,
{
    _requires = {"p_robot",},

	_name = "p_robotface",

    _actorname = "米娜minna",

    _eyesize = 180.0,
    _eyedist = 200.0,
    _eyeh = 80.0,
    _mouseh = -180.0,
    _szmouse = Sizef(140.0, 60.0),

    _frameFace = nil,
    _eyeleft = nil,
    _eyeleftctrl = nil,
    _eyectrlmove_left = nil,
    _eyeright = nil,
    _eyerightctrl = nil,
    _eyectrlmove_right = nil,
    _ctrlMouth = nil,

    _isuselive2d = false,
    _isplayingface_normal = false,

    _btnHome = nil,
    _btnVoice = nil,
	_fPicBoxFace = nil,
	_fPicBoxFace1 = nil,

    _frameVoice = nil,
    _fTextVoice = nil,

    _voiceSavePath = "",

    _frameSay = nil,
    _fTextSay = nil,
    
    _frameBackLive2D = nil,
    _CanvasLive2D = nil,

    _btnSetting = nil,
    _frameMgr = nil,
    _propertyGridEdit = nil,
    _sceneIndex = 0,
    _animGroupIndex = 0,
    _animGroupSubIndex = 0,

    _btnBattery = nil,
    _BatteryRequestTimeing = 0.0,
})
-------------------------------------------------------------------------------
function p_robotface:OnAttached()
	PX2_LM_APP:AddItem(self._name, "ROBOTFace", "表情")

	p_ctrl.OnAttached(self)
	print(self._name.." p_robotface:OnAttached")

    local pathParent = ResourceManager:GetWriteablePath().."Write_MANYKit/"
    local pathVoice = pathParent.."voice/"
    if not PX2_RM:IsFileFloderExist(pathVoice) then
        PX2_RM:CreateFloder(pathParent, "voice/")
    end
    self._voiceSavePath = pathVoice

    self:_CreateContentFrame()

    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
		if "awake"==str then
			print("----------------------------------------------------------")
            if PX2_SS then
                PX2_SS:PlayASound("engine/ding.mp3", 1.0, 2.0)
            end

            p_net._g_net:_send_minna_voice_wake()

            if PFastASR then
                if PFastASR:IsVoiceStreamSTTStarted() then
                else
                    coroutine.wrap(function()
                        sleep(0.3)
                        if PX2_SS then
                            PX2_SS:StartRecordingGet("voicestt")
                        end
                        sleep(3.0)
                        myself:_BtnEndGetVoice("voicestt")
                    end)()
                end
            end
        elseif "awakeclear"==str then
            if PFastASR then
                PFastASR:AWakeStreamClear()
            end
        elseif "awakingover"==str then
            print("awakingoverrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")

            if PFastASR then
                local streamText = PFastASR:GetStreamStr()
                print("streamText:"..streamText)

                local streamTextAnsi = StringHelp:UTF8ToAnsi(streamText)
                print("streamTextAnsi:"..streamTextAnsi)

                self:_SetSTTVoiceTextAndGetAnswer(streamText)
            end

        elseif "voice_answer_text"==str then
            myself:_SetTTSSay(str1)
		end
    end)

    local pt = PX2_APP:GetPlatformType()
    if Application.PLT_WINDOWS==pt then
        PX2_APP:LoadPlugin("PLive2D", "PLive2D")
    end
end
-------------------------------------------------------------------------------
function p_robotface:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_robotface:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_robotface:OnPPlay()
	print(self._name.." p_robotface:OnPPlay")
end
-------------------------------------------------------------------------------
function p_robotface:OnPUpdate()
    local espSeconds = PX2_APP:GetElapsedSecondsWidthSpeed()

    if self._fPicBoxFace then
        if g_manykit._faceTexture2D then
            self._fPicBoxFace:Show(true)
            self._fPicBoxFace:GetUIPicBox():SetTexture(g_manykit._faceTexture2D)
        else
            self._fPicBoxFace:Show(false)
        end
    end

    if self._fPicBoxFace1 then
        if g_manykit._faceTexture2D1 then
            self._fPicBoxFace1:Show(true)
            self._fPicBoxFace1:GetUIPicBox():SetTexture(g_manykit._faceTexture2D1)
        else
            self._fPicBoxFace1:Show(false)
        end
    end

    self._BatteryRequestTimeing = self._BatteryRequestTimeing + espSeconds
    if self._BatteryRequestTimeing>1.0 then
        if p_robot._g_sceneInst then
            local arduino = p_robot._g_sceneInst._roboAgent:GetArduino()
            if arduino then
                arduino:RobotGetBattery("def")

                local bat = arduino:RobotBatteryValue("def")
                local batPercStr = (bat+1).."0%"
                if self._btnBattery then
                    self._btnBattery:GetText():SetText(batPercStr)
                end
            end
        end

        self._BatteryRequestTimeing = 0.0
    end
end
-------------------------------------------------------------------------------
-- content frame
function p_robotface:_CreateContentFrame()
	print(self._name.." p_robotface:_CreateContentFrame")

    -- normal face
    local frame = self:_CreateFace()
    self._frameFace = frame
    
    local frameBackLive2D = UIFPicBox:New()
    self._frameBackLive2D = frameBackLive2D
    self._frame:AttachChild(frameBackLive2D)
    frameBackLive2D:LLY(-1.0)
    frameBackLive2D:SetAnchorHor(0.0, 1.0)
    frameBackLive2D:SetAnchorVer(0.0, 1.0)
    frameBackLive2D:GetUIPicBox():SetTexture("scripts/lua/plugins/p_robot/images/star.png")

    -- live2D face
    local canvasLive2D = Canvas:New("CanvasLive2D")
    self._CanvasLive2D = canvasLive2D
    self._frame:AttachChild(canvasLive2D)
    canvasLive2D:LLY(-2.0)
    canvasLive2D:SetAnchorHor(0.0, 1.0)
    canvasLive2D:SetAnchorParamHor(0.0, -0.0)
    canvasLive2D:SetAnchorVer(0.0, 1.0)
    canvasLive2D:SetAnchorParamVer(0.0, -0.0)
    canvasLive2D:GetCanvasRenderBind():SetRenderLayer(Renderable.RL_UI)
    canvasLive2D:CreateUICameraNode()
    canvasLive2D:SetClearFlag(false, false, false)
    canvasLive2D:SetClearColor(Float4(1.0, 0.0, 0.0, 1.0))
    local camNode = self._CanvasLive2D:GetUICameraNode()
    if camNode then
        local cam = camNode:GetCamera()
        if cam then
            cam:Enable(false)
        end
    end

    local uselive2dstr = PX2_PROJ:GetConfig("uselive2d")
    local uselive2d = Utils.IS2B(uselive2dstr)
    self:_UsePLive2D(uselive2d)

    -- home
    local btnHome = UIButton:New("BtnHome")
    self._btnHome = btnHome
    self._frame:AttachChild(btnHome)
	btnHome:LLY(-10.0)
	btnHome:SetAnchorHor(0.0, 0.0)
	btnHome:SetAnchorParamHor(50.0, 50.0)
    btnHome:SetAnchorVer(1.0, 1.0)
	btnHome:SetAnchorParamVer(-50.0, -50.0)
	btnHome:SetSize(60.0, 60.0)
	manykit_uiProcessBtn(btnHome)
    btnHome:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnHome:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("scripts/lua/plugins/p_robot/images/home1.png")
    btnHome:SetScriptHandler("_UICallback", self._scriptControl)
    btnHome:SetAlpha(0.5)

    -- stt
    local btnVoice = UIButton:New("BtnVoice")
    self._btnVoice = btnVoice
    self._frame:AttachChild(btnVoice)
	btnVoice:LLY(-10.0)
	btnVoice:SetAnchorHor(1.0, 1.0)
	btnVoice:SetAnchorParamHor(-50.0, -50.0)
    btnVoice:SetAnchorVer(1.0, 1.0)
	btnVoice:SetAnchorParamVer(-50.0, -50.0)
	btnVoice:SetSize(60.0, 60.0)
	manykit_uiProcessBtn(btnVoice)
    btnVoice:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnVoice:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("scripts/lua/plugins/p_robot/images/voice.png")
    btnVoice:SetScriptHandler("_UICallback", self._scriptControl)
    btnVoice:SetAlpha(0.5)

    -- voice stt
    local frameVoice = UIFrame:New()
    self._frameVoice = frameVoice
    self._frame:AttachChild(frameVoice)
    frameVoice:LLY(-5.0)
    frameVoice:SetAnchorHor(0.0, 1.0)
    frameVoice:SetAnchorParamHor(100.0, -100.0)
    frameVoice:SetAnchorVer(1.0, 1.0)
    frameVoice:SetAnchorParamVer(-8.0, -8.0)
    frameVoice:SetHeight(80.0)
    frameVoice:SetPivot(0.5, 1.0)
    local back = frameVoice:CreateAddBackgroundPicBox()
    back:SetTexture("scripts/lua/plugins/p_robot/images/roundsmall.png")
    back:SetPicBoxType(UIPicBox.PBT_NINE)
    back:SetTexCornerSize(40, 40, 40, 40)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.5)

    local fTextVoice = UIFText:New()
    self._fTextVoice = fTextVoice
	frameVoice:AttachChild(fTextVoice)
	fTextVoice:LLY(-5)
	fTextVoice:SetAnchorHor(0.0, 1.0)
    fTextVoice:SetAnchorParamHor(15.0, -15.0)
	fTextVoice:SetAnchorVer(0.0, 1.0)
    fTextVoice:SetAnchorParamVer(-5.0, -5.0)
	fTextVoice:GetText():SetText("")
    fTextVoice:GetText():SetFontColor(Float3(1.0, 1.0, 1.0))
    fTextVoice:GetText():SetDrawStyle(FD_BORDER)

    self:_ShowSTT(false)

    -- say
    local frameSay = UIFrame:New()
    self._frameSay = frameSay
    self._frame:AttachChild(frameSay)
    frameSay:LLY(-5.0)
    frameSay:SetAnchorHor(0.0, 1.0)
    frameSay:SetAnchorParamHor(100.0, -100.0)
    frameSay:SetAnchorVer(0.0, 0.0)
    frameSay:SetAnchorParamVer(8.0, 8.0)
    frameSay:SetHeight(80.0)
    frameSay:SetPivot(0.5, 0.0)
    local back = frameSay:CreateAddBackgroundPicBox()
    back:SetTexture("scripts/lua/plugins/p_robot/images/roundsmall.png")
    back:SetPicBoxType(UIPicBox.PBT_NINE)
    back:SetTexCornerSize(40, 40, 40, 40)
    back:UseAlphaBlend(true)
    back:SetAlpha(0.5)

    local fTextSay = UIFText:New()
    self._fTextSay = fTextSay
	frameSay:AttachChild(fTextSay)
	fTextSay:LLY(-5)
	fTextSay:SetAnchorHor(0.0, 1.0)
    fTextSay:SetAnchorParamHor(15.0, -15.0)
	fTextSay:SetAnchorVer(0.0, 1.0)
    fTextSay:SetAnchorParamVer(-5.0, -5.0)
	fTextSay:GetText():SetText("")
    fTextSay:GetText():SetFontColor(Float3(1.0, 1.0, 1.0))
    fTextSay:GetText():SetDrawStyle(FD_BORDER)

    --self:_SetTTSSay("你好!我是小豪", true)

    self:_ShowTTS(false)

    -- face0
    local picBoxFace = UIFPicBox:New("FPicBoxFace")
	self._fPicBoxFace = picBoxFace
    self._frame:AttachChild(picBoxFace)
	picBoxFace:LLY(-5.0)
    picBoxFace:SetAnchorHor(0.0, 0.0)
    picBoxFace:SetAnchorParamHor(5.0, 5.0)
    picBoxFace:SetAnchorVer(0.0, 0.0)
    picBoxFace:SetAnchorParamVer(5.0, 5.0)
    picBoxFace:SetSize(200.0, 200.0)
    picBoxFace:SetPivot(0.0, 0.0)
    picBoxFace:GetUIPicBox():SetMaterialType(UIPicBox.MT_NIGHT)
	picBoxFace:GetUIPicBox():SetNightParamControl(Float4(0.5, 0.5, 1.0, 0) )
	picBoxFace:SetBrightness(1.0)
	picBoxFace:SetColor(Float3.WHITE)

	local picBoxFace1 = UIFPicBox:New("FPicBoxFace1")
	self._fPicBoxFace1 = picBoxFace1
    self._frame:AttachChild(picBoxFace1)
	picBoxFace1:LLY(-5.0)
    picBoxFace1:SetAnchorHor(1.0, 1.0)
    picBoxFace1:SetAnchorParamHor(-5.0, -5.0)
    picBoxFace1:SetAnchorVer(0.0, 0.0)
    picBoxFace1:SetAnchorParamVer(5.0, 5.0)
    picBoxFace1:SetSize(200.0, 200.0)
    picBoxFace1:SetPivot(1.0, 0.0)
    picBoxFace1:GetUIPicBox():SetMaterialType(UIPicBox.MT_NIGHT)
	picBoxFace1:GetUIPicBox():SetNightParamControl(Float4(0.5, 1.0, 1.0, 0) )
	picBoxFace1:SetBrightness(1.0)
	picBoxFace1:SetColor(Float3.WHITE)

    local btnSetting = UIButton:New("BtnSetting")
	self._btnSetting = btnSetting
	self._frame:AttachChild(btnSetting)
	btnSetting:LLY(-10.0)
	btnSetting:SetAnchorHor(1.0, 1.0)
	btnSetting:SetAnchorVer(0.0, 0.0)
	btnSetting:SetAnchorParamHor(-44.0, -44.0)
	btnSetting:SetAnchorParamVer(44.0, 44.0)
	btnSetting:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
	btnSetting:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/setting.png")
	btnSetting:SetScriptHandler("_UICallback", self._scriptControl)

    local uiFrameBack = self:_CreateMgrFrame()
    self._frameMgr = uiFrameBack
	self._frame:AttachChild(uiFrameBack)
	uiFrameBack:LLY(-20)
    uiFrameBack:SetAnchorHor(0.0, 0.3)
	uiFrameBack:Show(false)

    local btnBattery = UIButton:New("BtnBattery")
    self._frame:AttachChild(btnBattery)
    self._btnBattery = btnBattery
	btnBattery:SetAnchorHor(0.0, 0.0)
	btnBattery:SetAnchorVer(0.0, 0.0)
	btnBattery:SetAnchorParamHor(20.0, 20.0)
	btnBattery:SetAnchorParamVer(44.0, 44.0)
    btnBattery:SetPivot(0.0, 0.5)
    btnBattery:LLY(-2.0)
    btnBattery:SetStateColor(UIButtonBase.BS_NORMAL, Float3.WHITE)
    btnBattery:SetStateColor(UIButtonBase.BS_HOVERED, Float3.WHITE)
    btnBattery:SetStateColor(UIButtonBase.BS_PRESSED, Float3:MakeColor(150, 150, 150))
    btnBattery:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("scripts/lua/plugins/p_robot/images/battery.png")
    btnBattery:SetSize(100.0, 80.0)
    btnBattery:SetAlpha(0.5)
    local fText = btnBattery:CreateAddFText("".."0%")
    fText:GetText():SetFontSize(24)
    manykit_uiProcessFText(fText)
end
-------------------------------------------------------------------------------
-- stt
function p_robotface:_SetSTTVoiceTextAndGetAnswer(str)
	print(self._name.." p_robotface:_SetSTTVoiceTextAndGetAnswer:"..str)

    p_net._g_net:_send_minna_voice_text(str)

    self:_FrameSetText(self._frameVoice, self._fTextVoice, str)

    local netid = PX2_PROJ:GetConfig("netid_minna")
    print("netid:"..netid)

    if ""~=netid then
        p_net._g_net:_act_voice_getanswer(netid, str)
    end
end
-------------------------------------------------------------------------------
function p_robotface:_BtnEndGetVoice(ttsname)
    print(self._name.." p_robotface:_BtnEndGetVoice")

    if PFastASR then
        PFastASR:OnVoiceAWakingOver(false)
    end

    local f = self._voiceSavePath .. "stt.wav"
    if PX2_SS then
        PX2_SS:EndRecordingGet(ttsname, f)
    end

    if p_net.g_sttprocessserverindex==0 then
        if PFastASR then
            local str = PFastASR:SpeachToText(f, PFastASRPlugin.MT_K2_RNNT2)
            str = str:gsub("[%c]", "")
            self:_SetSTTVoiceTextAndGetAnswer(str)
        end
    else

        local url = p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/aitalk/stt"
        print("urllll:"..url)

        local curl = CurlObj:NewThread()
        curl:PostFile(url, f, "_sttUploadCallback", self._scriptControl)
    end
end
-------------------------------------------------------------------------------
function p_robotface:_sttUploadCallback(ptr)    
    local curlObj = Cast:ToO(ptr)
end
-------------------------------------------------------------------------------
function p_robotface:_ShowSTT(show)
    if self._frameVoice then
        self._frameVoice:Show(show)
    end
end
-------------------------------------------------------------------------------
-- tts
function p_robotface:_SetTTSSay(str, doSpeach)
    --p_net._g_net:_send_minna_voice_answer_text(str)

    self:_FrameSetText(self._frameSay, self._fTextSay, str)

    if doSpeach then
        local pth = self._voiceSavePath .. PX2_IDM:GetNextID("Vocie") ..".wav"
        if PFastASR then
            PFastASR:TextToSpeach(str, pth)
        end
    end
end
-------------------------------------------------------------------------------
function p_robotface:_FrameSetText(frame, fText, str)
    frame:Show(true)

    local sw = fText:GetSize().Width
    local sw2 = sw*2.0
    local w = fText:GetText():GetTextWidth(str)

    print("sw:"..sw)
    print("w:"..w)

    if w>sw then
        local perc = sw/w
        fText:GetText():SetFontScale(perc)
        fText:GetText():SetFontSize(64)
        fText:GetText():SetRectUseage(RU_ALIGNS)
        fText:GetText():SetAligns(TEXTALIGN_HCENTER+TEXTALIGN_VCENTER)
        fText:GetText():SetAutoWarp(false)
    else
        fText:GetText():SetFontScale(1.0)
        fText:GetText():SetFontSize(64)
        fText:GetText():SetRectUseage(RU_ALIGNS)
        fText:GetText():SetAligns(TEXTALIGN_HCENTER+TEXTALIGN_VCENTER)
        fText:GetText():SetAutoWarp(false)
    end

    fText:GetText():SetText(str)
end
-------------------------------------------------------------------------------
function p_robotface:_ShowTTS(show)
    if self._frameSay then
        self._frameSay:Show(show)
    end
end
-------------------------------------------------------------------------------
-- face
function p_robotface:_CreateFace()
    print(self._name.." p_robotface:_CreateFace")

    local frame = UIFrame:New()
    self._frame:AttachChild(frame)
    frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
    local back = frame:CreateAddBackgroundPicBox(true, Float3:MakeColor(46, 54, 72))

    local frameEyeL = UIFrame:New()
    self._eyeleft = frameEyeL
    frame:AttachChild(frameEyeL)
    frameEyeL:LLY(-2.0)
    frameEyeL:SetSize(self._eyesize, self._eyesize)
    frameEyeL:SetColor(Float3:MakeColor(138, 226, 256))
    frameEyeL:EnableAnchorLayout(false)
    frameEyeL.LocalTransform:SetTranslate(APoint(-self._eyedist, 0.0, self._eyeh))

    local ctrl = UIPicBoxListController:New()
    self._eyeleftctrl = ctrl
    frameEyeL:AttachController(ctrl)
    ctrl:ResetPlay()

    local ctrlMoveL = InterpCurveTranslateController:New()
    self._eyectrlmove_left = ctrlMoveL
    frameEyeL:AttachController(ctrlMoveL)
    ctrlMoveL:Clear()
    ctrlMoveL:AddPoint(0.0, Float3(-self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
    ctrlMoveL.MaxTime = 1.0
    ctrlMoveL.Repeat = Controller.RT_CYCLE
    ctrlMoveL:ResetPlay()

    local frameEyeR = UIFrame:New()
    self._eyeright = frameEyeR
    frame:AttachChild(frameEyeR)
    frameEyeR:LLY(-2.0)
    frameEyeR:SetSize(self._eyesize, self._eyesize)
    frameEyeR:SetPivot(0.5, 0.5)
    frameEyeR:SetColor(Float3:MakeColor(138, 226, 256))
    frameEyeR.LocalTransform:SetTranslate(APoint(self._eyedist, 0.0, self._eyeh))

    local ctrl = UIPicBoxListController:New()
    self._eyerightctrl = ctrl
    frameEyeR:AttachController(ctrl)
    ctrl:SetInterval(0.02)
    ctrl:ResetPlay()

    local ctrlMoveR = InterpCurveTranslateController:New()
    self._eyectrlmove_right = ctrlMoveR
    frameEyeR:AttachController(ctrlMoveR)
    ctrlMoveR:Clear()
    ctrlMoveR:AddPoint(0.0, Float3(self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
    ctrlMoveR.MaxTime = 1.0
    ctrlMoveR.Repeat = Controller.RT_CYCLE
    ctrlMoveR:ResetPlay()

    self:_PlayFaceNormal()

    local fPicBoxMouse = UIFrame:New()
    frame:AttachChild(fPicBoxMouse)
    fPicBoxMouse:LLY(-2.0)
    fPicBoxMouse:SetAnchorHor(0.5, 0.5)
    fPicBoxMouse:SetAnchorParamHor(0.0, 0.0)
    fPicBoxMouse:SetAnchorVer(0.5, 0.5)
    fPicBoxMouse:SetAnchorParamVer(self._mouseh, self._mouseh)
    fPicBoxMouse:SetSize(self._szmouse)
    fPicBoxMouse:SetPivot(0.5, 0.5)
    fPicBoxMouse:SetColor(Float3:MakeColor(138, 226, 256))

    local ctrlMouth = UIPicBoxListController:New()
    self._ctrlMouth = ctrlMouth
    fPicBoxMouse:AttachController(ctrlMouth)
    ctrlMouth:SetInterval(0.02)
    ctrlMouth:ResetPlay()
    local ctrl = self._ctrlMouth
    ctrl:Clear()
    local pth = "scripts/lua/plugins/p_robot/images/mouse/"
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."1.png")
    ctrl:AddPicBox(pth.."2.png")
    ctrl:AddPicBox(pth.."3.png")
    ctrl:AddPicBox(pth.."4.png")
    ctrl:AddPicBox(pth.."5.png")
    ctrl:AddPicBox(pth.."6.png")
    ctrl:AddPicBox(pth.."7.png")
    ctrl:AddPicBox(pth.."8.png")
    ctrl:AddPicBox(pth.."9.png")
    ctrl:AddPicBox(pth.."10.png")
    ctrl:AddPicBox(pth.."11.png")
    ctrl:AddPicBox(pth.."12.png")
    ctrl:AddPicBox(pth.."13.png")
    ctrl:AddPicBox(pth.."14.png")
    ctrl:AddPicBox(pth.."15.png")
    ctrl:AddPicBox(pth.."16.png")
    ctrl:AddPicBox(pth.."17.png")
    ctrl:AddPicBox(pth.."18.png")
    self:_MouthNormal()

    return frame
end
-------------------------------------------------------------------------------
function p_robotface:_MouthSay()
    local interval = 0.02
    local ctrl = self._ctrlMouth
    ctrl:SetInterval(interval)
    ctrl.MaxTime = interval*19
    ctrl.Repeat = Controller.RT_CYCLE
    ctrl:ResetPlay()
end
-------------------------------------------------------------------------------
function p_robotface:_MouthNormal()
    self._ctrlMouth:Reset()
    self._ctrlMouth:Pause()
end
-------------------------------------------------------------------------------
function p_robotface:_BlinkEye(t)
    local rnd = Mathf:IntervalRandom(1.0, 5.0)
    if rnd>=3.0 then
        self._eyeleftctrl.MaxTime = t*2.0
        self._eyerightctrl.MaxTime = t*2.0
        self._eyeleftctrl:ResetPlay()
        self._eyerightctrl:ResetPlay()
        sleep(t*2.0)
        self._eyeleftctrl:Reset()
        self._eyeleftctrl:Pause()
        self._eyerightctrl:Reset()
        self._eyerightctrl:Pause()
    else
        self._eyeleftctrl.MaxTime = t
        self._eyerightctrl.MaxTime = t
        self._eyeleftctrl:ResetPlay()
        self._eyerightctrl:ResetPlay()
        sleep(t)
        self._eyeleftctrl:Reset()
        self._eyeleftctrl:Pause()
        self._eyerightctrl:Reset()
        self._eyerightctrl:Pause()
    end
end
-------------------------------------------------------------------------------
function p_robotface:_PlayFaceNormal()
    self._isplayingface_normal = true

    local pth = "scripts/lua/plugins/p_robot/images/eye/"
    local interval = 0.02
    for i=0, 1, 1 do
        local ctrlFace = self._eyeleftctrl
        if 0==i then
            ctrlFace = self._eyeleftctrl
        elseif 1==i then
            ctrlFace = self._eyerightctrl
        end

        ctrlFace:Clear()
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."1.png")
        ctrlFace:AddPicBox(pth.."2.png")
        ctrlFace:AddPicBox(pth.."3.png")
        ctrlFace:AddPicBox(pth.."4.png")
        ctrlFace:AddPicBox(pth.."5.png")
        ctrlFace:AddPicBox(pth.."6.png")
        ctrlFace:AddPicBox(pth.."7.png")
        ctrlFace:AddPicBox(pth.."8.png")
        ctrlFace:AddPicBox(pth.."9.png")
        ctrlFace:AddPicBox(pth.."10.png")
        ctrlFace:AddPicBox(pth.."11.png")
        ctrlFace:AddPicBox(pth.."12.png")
        ctrlFace:AddPicBox(pth.."13.png")
        ctrlFace:AddPicBox(pth.."14.png")
        ctrlFace:AddPicBox(pth.."15.png")
        ctrlFace:AddPicBox(pth.."16.png")
        ctrlFace:SetInterval(interval)
    end

    local t = interval*27
    self._eyeleftctrl.MaxTime = t
    self._eyeleftctrl.Repeat = Controller.RT_CLAMP
    self._eyerightctrl.MaxTime = t
    self._eyerightctrl.Repeat = Controller.RT_CLAMP

    coroutine.wrap(function()
        while self._isplayingface_normal do
            self:_BlinkEye(t)

            sleep(Mathf:IntervalRandom(1.0, 3.0))

            local rand = Mathf:SymmetricRandom()
            local dist = 40.0 * Mathf:Sign(rand) + rand * 40.0
            for j=0, 1, 1 do
                local sign = -1.0
                local ctrlMove = self._eyectrlmove_left
                if 0==j then
                    sign = -1.0
                    ctrlMove = self._eyectrlmove_left
                elseif 1==j then
                    sign = 1.0
                    ctrlMove = self._eyectrlmove_right
                end

                ctrlMove:Clear()
                ctrlMove:AddPoint(0.0, Float3(sign * self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
                ctrlMove:AddPoint(0.5, Float3(sign * self._eyedist + dist, 0.0, self._eyeh), ICM_CURVE_AUTO)
                ctrlMove.MaxTime = 0.5
                ctrlMove.Repeat = Controller.RT_CLAMP
                ctrlMove:ResetPlay()                
            end
            sleep(0.5)

            self:_BlinkEye(t)

            sleep(Mathf:IntervalRandom(1.0, 3.0))

            for j=0, 1, 1 do
                local sign = -1.0
                local ctrlMove = self._eyectrlmove_left
                if 0==j then
                    sign = -1.0
                    ctrlMove = self._eyectrlmove_left
                elseif 1==j then
                    sign = 1.0
                    ctrlMove = self._eyectrlmove_right
                end

                ctrlMove:Clear()
                ctrlMove:AddPoint(0.0, Float3(sign * self._eyedist + dist, 0.0, self._eyeh), ICM_CURVE_AUTO)
                ctrlMove:AddPoint(0.5, Float3(sign * self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
                ctrlMove.MaxTime = 0.5
                ctrlMove.Repeat = Controller.RT_CLAMP
                ctrlMove:ResetPlay()                
            end
            sleep(0.5)

            sleep(Mathf:IntervalRandom(1.0, 3.0))
        end
    end)()
end
-------------------------------------------------------------------------------
function p_robotface:_PlayFaceMusic()
    local pth = "scripts/lua/plugins/p_robot/images/eye/"

    local ctrl = self._eyeleftctrl
    ctrl:Clear()
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."1.png")
    ctrl:AddPicBox(pth.."2.png")
    ctrl:AddPicBox(pth.."3.png")
    ctrl:AddPicBox(pth.."4.png")
    ctrl:AddPicBox(pth.."5.png")
    ctrl:AddPicBox(pth.."6.png")
    ctrl:AddPicBox(pth.."7.png")
    ctrl:AddPicBox(pth.."8.png")
    ctrl:AddPicBox(pth.."9.png")
    ctrl:AddPicBox(pth.."10.png")
    ctrl:AddPicBox(pth.."11.png")
    ctrl:AddPicBox(pth.."12.png")
    ctrl:AddPicBox(pth.."13.png")
    ctrl:AddPicBox(pth.."14.png")
    ctrl:AddPicBox(pth.."15.png")
    ctrl:AddPicBox(pth.."16.png")
    ctrl:SetInterval(0.02)
    ctrl:ResetPlay()

    local ctrl = self._eyerightctrl
    ctrl:Clear()
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."0.png")
    ctrl:AddPicBox(pth.."1.png")
    ctrl:AddPicBox(pth.."2.png")
    ctrl:AddPicBox(pth.."3.png")
    ctrl:AddPicBox(pth.."4.png")
    ctrl:AddPicBox(pth.."5.png")
    ctrl:AddPicBox(pth.."6.png")
    ctrl:AddPicBox(pth.."7.png")
    ctrl:AddPicBox(pth.."8.png")
    ctrl:AddPicBox(pth.."9.png")
    ctrl:AddPicBox(pth.."10.png")
    ctrl:AddPicBox(pth.."11.png")
    ctrl:AddPicBox(pth.."12.png")
    ctrl:AddPicBox(pth.."13.png")
    ctrl:AddPicBox(pth.."14.png")
    ctrl:AddPicBox(pth.."15.png")
    ctrl:AddPicBox(pth.."16.png")
    ctrl:SetInterval(0.02)
    ctrl:ResetPlay()

    self._eyectrlmove_left:Clear()
    self._eyectrlmove_left:AddPoint(0.0, Float3(-self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
    self._eyectrlmove_left:AddPoint(1.0, Float3(-self._eyesize*0.6, 0.0, self._eyeh), ICM_CURVE_AUTO)
    self._eyectrlmove_left:ResetPlay()

    self._eyectrlmove_right:Clear()
    self._eyectrlmove_right:AddPoint(0.0, Float3(self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
    self._eyectrlmove_right:AddPoint(1.0, Float3(self._eyesize*0.6, 0.0, self._eyeh), ICM_CURVE_AUTO)
    self._eyectrlmove_right:ResetPlay()
end
-------------------------------------------------------------------------------
function p_robotface:_PlayFaceHappy()
    local pth = "scripts/lua/plugins/p_robot/images/eye/"
    local dist = 80.0

    for i=0, 1, 1 do
        local sign = -1.0
        local ctrlFace = self._eyeleftctrl
        local ctrlMove = self._eyectrlmove_left
        if 0==i then
            sign = -1.0
            ctrlFace = self._eyeleftctrl
            ctrlMove = self._eyectrlmove_left
        elseif 1==i then
            sign = 1.0
            ctrlFace = self._eyerightctrl
            ctrlMove = self._eyectrlmove_right
        end

        ctrlFace:Clear()
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."0.png")
        ctrlFace:AddPicBox(pth.."1.png")
        ctrlFace:AddPicBox(pth.."2.png")
        ctrlFace:AddPicBox(pth.."3.png")
        ctrlFace:AddPicBox(pth.."4.png")
        ctrlFace:AddPicBox(pth.."5.png")
        ctrlFace:AddPicBox(pth.."6.png")
        ctrlFace:AddPicBox(pth.."7.png")
        ctrlFace:AddPicBox(pth.."8.png")
        ctrlFace:AddPicBox(pth.."9.png")
        ctrlFace:AddPicBox(pth.."10.png")
        ctrlFace:AddPicBox(pth.."11.png")
        ctrlFace:AddPicBox(pth.."12.png")
        ctrlFace:AddPicBox(pth.."13.png")
        ctrlFace:AddPicBox(pth.."14.png")
        ctrlFace:AddPicBox(pth.."15.png")
        ctrlFace:AddPicBox(pth.."16.png")
        ctrlFace:SetInterval(0.02)
        ctrlFace:ResetPlay()

        ctrlMove:Clear()
        ctrlMove:AddPoint(0.0, Float3(sign * self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
        ctrlMove:AddPoint(0.5, Float3(sign * self._eyedist + dist, 0.0, self._eyeh), ICM_CURVE_AUTO)
        ctrlMove:AddPoint(1.0, Float3(sign * self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
        ctrlMove:AddPoint(1.5, Float3(sign * self._eyedist - dist, 0.0, self._eyeh), ICM_CURVE_AUTO)
        ctrlMove:AddPoint(2.0, Float3(sign * self._eyedist, 0.0, self._eyeh), ICM_CURVE_AUTO)
        ctrlMove.MaxTime = 2.0
        ctrlMove.Repeat = Controller.RT_CYCLE
        ctrlMove:ResetPlay()
    end
end
-------------------------------------------------------------------------------
function p_robotface:_UsePLive2D(use)
	print("p_robotface:_UsePLive2D")
    print_i_b(use)

    self._isuselive2d = use

    if self._CanvasLive2D then
        self._CanvasLive2D:Show(use)
    end

    if self._frameBackLive2D then
        self._frameBackLive2D:Show(use)
    end

    if self._frameFace then
        self._frameFace:Show(not use)
    end

    PX2_PROJ:SetConfig("uselive2d", Utils.B2IS(use))
end
-------------------------------------------------------------------------------
function p_robotface:_PlayMotion(groupIndex, subIndex)
	print("p_robotface:_PlayMotion")
    print("groupIndex:"..groupIndex)
    print("subIndex:"..subIndex)

    if PLive2D then
        local name = PLive2D:GetMotionGroupName(groupIndex)
        PLive2D:PlayMotion(name, subIndex, "");
    end
end
-------------------------------------------------------------------------------
-- settings
function p_robotface:SetEyeLeftColor(color)
    if nil~=self._eyeleft then
        self._eyeleft:SetColor(color)
    end
end

function p_robotface:SetEyeLeftSize(size)
    if nil~=self._eyeleft then
        self._eyeleft:SetSize(size, size)
    end
end

function p_robotface:SetEyeRightColor(color)
    if nil~=self._eyeright then
        self._eyeright:SetColor(color)
    end
end

function p_robotface:SetEyeRightSize(size)
    if nil~=self._eyeright then
        self._eyeright:SetSize(size, size)
    end
end

-- setting
function p_robotface:_CreateMgrFrame()
	local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "")
	self._frameMgr = uiFrameBack
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local frameTable = UITabFrame:New("TabFrameInfo")
    uiFrame:AttachChild(frameTable)
    frameTable:AddTab("Setting", ""..PX2_LM_APP:V("Setting"), self:_CreateFrameSetting())
    frameTable:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessTable(frameTable)
    frameTable:SetActiveTab("Setting")

	return uiFrameBack
end

function p_robotface:_CreateFrameSetting()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

	local pg = UIPropertyGrid:New("PropertyGridEdit")
    self._propertyGridEdit = pg
    uiFrame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl) 
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)

	return uiFrame
end

function p_robotface:_RegistPropertyOnSetting()
	print(self._name.." p_robotface:_RegistPropertyOnSetting")

	self._scriptControl:RemoveProperties("EditSetting")

    self._scriptControl:BeginPropertyCata("EditSetting")
    self._scriptControl:AddPropertyClass("Setting", "设置")

    self._scriptControl:AddPropertyBool("IsUsePLive2D", "Live2D", self._isuselive2d, true, true)

    if PLive2D then
        local numScene = PLive2D:GetNumScene()
        local tabSceneIndex = {}
        for i=0, numScene-1, 1 do
            table.insert(tabSceneIndex, #tabSceneIndex + 1, i)
        end
        PX2Table2Vector(tabSceneIndex)
        self._scriptControl:AddPropertyEnum("SceneIndex", "场景", self._sceneIndex, PX2_GH:Vec(), true, false)

        local numAnimGroup = PLive2D:GetNumMotionGroup()
        local tabAnimGroup = {}
        for i=0, numAnimGroup-1, 1 do
            local groupName = PLive2D:GetMotionGroupName(i)
            table.insert(tabAnimGroup, #tabAnimGroup + 1, groupName)
        end
        PX2Table2Vector(tabAnimGroup)
        self._scriptControl:AddPropertyEnum("AnimGroup", "动画", self._animGroupIndex, PX2_GH:Vec(), true, false)

        local count = PLive2D:GetMotionGroupCountByIndex(self._animGroupIndex)
        local tabSub = {}
        for i=0, count-1, 1 do
            table.insert(tabSub, #tabSub + 1, i)
        end
        PX2Table2Vector(tabSub)
        self._scriptControl:AddPropertyEnum("AnimGroupSubIndex", "子动画", self._animGroupSubIndex, PX2_GH:Vec(), true, false)

    end

    self._scriptControl:EndPropertyCata()

    self._propertyGridEdit:RegistOnObject(self._scriptControl, "EditSetting")
end

function p_robotface:_ShowSetting(show)
	print("p_robotface:_ShowSetting")
	print_i_b(show)

	self._frameMgr:Show(show)

    if show then
        self:_RegistPropertyOnSetting()
    end
end
-------------------------------------------------------------------------------
-- callback
function p_robotface:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()
    local platType = PX2_APP:GetPlatformType()

    if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
        if name=="BtnVoice" then
            print("BtnVoice")
            if PX2_SS then
                PX2_SS:StartRecordingGet("voicestt")
            end
        end
    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)
        if name=="BtnHome" then
			g_manykit:_ShowSide(not g_manykit.IsShowSide)
        elseif name=="BtnVoice" then
            self:_BtnEndGetVoice("voicestt")
        elseif "BtnDlgClose"==name then
            self:_ShowSetting(false)
        elseif "BtnSetting"==name then
            self:_ShowSetting(true)
        end
    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)
    elseif UICT_PROPERTY_CHANGED==callType then
        local pObj = obj:GetPorpertyObject()
        print("obj.Name:"..pObj.Name)

        if "SceneIndex"==pObj.Name then
            self._sceneIndex = pObj:PInt()

            if PLive2D then
                PLive2D:ChangeToScene(self._sceneIndex)
            end

            self:_RegistPropertyOnSetting()
        elseif "AnimGroup"==pObj.Name then
            self._animGroupSubIndex = 0
            self._animGroupIndex = pObj:PInt()

            self:_RegistPropertyOnSetting()

            self:_PlayMotion(self._animGroupIndex, self._animGroupSubIndex)
        elseif "AnimGroupSubIndex"==pObj.Name then
            self._animGroupSubIndex = pObj:PInt()

            self:_RegistPropertyOnSetting()

            self:_PlayMotion(self._animGroupIndex, self._animGroupSubIndex)
        elseif "IsUsePLive2D"==pObj.Name then
            local use = pObj:PBool()
            self._isuselive2d = use
            
            self:_UsePLive2D(use)
        end
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_robotface)
-------------------------------------------------------------------------------