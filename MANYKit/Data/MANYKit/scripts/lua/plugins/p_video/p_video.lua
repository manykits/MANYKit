-- p_video.lua

p_video = class(p_ctrl,
{
	_name = "p_video",

	_nextFaceID = 50000,

	-- pic
	_fPicBoxCamera0 = nil,
	_fPicBoxCamera1 = nil,
	_fPicBoxCamera2 = nil,

	-- setting ui
	_btnSetting = nil,
	_frameMgr = nil,
	_setting_DeviceID = nil,
	_setting_InfoText = nil,
	_setting_ListGroup = nil,
	_setting_ListFace = nil,
	_propertyGridUser = nil,

	_propertyGridEdit = nil,
	_editboxName = nil,

	-- face
	_isRefreshCameraCVID = false,
	_cvidCamera0 = -1,
	_cvidCamera1 = -1,
	_isShow0 = true,
	_isShow1 = true,
	_isShow2 = true,

	-- slam
	_isSlamMapBinOK = false,
	_isSlamMapPlyOK = false,

	-- face detect
	_isUseFaceIdentify = false,
	_identifyUseIndex = 0,
	_identifyScore = 80,
	_identifySamePeopleTime = 1,
	_identifySamePeopleTimeIndex = 0,

	-- rtsp rtmp
	_isRtsp = false,
	_isRtmp = false,
	_cameraKey = "",
	_ipindex_rtmp = 0,
	_ip_rtmp = "",

	-- april tag
	_isOpenAprilTag = false,
	_aprilTagType = 0,
	_aprilTagSize = 0.024,
	_aprilTagScale = 1.0,
	_aprilTagAlpha = 1.0,
	_aprilTagLight = 0.0,
	_aprilTagIRThreshold = 100.0,
	_weaponIPIndex = 0,
	_aprilRectFloat4 = Float4(),

	-- identify
	_lastidentifiedtiming = 0.0,

	_lastidentifyuserid = "",
	_lastidentifytime = 0,
	_isidentifyresetted = true,

	-- taking photo
	_istakingphoto = false,
	_takingphotouserid = "",

	-- identify show ui
	_frameIdentify = nil,
	_fTextIdentifyName = nil,

	-- callback
	_imgregcallback_url = "",
	_identifycallback_url = "",
	_heartcallback_url = "",

	_mkdir = "MANYKit",
})
-------------------------------------------------------------------------------
function p_video:OnAttached()
	PX2_LM_APP:AddItem(self._name, "Video", "视频")
	PX2_LM_APP:AddItem("Video", "Video", "视频")
	PX2_LM_APP:AddItem("Face", "Face", "人脸")
	PX2_LM_APP:AddItem("Setting", "Setting", "设置")

	p_ctrl.OnAttached(self)
	print(self._name.." p_video:OnAttached")

	PX2_APP:LoadConfig(self._mkdir, "userinfo")

    print("is mk system")

    local idstr = PX2_PROJ:GetConfig("NextFaceID")
    if ""~=idstr then
        self._nextFaceID = StringHelp:StringToInt(idstr)
    end

    self._isShow0 = PX2_PROJ:GetConfigInt("pvideo_isshow0")==1
    self._isShow1 = PX2_PROJ:GetConfigInt("pvideo_isshow1")==1
    self._isShow2 = PX2_PROJ:GetConfigInt("pvideo_isshow2")==1

    local idx = PX2_PROJ:GetConfigInt("p_video_weaponipindex", self._weaponIPIndex)
    self._weaponIPIndex = idx
    if 0==idx then
        p_net._g_ip_weapontrigger = "192.168.6.51"
    elseif 1==idx then
        p_net._g_ip_weapontrigger = "192.168.6.52"
    elseif 2==idx then
        p_net._g_ip_weapontrigger = "192.168.6.53"
    elseif 3==idx then
        p_net._g_ip_weapontrigger = "192.168.6.54"
    elseif 4==idx then
        p_net._g_ip_weapontrigger = "192.168.6.55"
    elseif 5==idx then
        p_net._g_ip_weapontrigger = "192.168.6.56"
    end

    local isUseFaceIdentifyStr = PX2_PROJ:GetConfig("face_isusefaceidentify")
    self._isUseFaceIdentify = Utils.IS2B(isUseFaceIdentifyStr)	
    self:_UseFaceIdentify(self._isUseFaceIdentify)

    local identifyUseIndexStr = PX2_PROJ:GetConfig("face_identifyUseIndex")
    if ""~=identifyUseIndexStr then
        self._identifyUseIndex = StringHelp:StringToInt(identifyUseIndexStr)
    end

    local identifyScoreStr = PX2_PROJ:GetConfig("face_identifyScore")
    if ""~=identifyScoreStr then
        self._identifyScore = StringHelp:StringToFloat(identifyScoreStr)
        PX2_OPENCVM:SetIdentifyScore(self._identifyScore)
    end

    local face_identifySamePeopleTimeStr = PX2_PROJ:GetConfig("face_identifySamePeopleTime")
    if ""~=face_identifySamePeopleTimeStr then
        self._identifySamePeopleTime = StringHelp:StringToFloat(face_identifySamePeopleTimeStr)
    end
    local face_identifySamePeopleTimeIndexStr = PX2_PROJ:GetConfig("face_identifySamePeopleTimeIndex")
    if ""~=face_identifySamePeopleTimeIndexStr then
        self._identifySamePeopleTimeIndex = StringHelp:StringToInt(face_identifySamePeopleTimeIndexStr)
    end

    local isRtspStr = PX2_PROJ:GetConfig("video_isrtsp")
    self._isRtsp = Utils.IS2B(isRtspStr)
    local isRtmpStr = PX2_PROJ:GetConfig("video_isrtmp")
    self._isRtmp = Utils.IS2B(isRtmpStr)	
    self._cameraKey = PX2_PROJ:GetConfig("video_camerakey")

    self:_CreateContentFrame()

    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
        if "peoplein"==str then		
            if "0"==str1 then	
                local url = self._identifycallback_url
                if ""~=url then
                    local allurl = url .."?type=1&userid=STRANGERBABY".."&ip="..p_net.g_ip_minna.."&imagepath=''"
                        .."&devicekey="..PX2_OPENCVM:GetFaceDeviceID().."&act=strangerin"
                    local curlObj = CurlObj:NewThread()
                    curlObj:Get(allurl, "identifyCallback", self._scriptControl)
                end
            end

            p_net._g_net:_send_minna_face_peoplein(str1)
        elseif "peopleout"==str then
            if "0"==str1 then
                local url = self._identifycallback_url
                if ""~=url then
                    local allurl = url .."?type=1&userid=STRANGERBABY".."&ip="..p_net.g_ip_minna.."&imagepath=''"
                        .."&devicekey="..PX2_OPENCVM:GetFaceDeviceID().."&act=strangerout"
                    local curlObj = CurlObj:NewThread()
                    curlObj:Get(allurl, "identifyCallback", self._scriptControl)
                end
            end
            p_net._g_net:_send_minna_face_peopleout(str1)
        elseif "faceidentify"==str then
            print("faceidentify:")

            local faceRet = PX2_OPENCVM:GetFaceRegRet()
            local faceRegResult = faceRet:GetResult(0)
            print("GroupIDStr:"..faceRegResult.GroupIDStr)
            print("ScoreStr:"..faceRegResult.ScoreStr)
            print("UserIDStr:"..faceRegResult.UserIDStr)

            local imagePath = str1

            local tab = PX2JSon.decode(faceRegResult.UserInfoStr)
            -- print("UserInfoStr0:"..tab.data.log_id)
            -- print("UserInfoStr:"..tab.data.result[1].user_info)

            local name = PX2_APP:GetConfig(self._mkdir, "userinfo", faceRegResult.UserIDStr)
            myself:_ShowIdentifyFrame(name)

            local url = self._identifycallback_url
            if ""~=url then
                local allurl = url .."?type=1&userid="..faceRegResult.UserIDStr.."&ip="..p_net.g_ip_minna.."&imagepath="..imagePath
                    .."&devicekey="..PX2_OPENCVM:GetFaceDeviceID().."&act=faceidentify"
                local curlObj = CurlObj:NewThread()
                curlObj:Get(allurl, "identifyCallback", self._scriptControl)
            end

            p_net._g_net:_send_minna_face_identify(faceRegResult.UserIDStr, name)
        elseif "faceidentifyreset"==str then
            myself._frameIdentify:Show(false)

            p_net._g_net:_send_minna_face_reset()
        elseif "SlamClearMap"==str then
            myself:_SlamClearMap(str1)
        elseif "SlamSaveMap"==str then
            myself:_SlamSaveMap(str1)
        elseif "SlamLoadMap"==str then
            myself:_SlamLoadMap(str1)
        elseif "hotcamera"==str then
            myself:_UseHotCamera("1" == str1)
        elseif "ipcamera"==str then
            myself:_UseIPCamera("1" == str1)
        end
    end)
end
-------------------------------------------------------------------------------
function p_video:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_video:OnInitUpdate")

    print("ListCameraDevices")
    PX2_OPENCVM:ListCameraDevices()
    local numDevices = PX2_OPENCVM:GetNumListCameraDevices()
    for i=0, numDevices-1, 1 do
        local camdev = PX2_OPENCVM:GetListCameraDevice(i)
        local idx = camdev.Index
        local devName = camdev.DeviceName
        local devPath = camdev.DevicePath

        print("idx:"..idx)
        print("devName:"..devName)
        print("devPath:"..devPath)

        if self._isRefreshCameraCVID then
            if "USB Camera RGB"==devName or "KS2A418"==devName then
                self._cvidCamera0 = idx
            elseif "USB Camera"==devName then
                self._cvidCamera1 = idx
            end
        end
    end

    PX2_OPENCVM:SetScriptCallback("_OnOpenCVCallback", self._scriptControl)

    local strShow = PX2_PROJ:GetConfigInt("p_video_showapriltag", 0)
    local apShow = Utils.IS2B(strShow)
    print_i_b(apShow)
    g_manykit._isShowAprilTag = apShow

    self:_RegistPropertyOnSetting()

    PX2_OPENCVM:CalGetGroupListVec()
    local numGroups = PX2_OPENCVM:GetNumGroups()
    if 0==numGroups then
        PX2_OPENCVM:GroupAdd("manykit")
    end

    PX2_APPSERVER:AddScriptHandler("_OnServerCallback", self._scriptControl)

    if g_manykit._systemControlMode==1 then
        coroutine.wrap(function()
            sleep(4.0)
            self:_OpenCameras()
            sleep(2.0)	
            self:_UseRtsp(self._isRtsp)
            self:_UseRtmp(self._isRtmp)
            sleep(2.0)
            local strOpen = PX2_PROJ:GetConfigInt("p_video_openapriltag")
            local apOpen = Utils.IS2B(strOpen)
            if apOpen then
                self:_OpenGunDetect(apOpen)
            end

            self:_ShowAprilTag(apShow)
        end)()
    else
        coroutine.wrap(function()
            sleep(4.0)
            self:_OpenCameras()
            sleep(2.0)
            self:_UseRtsp(self._isRtsp)
            self:_UseRtmp(self._isRtmp)
            sleep(2.0)
            local strOpen = PX2_PROJ:GetConfigInt("p_video_openapriltag")
            local apOpen = Utils.IS2B(strOpen)
            if apOpen then
                self:_OpenGunDetect(apOpen)
            end
            self:_ShowAprilTag(apShow)
        end)()
    end
end
-------------------------------------------------------------------------------
function p_video:_OpenCameras()
	local numCameraPreCreate = PX2_OPENCVM:GetNumCVCameraObjPreCreate()
	for i=0, numCameraPreCreate-1, 1 do
		local cvObj = PX2_OPENCVM:GetCVCameraObjPreCreate(i)

		local cvType = cvObj.TheVCType
		print("cvType:"..cvType)

		local useage = cvObj.Useage

		if "slam"==useage then
			cvObj:Open()
		elseif "irgun"==useage then
			cvObj:Open()
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_UseHotCamera(use)
    print(self._name.." p_video:_UseHotCamera")

	coroutine.wrap(function()
		local numCameraPreCreate = PX2_OPENCVM:GetNumCVCameraObjPreCreate()
		for i=0, numCameraPreCreate-1, 1 do
			local cvObj = PX2_OPENCVM:GetCVCameraObjPreCreate(i)
			local cvType = cvObj.TheVCType
			if cvType==CVCameraObjBase.VCT_HOTCAMERA then
				if use then
					cvObj:Open()
					sleep(2.0)
					cvObj:SetPattleType(CVCameraObjBase.PT_IRONBOW)
				else
					cvObj:Close()
				end
			end
		end
	end)()
end
-------------------------------------------------------------------------------
function p_video:_UseIPCamera(use)
    print(self._name.." p_video:_UseIPCamera")

	local numCameraPreCreate = PX2_OPENCVM:GetNumCVCameraObjPreCreate()
	for i=0, numCameraPreCreate-1, 1 do
		local cvObj = PX2_OPENCVM:GetCVCameraObjPreCreate(i)
		local cvType = cvObj.TheVCType

		print("1111111111111111111111")
		print(cvType)

		if cvType==CVCameraObjBase.VCT_URL or cvType==CVCameraObjBase.VCT_URLFFMPEG then
			if use then
				print("http://192.168.6.56:8080000000000000000000000000000")
				cvObj:SetURLFile("http://127.0.0.1:8081")
				cvObj:Open(true)
			else
				cvObj:Close()
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_Cleanup()
	print(self._name.." p_video:_Cleanup")
	PX2_OPENCVM:SetScriptCallback("", nil)

	PX2_OPENCVM:TerminateFace()
end

function p_video:OnPPlay()
	print(self._name.." p_video:OnPPlay")
end

function p_video:OnPUpdate()
	self:_OnPUpdate()
end
-------------------------------------------------------------------------------
function p_video:_CreateContentFrame()
	print(self._name.." p_video:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frame:AttachChild(frame)
	frame:LLY(-20.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    local picBoxCamera0 = UIFPicBox:New("FPicBoxCamera0")
	self._fPicBoxCamera0 = picBoxCamera0
    frame:AttachChild(picBoxCamera0)
	picBoxCamera0:LLY(-1.0)
    picBoxCamera0:SetAnchorHor(0.0, 1.0)
    picBoxCamera0:SetAnchorVer(0.0, 1.0)
    picBoxCamera0:GetUIPicBox():SetMaterialType(UIPicBox.MT_NIGHT)
	picBoxCamera0:GetUIPicBox():SetNightParamControl(Float4(0.5, 0.5, 1.0, 0) )
	picBoxCamera0:SetBrightness(1.0)
	picBoxCamera0:SetColor(Float3.WHITE)
	picBoxCamera0:Show(self._isShow0)

	local picBoxCamera1 = UIFPicBox:New("FPicBoxCamera1")
	self._fPicBoxCamera1 = picBoxCamera1
    frame:AttachChild(picBoxCamera1)
	picBoxCamera1:LLY(-2.0)
    picBoxCamera1:SetAnchorHor(0.0, 1.0)
    picBoxCamera1:SetAnchorVer(0.0, 1.0)
    picBoxCamera1:GetUIPicBox():SetMaterialType(UIPicBox.MT_NIGHT)
	picBoxCamera1:GetUIPicBox():SetNightParamControl(Float4(0.5, 1.0, 1.0, 0) )
	picBoxCamera1:SetBrightness(1.0)
	picBoxCamera1:SetColor(Float3.WHITE)
	picBoxCamera1:Show(self._isShow1)

	local picBoxCamera2 = UIFPicBox:New("FPicBoxCamera2")
	self._fPicBoxCamera2 = picBoxCamera2
    frame:AttachChild(picBoxCamera2)
	picBoxCamera2:LLY(-2.0)
    picBoxCamera2:SetAnchorHor(0.0, 1.0)
    picBoxCamera2:SetAnchorVer(0.0, 1.0)
    picBoxCamera2:GetUIPicBox():SetMaterialType(UIPicBox.MT_NIGHT)
	picBoxCamera2:GetUIPicBox():SetNightParamControl(Float4(0.5, 1.0, 1.0, 0) )
	picBoxCamera2:SetBrightness(1.0)
	picBoxCamera2:SetColor(Float3.WHITE)
	picBoxCamera2:Show(self._isShow2)

	local btnSetting = UIButton:New("BtnList")
	frame:AttachChild(btnSetting)
	btnSetting:LLY(-3.0)
	btnSetting:SetAnchorHor(0.0, 0.0)
	btnSetting:SetAnchorVer(1.0, 1.0)
	btnSetting:SetAnchorParamHor(25.0, 25.0)
	btnSetting:SetAnchorParamVer(-25.0, -25.0)
	btnSetting:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
	btnSetting:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/setting.png")
	btnSetting:SetScriptHandler("_UICallback", self._scriptControl)

	local uiFrameBack = self:_CreateMgrFrame()
	frame:AttachChild(uiFrameBack)
	uiFrameBack:LLY(-10)
	uiFrameBack:Show(false)
	self._frameMgr = uiFrameBack

	local frameIdentify = self:_CreateFrameIdentify()
	self._frameIdentify = frameIdentify
	frame:AttachChild(frameIdentify)
	frameIdentify:LLY(-5)
	frameIdentify:SetAnchorHor(0.0, 1.0)
	frameIdentify:SetAnchorVer(0.0, 0.0)
	frameIdentify:SetAnchorParamHor(10.0, -10.0)
	frameIdentify:SetAnchorParamVer(10.0, 0.0)
	frameIdentify:SetPivot(0.5, 0.0)
	frameIdentify:SetHeight(200.0)
	frameIdentify:Show(false)

	self:_Show0(self._isShow0)
	self:_Show1(self._isShow1)
	self:_Show2(self._isShow2)

	self._scriptControl:ResetPlay()
end
-------------------------------------------------------------------------------
function p_video:imgregCallback(ptr)
	local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
        local strMem = curlObj:GetGettedString()
        print("strMem:")
        print(strMem)
	end
end
-------------------------------------------------------------------------------
function p_video:identifyCallback(ptr)
	local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
        local strMem = curlObj:GetGettedString()
        print("strMem:")
        print(strMem)
	end
end
-------------------------------------------------------------------------------
function p_video:_OnServerCallback(ptr, t, clientstr, data)
	if t=="/requestdata" then
		print("requestdata")
        --print("clientstr:"..clientstr)
        --print("data:"..data)

        local tab = PX2JSon.decode(data)

        local type = tab.type
        print("type:")
		print(type)

        local dt = tab.data
        print("dt:")
        print(dt)

        if "getdevicekey"==type then
			local faceDeviceID = PX2_OPENCVM:GetFaceDeviceID()
            PX2_APPSERVER:SetHttpResult(faceDeviceID)
        elseif "deletepeople"==type then
            PX2_OPENCVM:UserDelete(dt, "manykit")
            PX2_APPSERVER:SetHttpResult("deletepeople")
        elseif "deletepeopleall"==type then
            PX2_OPENCVM:DeleteGroupAllUser("manykit")
            PX2_APPSERVER:SetHttpResult("deletepeopleall")
        elseif "createpeople"==type then
            local dtjson = PX2JSon.decode(dt)
            local id = dtjson.id
            local name = dtjson.name
            print("id:"..id)
            print("name:"..name)
        elseif "faceregist"==type then
            local dtjson = PX2JSon.decode(dt)
            local id = dtjson.id
            local name = dtjson.name
            local faceid = dtjson.faceid
            local image = dtjson.image

            PX2_OPENCVM:ThreadUserAddJob(image, id, name, faceid)
		elseif "takephoto"==type then
			self._istakingphoto = true
			self._takingphotouserid = dt
			PX2_APPSERVER:SetHttpResult("takephoto")
		elseif "setimgregcallback"==type then
			self._imgregcallback_url = dt
			print("self._imgregcallback_url:"..self._imgregcallback_url)

		elseif "setidentifycallback"==type then
			self._identifycallback_url = dt
			print("self._identifycallback_url:"..self._identifycallback_url)

		elseif "setheartcallback"==type then
			self._heartcallback_url = dt
			print("self._heartcallback_url:"..self._heartcallback_url)
		elseif "stt"==type then
			PX2_APPSERVER:SetHttpResult("123aaa")
        end
	end
end
-------------------------------------------------------------------------------
function p_video:_RefreshGroupFaces()
	local itemSel = self._setting_ListGroup:GetSelectedItem()
	if nil~=itemSel then
		local group = itemSel:GetUserDataString("group")
		self:_RefreshGroup(group)
		self:_RegistPropertyOnUser("")
	end
end
-------------------------------------------------------------------------------
function p_video:_DeleteCurSelectFace()
	print(self._name.." p_info:_DeleteCurSelectFace")

	local itemSel = self._setting_ListFace:GetSelectedItem()
	if nil~=itemSel then
		local userid = itemSel:GetUserDataString("userid")
		PX2_OPENCVM:UserDelete(userid, "manykit")
	end
end
-------------------------------------------------------------------------------
function p_video:_AddFace(name)
	print(self._name.." p_info:_AddFace")
	print("name:"..name)

	if ""~=name then
		if self._identifyUseIndex==0 or self._identifyUseIndex==1 then
			local itemSelectGroup = self._setting_ListGroup:GetSelectedItem()
			if itemSelectGroup then
				local group = itemSelectGroup:GetUserDataString("group")
				print("group:"..group)

				local userid = PX2_IDM:GetNextID("NextFaceID", self._nextFaceID)
				PX2_PROJ:SetConfig("NextFaceID", userid)

				local cfgName = PX2_OPENCVM:GetConfigName()	
				local pathParent = ResourceManager:GetWriteablePath() .. "Write_" .. cfgName .. "/"
				local pathFolder = pathParent .. "face/"
				if not PX2_RM:IsFileFloderExist(pathFolder) then
					PX2_RM:CreateFloder(pathParent, "face/")
				end
				local savepath = pathFolder .. userid..".png"
				PX2_OPENCVM:CaptureImageToFile(self._identifyUseIndex, savepath)

				PX2_RM:ClearRes(savepath)
				local texObj = PX2_RM:BlockLoad(savepath)
				local tex2D = Cast:ToTexture2D(texObj)
				if tex2D then
					PX2_OPENCVM:UserAdd(tex2D, ""..userid, group, name)
					PX2_APP:SetConfig(self._mkdir, "userinfo", userid, name)

					self:_RefreshGroupFaces()
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)

	elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

		if "BtnDlgClose"==name then
			self:_ShowSetting(false)
		elseif "BtnList"==name then
			self:_ShowSetting(true)
		elseif "BtnObjectOption"==name then
			local useage = obj:GetUserDataString("useage")
			if "add"==useage then
				local text = self._editboxName:GetText()
				if ""~=text then
					self:_AddFace(text)
				end
			elseif "delete"==useage then
				self:_DeleteCurSelectFace()
				self:_RefreshGroupFaces()
			end
		end
	elseif UICT_RELEASED_NOTPICK == callType then
        PX2_GH:PlayNormal(obj)

	elseif UICT_LIST_SELECTED == callType then
		if "ListGroup"==name then
            local itemSel = obj:GetSelectedItem()
            if nil~=itemSel then
                local group = itemSel:GetUserDataString("group")
				self:_RefreshGroup(group)
				self:_RegistPropertyOnUser("")
            end
		elseif "ListFace"==name then
			local itemSel = obj:GetSelectedItem()
            if nil~=itemSel then
				local userid = itemSel:GetUserDataString("userid")
				local name = PX2_APP:GetConfig(self._mkdir, "userinfo", userid)
				print("name:"..name)

				self:_RegistPropertyOnUser(userid)
			end
		end
	elseif UICT_PROPERTY_CHANGED==callType then
        print("UICT_PROPERTY_CHANGED "..name)
        if "PropertyGridEdit"==name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)

            if "IsShow0"==pObj.Name then
				local isShow0 =  pObj:PBool()
				self._isShow0 = isShow0
				PX2_PROJ:SetConfig("pvideo_isshow0", Utils.B2IS(isShow0))
				self:_Show0(isShow0)
			elseif "IsShow1"==pObj.Name then
				local isShow1 =  pObj:PBool()
				self._isShow1 = isShow1
				PX2_PROJ:SetConfig("pvideo_isshow1", Utils.B2IS(isShow1))
				self:_Show1(isShow1)
			elseif "IsShow2"==pObj.Name then
				local isShow2 =  pObj:PBool()
				self._isShow2 = isShow2
				PX2_PROJ:SetConfig("pvideo_isshow2", Utils.B2IS(isShow2))
				self:_Show2(isShow2)
			elseif "IsUseFaceIdentify"==pObj.Name then
				local isUseFaceIdentify = pObj:PBool()
				self._isUseFaceIdentify = isUseFaceIdentify	
				PX2_PROJ:SetConfig("face_isusefaceidentify", Utils.B2IS(isUseFaceIdentify))
				self:_UseFaceIdentify(isUseFaceIdentify)
			elseif "IdentifyUseIndex"==pObj.Name then
				self._identifyUseIndex = pObj:PInt()
				PX2_PROJ:SetConfig("face_identifyUseIndex", self._identifyUseIndex)
			elseif "IdentifyScore"==pObj.Name then
				self._identifyScore = pObj:PFloat()
				PX2_PROJ:SetConfig("face_identifyScore", ""..self._identifyScore)
				PX2_OPENCVM:SetIdentifyScore(self._identifyScore)
			elseif "IdentifySamePeopleTime"==pObj.Name then
				self._identifySamePeopleTime = pObj:PEnumData2Float()
				self._identifySamePeopleTimeIndex = pObj:PInt()

				print("self._identifySamePeopleTime:"..self._identifySamePeopleTime)

				PX2_PROJ:SetConfig("face_identifySamePeopleTimeIndex", ""..self._identifySamePeopleTimeIndex)
				PX2_PROJ:SetConfig("face_identifySamePeopleTime", ""..self._identifySamePeopleTime)
			elseif "IsRtsp"==pObj.Name then
				local isRtsp = pObj:PBool()
				print("IsRtsp")
				print_i_b(isRtsp)
				PX2_PROJ:SetConfig("video_isrtsp", Utils.B2IS(isRtsp))

				self:_UseRtsp(isRtsp)
			elseif "IsRtmp"==pObj.Name then
				local isRtmp = pObj:PBool()
				print("IsRtmp:")
				print_i_b(isRtmp)
				PX2_PROJ:SetConfig("video_isrtmp", Utils.B2IS(isRtmp))

				if isRtmp then
					PX2_OPENCVM:StopRtmpPublisher()
				end

				self:_UseRtmp(isRtmp)
			elseif "IPRtmpTo"==pObj.Name then
				local ipindexrtmp = pObj:PInt()

				self._ipindex_rtmp = ipindexrtmp
				self._ip_rtmp = pObj:PEnumData2()

				print("iprtmpindex:"..ipindexrtmp)
				PX2_PROJ:SetConfig("ipindex_rtmp", ipindexrtmp)

			elseif "CameraKey"==pObj.Name then
				local cameraKey = pObj:PString()
				print("cameraKey:"..cameraKey)

				self._cameraKey = cameraKey

				PX2_PROJ:SetConfig("video_camerakey", cameraKey)

			elseif "IsOpenAprilTag"==pObj.Name then
				local isOpenAprilTag = pObj:PBool()
				print("isOpenAprilTag:")
				print_i_b(isOpenAprilTag)

				self:_OpenGunDetect(isOpenAprilTag)
			elseif "AprilTagType"==pObj.Name then
				local apt = pObj:PInt()
				print("apt:"..apt)
				print_i_b(apt)
				self._aprilTagType = apt
				PX2_PROJ:SetConfig("AprilTagType", ""..self._aprilTagType)

				self:_OpenGunDetect(self._isOpenAprilTag)
			elseif "IsShowAprilTag"==pObj.Name then
				local isShowAprilTag = pObj:PBool()
				print("IsShowAprilTag:")
				print_i_b(isShowAprilTag)

				self:_ShowAprilTag(isShowAprilTag)
			elseif "AprilTagSize"==pObj.Name then
				local ats = pObj:PFloat()
				self._aprilTagSize = ats
				PX2_PROJ:SetConfig("AprilTagSize", ""..ats)

			elseif "AprilTagScale"==pObj.Name then
				local ats = pObj:PFloat()
				self._aprilTagScale = ats
				PX2_PROJ:SetConfig("AprilTagScale", ""..ats)						

				local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
				if cvCamObj then
					cvCamObj:SetAprilTagDetectScale(self._aprilTagScale)
				end

			elseif "AprilTagLight"==pObj.Name then
				local ats = pObj:PFloat()
				self._aprilTagLight = ats
				PX2_PROJ:SetConfig("AprilTagLight", ""..ats)						

				local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
				if cvCamObj then
					cvCamObj:SetAprilTagDetectLight(self._aprilTagLight)
				end
			elseif "AprilTagThresh"==pObj.Name then
				local ats = pObj:PFloat()
				self._aprilTagThresh = ats
				PX2_PROJ:SetConfig("AprilTagThresh", ""..ats)

				local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
				if cvCamObj then
					cvCamObj:SetAprilTagDetectIRThresh(self._aprilTagThresh)
				end
			elseif "AprilTagAlpha"==pObj.Name then
				local ats = pObj:PFloat()
				self._aprilTagAlpha = ats
				PX2_PROJ:SetConfig("AprilTagAlpha", ""..ats)						

				local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
				if cvCamObj then
					cvCamObj:SetAprilTagDetectAlpha(self._aprilTagAlpha)
				end
			elseif "AprilTagRect"==pObj.Name then
				local recV = pObj:PFloat4()
				self._aprilRectFloat4 = recV
				PX2_PROJ:SetConfig("AprilTagRect", ""..self._aprilRectFloat4:ToString())

				local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
				if cvCamObj then
					cvCamObj:SetAprilTagDetectRect(Rectf(recV:X(), recV:Y(), recV:Z(), recV:W()))
				end
			elseif "WeaponIPIndex"==pObj.Name then
				local idx = pObj:PInt()
				self._weaponIPIndex = idx
				if 0==idx then
					p_net._g_ip_weapontrigger = "192.168.6.51"
				elseif 1==idx then
					p_net._g_ip_weapontrigger = "192.168.6.52"
				elseif 2==idx then
					p_net._g_ip_weapontrigger = "192.168.6.53"
				elseif 3==idx then
					p_net._g_ip_weapontrigger = "192.168.6.54"
				elseif 4==idx then
					p_net._g_ip_weapontrigger = "192.168.6.55"
				elseif 5==idx then
					p_net._g_ip_weapontrigger = "192.168.6.56"
				end
				PX2_PROJ:SetConfig("p_video_weaponipindex", idx)
			elseif "SaveMap"==pObj.Name then
				print("SaveMap")
				local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
				if cvCamObj then
					coroutine.wrap(function()
						cvCamObj:Close()
						sleep(2.0)
						cvCamObj:Open()
					end)()
				end
			elseif "LoadMap"==pObj.Name then
				print("LoadMap")
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_SlamClearMap(str1)
	print(self._name.." _SlamClearMap")

	local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
	if cvCamObj then
		coroutine.wrap(function()
			cvCamObj:Close()
			sleep(3.0)
			local f = File("./slam/map.bin")
			f:Delete()
			local f1 = File("./slam/map.ply")
			f1:Delete()
			sleep(2.0)
			cvCamObj:Open()
		end)()
	end
end
-------------------------------------------------------------------------------
function p_video:_SlamSaveMap(str1)
	print(self._name.." _SlamSaveMap")

	local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
	if cvCamObj then
		coroutine.wrap(function()
			cvCamObj:Close()
			sleep(2.0)

			if str1 == "cloud" then
				local curlObj = CurlObj:NewThread()
				local url = p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/people/uploadslam"
				print("url:"..url)

				local f = "./slam/map.bin"
				local f1 = "./slam/map.ply"
				local curl = CurlObj:NewThread()
				curl:SetUserDataString("f", f)
				curl:PostFile(url, f, "_slamUploadCallback", self._scriptControl)
				sleep(0.5)
				local curl1 = CurlObj:NewThread()
				curl1:SetUserDataString("f", f1)
				curl1:PostFile(url, f1, "_slamUploadCallback", self._scriptControl)
				sleep(2.0)
			end
			cvCamObj:Open()
		end)()
	end
end
-------------------------------------------------------------------------------
function p_video:_SlamLoadMap(str1)
	print(self._name.." _SlamSaveMap")

	self._isSlamMapBinOK = false
	self._isSlamMapPlyOK = false

	local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
	if cvCamObj then
		coroutine.wrap(function()
			cvCamObj:Close()
			sleep(3.0)
			local f = File("./slam/map.bin")
			f:Delete()
			local f1 = File("./slam/map.ply")
			f1:Delete()
			sleep(1.0)

			local curlObj = CurlObj:NewThread()
			local url = p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/people/upload/slammap/map.bin"
			print("url:"..url)
			local fp = "./slam/map.bin"
			local curlSlamDownLoad = CurlObj:NewThread("SlamDownload")
			curlSlamDownLoad:SetUserDataString("f", fp)
			curlSlamDownLoad:Download(url, fp, "_slamDownloadCallback", self._scriptControl)

			local url1 = p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/people/upload/slammap/map.ply"
			print("url1:"..url1)
			local fp1 = "./slam/map.ply"
			local curlSlamDownLoad1 = CurlObj:NewThread("SlamDownload1")
			curlSlamDownLoad1:SetUserDataString("f", fp1)
			curlSlamDownLoad1:Download(url1, fp1, "_slamDownloadCallback", self._scriptControl)
		end)()
	end
end
-------------------------------------------------------------------------------
function p_video:_slamUploadCallback(ptr)    
    local curlObj = Cast:ToO(ptr)
    local progress = curlObj:GetGettedProgress()
	local filename = curlObj:GetUserDataString("f")

	local iProj = progress * 100
    print(filename.." upload:"..iProj)

    if curlObj:IsGettedOK() then
		print(filename.." upload ok")
    end
end
-------------------------------------------------------------------------------
function p_video:_slamDownloadCallback(ptr)    
    local curlObj = Cast:ToO(ptr)
    local progress = curlObj:GetGettedProgress()
	local filename = curlObj:GetUserDataString("f")

	local iProj = progress * 100
    print(filename.." download:"..iProj)

    if curlObj:IsGettedOK() then
		print(filename.." download ok")

		self:_CheckSlamDownload(filename)
    end
end
-------------------------------------------------------------------------------
function p_video:_CheckSlamDownload(filename)
	print(self._name.." _CheckSlamDownload")

	if filename=="./slam/map.bin" then
		self._isSlamMapBinOK = true
	end
	if filename=="./slam/map.ply" then
		self._isSlamMapPlyOK = true
	end

	if self._isSlamMapBinOK and self._isSlamMapPlyOK then
		local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
		if cvCamObj then
			coroutine.wrap(function()
				sleep(0.2)
				cvCamObj:Open()
			end)()
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_Show0(s)
	print(self._name.." _Show0")
	print_i_b(s)

	self._fPicBoxCamera0:Show(s)

	self:_CheckShow()
end
-------------------------------------------------------------------------------
function p_video:_Show1(s)
	print(self._name.." _Show1")
	print_i_b(s)

	self._fPicBoxCamera1:Show(s)

	self:_CheckShow()
end
-------------------------------------------------------------------------------
function p_video:_Show2(s)
	print(self._name.." _Show2")
	print_i_b(s)

	self._fPicBoxCamera2:Show(s)

	self:_CheckShow()
end
-------------------------------------------------------------------------------
function p_video:_CheckShow()
	print(self._name.." _CheckShow")

	local showObjs = {}

	local numShow = 0
	local numShow0 = self._fPicBoxCamera0:IsShow()
	if numShow0 then
		numShow = numShow + 1
		table.insert(showObjs, self._fPicBoxCamera0)
	end
	local numShow1 = self._fPicBoxCamera1:IsShow()
	if numShow1 then
		numShow = numShow + 1
		table.insert(showObjs, self._fPicBoxCamera1)
	end
	local numShow2 = self._fPicBoxCamera2:IsShow()
	if numShow2 then
		numShow = numShow + 1
		table.insert(showObjs, self._fPicBoxCamera2)
	end

	print("numShow:"..numShow)

	if numShow > 0 then
		local showstep = 1.0/(numShow*1.0)
		local st = 0.0
		for k,v in ipairs(showObjs) do

			v:SetAnchorHor(st, st + showstep)
			v:SetAnchorVer(0.0, 1.0)

			st = st + showstep
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_UseFaceIdentify(use)
	if use then
		PX2_OPENCVM:InitlizeFace()
	else
		PX2_OPENCVM:TerminateFace()
	end
end
-------------------------------------------------------------------------------
function p_video:_RefreshGroup(groupstr)
	PX2_OPENCVM:CalGetUserList(groupstr)

	self._setting_ListFace:RemoveAllItems()

	local numUsers = PX2_OPENCVM:GetNumUsers()
	for i=0, numUsers-1, 1 do
		local userid = PX2_OPENCVM:GetUser(i)
		local item = self._setting_ListFace:AddItem(userid)
		
		PX2_OPENCVM:CalGetUserInfo(userid, groupstr)
		local fuserinfo = PX2_OPENCVM:GetFirstUserInfo()

		item:SetUserDataString("userid", userid)
		item:SetUserDataString("GroupID", fuserinfo.GroupID)
		item:SetUserDataString("CreateTime", fuserinfo.CreateTime)
	end
end
-------------------------------------------------------------------------------
function p_video:_ShowSetting(show)
	print("p_video:_ShowSetting")
	print_i_b(show)

	self._frameMgr:Show(show)

	if show then
		self._setting_ListGroup:RemoveAllItems()

		if self._setting_DeviceID then
			local faceDeviceID = PX2_OPENCVM:GetFaceDeviceID()
			local isFaceInitOK = PX2_OPENCVM:IsFaceInitOK()
			self._setting_DeviceID:GetText():SetText("人脸设备ID:"..faceDeviceID)
			if isFaceInitOK then
				self._setting_DeviceID:GetText():SetColor(Float3.GREEN)
			else
				self._setting_DeviceID:GetText():SetColor(Float3(0.2, 0.2, 0.2))
			end
		end

		if self._setting_InfoText then
			local numFace = PX2_OPENCVM:DBFaceCount()
			self._setting_InfoText:GetText():SetText("人脸数量:"..numFace)
		end

		PX2_OPENCVM:CalGetGroupListVec()
		local numGroups = PX2_OPENCVM:GetNumGroups()
		for i=0, numGroups-1, 1 do
			local gpstr = PX2_OPENCVM:GetGroup(i)
			local item = self._setting_ListGroup:AddItem(gpstr)
			item:SetUserDataString("group", gpstr)
		end

		self:_RegistPropertyOnSetting()
	end
end
-------------------------------------------------------------------------------
function p_video:_CreateMgrFrame()
	local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "")
	self._frameMgr = uiFrameBack
	btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local frameTable = UITabFrame:New("TabFrameInfo")
    uiFrame:AttachChild(frameTable)
    frameTable:AddTab("Setting", ""..PX2_LM_APP:V("Setting"), self:_CreateFrameSetting())
	frameTable:AddTab("Face", ""..PX2_LM_APP:V("Face"), self:_CreateFrameFace())
    frameTable:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessTable(frameTable)
    frameTable:SetActiveTab("Setting")

	return uiFrameBack
end
-------------------------------------------------------------------------------
function p_video:_CreateFrameIdentify()
	local frame = UIFrame:New()
	local back = frame:CreateAddBackgroundPicBox()
	back:UseAlphaBlend(true)
	back:SetColor(Float3(0.1, 0.1, 0.1))
	back:SetAlpha(0.4)

	local fText = UIFText:New()
	self._fTextIdentifyName = fText
	frame:AttachChild(fText)
	fText:LLY(-1)
	fText:SetAnchorHor(0.0, 0.5)
	fText:SetAnchorVer(0.0, 1.0)
	fText:GetText():SetText("你好")
	fText:GetText():SetFontSize(64)
	
	return frame
end
-------------------------------------------------------------------------------
function p_video:_ShowIdentifyFrame(name)
	self._fTextIdentifyName:GetText():SetText(""..name)
	self._frameIdentify:Show(true)
end
-------------------------------------------------------------------------------
function p_video:_CreateMapToolMapEdit()
    local frameTool = UIFrame:New()
    frameTool:SetPickOnlyInSizeRange(false)

    local btnSZ = 35.0
    local tmp = 1.0
    local posH1 = g_manykit._hBtn * 0.5
    for i=0,1,1 do
        local btnAdj = UIButton:New("BtnObjectOption")
        frameTool:AttachChild(btnAdj)
        btnAdj:LLY(-1.0)
        btnAdj:SetAnchorHor(0.0, 0.0)
        btnAdj:SetAnchorParamHor(posH1, posH1)
        btnAdj:SetAnchorVer(0.5, 0.5)
        btnAdj:SetSize(btnSZ, btnSZ)
        btnAdj:SetScriptHandler("_UICallback", self._scriptControl)

        local fText= btnAdj:CreateAddFText(txt)
        fText:GetText():SetFontScale(1.0)
        
        local txt = ""
        local useage = ""
        if 0==i then
			txt = "删除"
            useage = "delete"
            fText:GetText():SetFontScale(0.8)     
		elseif 1==i then
            txt = "增加"
            useage = "add"
            fText:GetText():SetFontScale(0.8)   
        end

        fText:GetText():SetText(txt)
        btnAdj:SetUserDataString("useage", useage)

        manykit_uiProcessBtn(btnAdj)

		if "add"==useage then
			btnAdj:SetStateColor(UIButtonBase.BS_NORMAL, Float3(0.0, 0.0, 0.5))
            btnAdj:SetStateColor(UIButtonBase.BS_PRESSED, Float3(0.0, 0.0, 0.5))
            btnAdj:SetStateColor(UIButtonBase.BS_HOVERED, Float3(0.0, 0.0, 0.5))
		elseif "delete"==useage then
            btnAdj:SetStateColor(UIButtonBase.BS_NORMAL, Float3(0.5, 0.0, 0.0))
            btnAdj:SetStateColor(UIButtonBase.BS_PRESSED, Float3(0.5, 0.0, 0.0))
            btnAdj:SetStateColor(UIButtonBase.BS_HOVERED, Float3(0.5, 0.0, 0.0))
        end

        posH1 = posH1 + btnSZ + tmp
    end

    local uiEditName = UIEditBox:New("EditBoxUserName")
	self._editboxName = uiEditName
	frameTool:AttachChild(uiEditName)
	uiEditName:LLY(-2.0)
	uiEditName:SetAnchorHor(0.0, 0.0)
	uiEditName:SetAnchorParamHor(80.0, 80.0)
	uiEditName:SetAnchorVer(0.0, 1.0)
	uiEditName:SetAnchorParamVer(5, -5)
	uiEditName:SetPivot(0.0, 0.5)
	uiEditName:SetWidth(200.0)
	uiEditName:GetBackFPicBox():SetColor(Float3(0.7, 0.7, 0.7))

    return frameTool
end
-------------------------------------------------------------------------------
function p_video:_CreateFrameFace()
	local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

	local frameTool = self:_CreateMapToolMapEdit()
	uiFrame:AttachChild(frameTool)
	frameTool:SetAnchorHor(0.0, 1.0)
	frameTool:SetAnchorVer(1.0, 1.0)
	frameTool:SetAnchorParamHor(4.0, -4.0)
	frameTool:SetAnchorParamVer(-25.0, -25.0)
	frameTool:CreateAddBackgroundPicBox()
	frameTool:SetHeight(38.0)

	local pv = -60.0

	local fTextDeviceID = UIFText:New()
	self._setting_DeviceID = fTextDeviceID
	uiFrame:AttachChild(fTextDeviceID)
	fTextDeviceID:LLY(-1.0)
	fTextDeviceID:SetAnchorHor(0.0, 1.0)
	fTextDeviceID:SetAnchorParamHor(5.0, 0.0)
	fTextDeviceID:SetAnchorVer(1.0, 1.0)
	fTextDeviceID:SetAnchorParamVer(pv, pv)
	fTextDeviceID:SetPivot(0.0, 0.5)
	fTextDeviceID:SetSize(0.0, 80)
    fTextDeviceID:GetText():SetText("")
    fTextDeviceID:GetText():SetFontColor(Float3.WHITE)
	fTextDeviceID:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)

	pv = pv - 20.0

    local fText = UIFText:New()
	self._setting_InfoText = fText
	uiFrame:AttachChild(fText)
	fText:LLY(-1.0)
	fText:SetAnchorHor(0.0, 1.0)
	fText:SetAnchorParamHor(5.0, 0.0)
	fText:SetAnchorVer(1.0, 1.0)
	fText:SetAnchorParamVer(pv, pv)
	fText:SetPivot(0.0, 0.5)
	fText:SetSize(0.0, 80)
    fText:GetText():SetText("")
    fText:GetText():SetFontColor(Float3.WHITE)
	fText:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)

	pv = pv - 40.0

	-- 分组
	local text0 = UIFText:New()
    uiFrame:AttachChild(text0)
    text0:LLY(-2.0)
    text0:SetAnchorHor(0.0, 0.25)
    text0:SetAnchorParamHor(5.0, -5.0)
    text0:SetAnchorVer(1.0, 1.0)
    text0:SetAnchorParamVer(pv, pv)
    text0:SetHeight(30.0)
    text0:SetPivot(0.5, 0.0)
    text0:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    text0:GetText():SetText("分组")
    text0:GetText():SetFontColor(Float3.WHITE)

	local listGroup = UIList:New("ListGroup")
	self._setting_ListGroup = listGroup
    uiFrame:AttachChild(listGroup)
    listGroup:LLY(-2.0)
    listGroup:SetAnchorHor(0.0, 0.25)
    listGroup:SetAnchorVer(0.0, 1.0)
    listGroup:SetAnchorParamHor(5.0, -5.0)
    listGroup:SetAnchorParamVer(5.0, pv)
    listGroup:SetReleasedDoSelect(true)
    listGroup:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(listGroup)

	-- 人脸
	local text1 = UIFText:New()
    uiFrame:AttachChild(text1)
    text1:LLY(-2.0)
    text1:SetAnchorHor(0.25, 0.5)
    text1:SetAnchorParamHor(5.0, -5.0)
    text1:SetAnchorVer(1.0, 1.0)
    text1:SetAnchorParamVer(pv, pv)
    text1:SetHeight(30.0)
    text1:SetPivot(0.5, 0.0)
    text1:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    text1:GetText():SetText("人脸")
    text1:GetText():SetFontColor(Float3.WHITE)

	local listFace = UIList:New("ListFace")
	self._setting_ListFace = listFace
    uiFrame:AttachChild(listFace)
    listFace:LLY(-2.0)
    listFace:SetAnchorHor(0.25, 0.5)
    listFace:SetAnchorVer(0.0, 1.0)
    listFace:SetAnchorParamHor(5.0, -5.0)
    listFace:SetAnchorParamVer(5.0, pv)
    listFace:SetReleasedDoSelect(true)
    listFace:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(listFace)

	local pg = UIPropertyGrid:New("PropertyGridFace")
    self._propertyGridUser = pg
    uiFrame:AttachChild(pg)
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.5, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
	pg:SetAnchorParamHor(5.0, -5.0)
	pg:SetAnchorParamVer(5.0, pv)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl) 
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)

	self:_RegistPropertyOnUser("")

	return uiFrame
end
-------------------------------------------------------------------------------
function p_video:_CreateFrameSetting()
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
-------------------------------------------------------------------------------
function p_video:_RegistPropertyOnSetting()
	self._scriptControl:RemoveProperties("EditSetting")
    self._scriptControl:BeginPropertyCata("EditSetting")

    self._scriptControl:AddPropertyClass("Video", "视频")

	self._scriptControl:AddPropertyInt("CVID0", "CVID0", self._cvidCamera0, false, false)
	self._scriptControl:AddPropertyInt("CVID1", "CVID1", self._cvidCamera1, false, false)

    self._scriptControl:AddPropertyBool("IsShow0", "显示0", self._isShow0)
	self._scriptControl:AddPropertyBool("IsShow1", "显示1", self._isShow1)
	self._scriptControl:AddPropertyBool("IsShow2", "显示2", self._isShow2)

	self._scriptControl:AddPropertyClass("Face", "人脸识别")

	self._scriptControl:AddPropertyBool("IsUseFaceIdentify", "启用", self._isUseFaceIdentify)

	PX2Table2Vector({"色彩", "灰度", "关闭"})
	self._scriptControl:AddPropertyEnum("IdentifyUseIndex", "识别相机", self._identifyUseIndex, PX2_GH:Vec(), true, false)

	self._scriptControl:AddPropertyFloat("IdentifyScore", "识别分数", self._identifyScore, true, false)

	PX2Table2Vector({"1", "2", "5", "10", "60", "600"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"1", "2", "5", "10", "60", "600"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("IdentifySamePeopleTime", "触发间隔", self._identifySamePeopleTimeIndex, vec, vec1, vec2, true, true)

	self._scriptControl:AddPropertyClass("Stream", "推拉流")
	local ipAdj = "http://127.0.0.1:8080;http://"..PX2_APP:GetIPAdjust()..":8080"
	self._scriptControl:AddPropertyString("UrlRtsp", "拉流地址", ipAdj, false, false)
	self._scriptControl:AddPropertyBool("IsRtsp", "启动拉流服务器", self._isRtsp, true, false)

	local ipindex_rtmpstr = PX2_PROJ:GetConfig("ipindex_rtmp")
	if ""~=ipindex_rtmpstr then
		self._ipindex_rtmp = StringHelp:StringToInt(ipindex_rtmpstr)
		if 0==self._ipindex_rtmp then
			self._ip_rtmp = "127.0.0.1"
		elseif 1==self._ipindex_rtmp then
			self._ip_rtmp = "192.168.6.10"
		elseif 2==self._ipindex_rtmp then
			self._ip_rtmp = "182.254.213.85"
		end
	end
	PX2Table2Vector({"127.0.0.1", "192.168.6.10", "182.254.213.85"})
	local vec = PX2_GH:Vec()
	PX2Table2Vector({"127.0.0.1", "192.168.6.10", "182.254.213.85"})
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData("IPRtmpTo", "IPRtmpTo", self._ipindex_rtmp, vec, vec1, vec2, true, false)	

	self._scriptControl:AddPropertyString("CameraKey", "推流Key", self._cameraKey, true, false)
	self._scriptControl:AddPropertyBool("IsRtmp", "启动推流", self._isRtmp, true, false)

	local aprilTagSizeStr = PX2_PROJ:GetConfig("AprilTagSize")
	if ""==aprilTagSizeStr then
		aprilTagSizeStr = "0.024"
		PX2_PROJ:SetConfig("AprilTagSize", aprilTagSizeStr)
	end
	self._aprilTagSize = StringHelp:StringToFloat(aprilTagSizeStr)

	local scale = PX2_PROJ:GetConfigFloat("AprilTagScale", 1.0)
	self._aprilTagScale = scale

	local alpha = PX2_PROJ:GetConfigFloat("AprilTagAlpha", 1.0)
	self._aprilTagAlpha = alpha

	local light = PX2_PROJ:GetConfigFloat("AprilTagLight", 0.0)
	self._aprilTagLight = light

	local th = PX2_PROJ:GetConfigFloat("AprilTagIRThreshold", 100.0)
	self._aprilTagIRThreshold = th

	self._aprilTagType = PX2_PROJ:GetConfigInt("AprilTagType", 0)

	local rectStr =  PX2_PROJ:GetConfig("AprilTagRect")
	if rectStr~="" then
		self._aprilRectFloat4 = Float4:SFromString(rectStr)
	end

	self._scriptControl:AddPropertyClass("SimuWeapon", "仿真武器")
	self._scriptControl:AddPropertyBool("IsOpenAprilTag", "是否开启", self._isOpenAprilTag, true, false)
	self._scriptControl:AddPropertyBool("IsShowAprilTag", "是否显示检测", g_manykit._isShowAprilTag, true, false)
	PX2Table2Vector({ "Tag16h5", "Tag36h11", "irgun"})
	self._scriptControl:AddPropertyEnum("AprilTagType", "类型", self._aprilTagType, PX2_GH:Vec(), true, false)
	self._scriptControl:AddPropertyFloat("AprilTagSize", "AprilTag大小", self._aprilTagSize, true, false)

	if 0==self._aprilTagType or 1==self._aprilTagType then
		self._scriptControl:AddPropertyFloatSlider("AprilTagScale", "AprilTag缩放", self._aprilTagScale,  1, 4, true, false)
		self._scriptControl:AddPropertyFloat("AprilTagSize", "AprilTag大小", self._aprilTagSize, true, false)
		self._scriptControl:AddPropertyFloatSlider("AprilTagScale", "AprilTag缩放", self._aprilTagScale,  1, 4, true, false)
		self._scriptControl:AddPropertyFloatSlider("AprilTagAlpha", "AprilTag对比度", self._aprilTagAlpha, 0.1, 2, true, false)
		self._scriptControl:AddPropertyFloatSlider("AprilTagLight", "AprilTag亮度", self._aprilTagLight, -100, 100, true, false)
		self._scriptControl:AddPropertyFloat4("AprilTagRect", "AprilTag聚焦区域", self._aprilRectFloat4, true, false)
	elseif 2==self._aprilTagType then
		self._scriptControl:AddPropertyFloatSlider("AprilTagIRThreshold", "IR出发亮度阈值", self._aprilTagIRThreshold, 0, 255, true, false)
	end

	PX2Table2Vector({ "51", "52", "53", "54", "55", "56"})
	self._scriptControl:AddPropertyEnum("WeaponIPIndex", "武器IP", self._weaponIPIndex, PX2_GH:Vec(), true, false)

	self._scriptControl:AddPropertyClass("Slam", "Slam")
	self._scriptControl:AddPropertyButton("SaveMap", "保存地图")
	self._scriptControl:AddPropertyButton("LoadMap", "加载地图")

    self._scriptControl:EndPropertyCata()

    self._propertyGridEdit:RegistOnObject(self._scriptControl, "EditSetting")
end
-------------------------------------------------------------------------------
function p_video:_OnPUpdate()
	local numCameras = PX2_OPENCVM:GetNumCVCameraObjPreCreate()
	local cvObj = PX2_OPENCVM:GetCVCameraObjPreCreate(0)
	if cvObj then
		if cvObj:IsOpened() then
			if self._isShow0 or self._isShow1 then
				if cvObj.TheVCType ==CVCameraObjBase.VCT_NORMAL or cvObj.TheVCType ==CVCameraObjBase.VCT_V4L2 then
					if cvObj then
						PX2_OPENCVM:GetTexture(0, self._fPicBoxCamera0:GetUIPicBox(), false)
						g_manykit._cameraTexture2D = self._fPicBoxCamera0:GetUIPicBox():GetTexture2D()
					end
				elseif cvObj.TheVCType ==CVCameraObjBase.VCT_CARINA then
					PX2_OPENCVM:GetTexture(0, self._fPicBoxCamera0:GetUIPicBox(), false, 0)
					g_manykit._cameraTexture2D = self._fPicBoxCamera0:GetUIPicBox():GetTexture2D()

					PX2_OPENCVM:GetTexture(0, self._fPicBoxCamera1:GetUIPicBox(), false, 1)
					g_manykit._cameraTexture2D1 = self._fPicBoxCamera1:GetUIPicBox():GetTexture2D()
				elseif cvObj.TheVCType ==CVCameraObjBase.VCT_ORBBEC then
					PX2_OPENCVM:GetTexture(0, self._fPicBoxCamera0:GetUIPicBox(), false, 0)
					g_manykit._cameraTexture2D = self._fPicBoxCamera0:GetUIPicBox():GetTexture2D()

					PX2_OPENCVM:GetTexture(0, self._fPicBoxCamera1:GetUIPicBox(), false, 1)
					g_manykit._cameraTexture2D1 = self._fPicBoxCamera1:GetUIPicBox():GetTexture2D()
				end
			end
		end
	end

	local isNeedUpdateHot = false
	if g_manykit._isUseCameraHot or self._isShow2 then
		isNeedUpdateHot = true
	end

	local cvObj1 = PX2_OPENCVM:GetCVCameraObjPreCreate(1)
	if cvObj1 and cvObj1:IsOpened() and isNeedUpdateHot then
		if cvObj1.TheVCType == CVCameraObjBase.VCT_NORMAL or cvObj1.TheVCType ==CVCameraObjBase.VCT_V4L2 then
			if cvObj1 and cvObj1:IsOpened() then
				PX2_OPENCVM:GetTexture(1, self._fPicBoxCamera1:GetUIPicBox(), false)
				g_manykit._cameraTexture2D1 = self._fPicBoxCamera1:GetUIPicBox():GetTexture2D()
			end
		elseif cvObj1.TheVCType == CVCameraObjBase.VCT_HOTCAMERA then
			PX2_OPENCVM:GetTexture(1, self._fPicBoxCamera2:GetUIPicBox(), false, 0)
			g_manykit._cameraTexture2D2 = self._fPicBoxCamera2:GetUIPicBox():GetTexture2D()

			g_manykit._fPicBoxHot:GetUIPicBox():SetTexture(g_manykit._cameraTexture2D2)
		end
	end

	local cvObj2 = PX2_OPENCVM:GetCVCameraObjPreCreate(2)
	if cvObj2 and cvObj2:IsOpened() and g_manykit._isUseCameraIP then
		if cvObj2.TheVCType == CVCameraObjBase.VCT_URL or cvObj2.TheVCType==CVCameraObjBase.VCT_URLFFMPEG then
			if cvObj2 and cvObj2:IsOpened() then
				PX2_OPENCVM:GetTexture(2, g_manykit._fPicBoxCameraIP:GetUIPicBox(), false, 0)
			end
		end
	end

	if self._isUseFaceIdentify then
		if not self._istakingphoto then
			if 0==self._identifyUseIndex then
				local tex2D = self._fPicBoxCamera0:GetUIPicBox():GetTexture2D()
				if tex2D then
					PX2_OPENCVM:IdentifyWithAll(tex2D, 0, self._identifyUseIndex)
				end
			end

			if 1==self._identifyUseIndex then
				local tex2D1 = self._fPicBoxCamera1:GetUIPicBox():GetTexture2D()
				if tex2D1 then
					PX2_OPENCVM:IdentifyWithAll(tex2D1, 0, self._identifyUseIndex)
				end
			end
		else
			self:_TakePhoto()
			self._istakingphoto = false
		end
	end

	local appSeconds = PX2_APP:GetAppSeconds()
	local diff = appSeconds - self._lastidentifiedtiming
	if diff > 0.6 then
		if not self._isidentifyresetted then
			self:_FaceIdentifyReset()
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_TakePhoto()
	print(self._name.." p_info:_TakePhoto")

	local userid = self._takingphotouserid

	local cfgName = PX2_OPENCVM:GetConfigName()	
	local pathParent = ResourceManager:GetWriteablePath() .. "Write_" .. cfgName .. "/"
	local pathFolder = pathParent .. "facetakephoto/"
	if not PX2_RM:IsFileFloderExist(pathFolder) then
		PX2_RM:CreateFloder(pathParent, "facetakephoto/")
	end

	local ldt = LocalDateTime()
	local tStr = ""..DateTimeFormatter:Format(ldt, "%Y-%n-%e-%H-%M-%S")
	local camIndex = PX2_OPENCVM:GetIdentifyCameraIndex()
	local filename = userid .. "_" .. tStr .. "_" .. camIndex ..".png" 
	local savePath = pathFolder .. filename
	print("savePathTakePhoto:"..savePath)

	local urlpath = "http://" .. p_net.g_ip_minna .. ":" .. "6606/" .. "facetakephoto/"..filename
	print("urlpath:"..urlpath)

	PX2_OPENCVM:CaptureImageToFile(camIndex, savePath)

	if ""~=self._imgregcallback_url then
		local devicekey = PX2_OPENCVM:GetFaceDeviceID()
		local allurl = self._imgregcallback_url.."?type=1&userid="..userid.."&ip=".. p_net.g_ip_minna .. "&devicekey"..devicekey.."&port=6606&image="..urlpath
		local curlObj = CurlObj:NewThread()
		curlObj:Get(allurl, "imgregCallback", self._scriptControl)
	end
end
-------------------------------------------------------------------------------
function p_video:_FaceIdentifyReset()
	print("p_video:_FaceIdentifyReset")

	self._lastidentifyuserid = ""
	self._isidentifyresetted = true

	PX2_GH:SendGeneralEvent("faceidentifyreset")
end
-------------------------------------------------------------------------------
function p_video:_OnOpenCVCallback(calltype, str0, str1, str2, str3)
	--print("calltype:"..calltype)

	if "faceregist"==calltype then
		local userid = str0
		local name = str1
		local faceid = str2
		local url = str3

		print("userid:"..userid)
		print("name:"..name)
		print("faceid:"..faceid)
		print("url:"..url)		

		local outBase_texture = StringHelp:SplitFullFilename_OutBase(url)
		local outExt_texture = StringHelp:SplitFullFilename_OutExt(url)

		print("outBase_texture:"..outBase_texture)
		print("outExt_texture:"..outExt_texture)

		local wpath0 = ResourceManager:GetWriteablePath().."Write_MANYKit/"
		local wpath1 = "face/"
		if not PX2_RM:IsFileFloderExist(wpath0..wpath1) then
			PX2_RM:CreateFloder(wpath0, wpath1)
		end
		local wpath = wpath0..wpath1..outBase_texture.."."..outExt_texture
		print("wpath:"..wpath)

		local curl = CurlObj:NewThread()
		curl:SetUserDataString("userid", userid)
		curl:SetUserDataString("group", "manykit")
		curl:SetUserDataString("name", name)
		curl:SetUserDataString("faceid", faceid)
		curl:SetUserDataString("savepath", wpath)
		curl:Download(url, wpath, "p_OnDownloadFaceRegist", self._scriptControl)
	elseif "faceidentify"==calltype then
		if "in"==str0 then
			PX2_GH:SendGeneralEvent("peoplein", str1)

			if "0"==str1 then
				print("stranger in")
			elseif "1"==str1 then
				print("friend in")
			end
		elseif "out"==str0 then
			PX2_GH:SendGeneralEvent("peopleout", str1)

			if "0"==str1 then
				print("stranger out")
			elseif "1"==str1 then
				print("friend out")
			end
		elseif "user"==str0 then
			local curappSeconds = PX2_APP:GetAppSeconds()
			self._lastidentifiedtiming = curappSeconds
			self._isidentifyresetted = false
			
			local faceRet = PX2_OPENCVM:GetFaceRegRet()
			local numRet = faceRet.ResultNum
			if numRet>0 then
				for i=0, numRet-1, 1 do
					local ret = faceRet:GetResult(i)
					--print("ret:"..i)
					--print("GroupIDStr:"..ret.GroupIDStr)
					--print("ScoreStr:"..ret.ScoreStr)
					--print("Score:"..ret.Score)
					--print("UserIDStr:"..ret.UserIDStr)
	
					local trig = false
					
					if self._lastidentifyuserid ~= ret.UserIDStr then
						self._lastidentifytime = curappSeconds
						trig = true
					else
						local diff = curappSeconds - self._lastidentifytime
						if diff > self._identifySamePeopleTime then
							self._lastidentifytime = curappSeconds
							trig = true						
						end
					end
					if trig then
						local cfgName = PX2_OPENCVM:GetConfigName()	
						local pathParent = ResourceManager:GetWriteablePath() .. "Write_" .. cfgName .. "/"
						local pathFolder = pathParent .. "faceidentify/"
						if not PX2_RM:IsFileFloderExist(pathFolder) then
							PX2_RM:CreateFloder(pathParent, "faceidentify/")
						end

						local ldt = LocalDateTime()
						local tStr = ""..DateTimeFormatter:Format(ldt, "%Y-%n-%e-%H-%M-%S")

						local camIndex = PX2_OPENCVM:GetIdentifyCameraIndex()
						local filename = ret.UserIDStr .. "_" .. tStr .. "_" .. camIndex ..".png" 
						local savePath = pathFolder .. filename
						print("savePath:"..savePath)						
						PX2_OPENCVM:CaptureImageToFile(camIndex, savePath)

						-- http://127.0.0.1:6606/faceidentify/10006_2023-7-14-14-14-40_1.png

						local urlpath = "faceidentify/"..filename
						PX2_GH:SendGeneralEvent("faceidentify", urlpath)
					end
					self._lastidentifyuserid = ret.UserIDStr
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_video:p_OnDownloadFaceRegist(ptr)
    local curlObj = Cast:ToO(ptr)

	if curlObj:IsGettedOK() then
		print("p_video:p_OnDownloadFaceRegist OK")

		local userid = curlObj:GetUserDataString("userid")
		local name = curlObj:GetUserDataString("name")
		local group = curlObj:GetUserDataString("group")
        local savepath = curlObj:GetUserDataString("savepath")
		local faceid = curlObj:GetUserDataString("faceid")
		PX2_RM:ClearRes(savepath)
		local texObj = PX2_RM:BlockLoad(savepath)
		local tex2D = Cast:ToTexture2D(texObj)
		if tex2D then
			PX2_OPENCVM:UserAdd(tex2D, userid, group, name)
			PX2_APP:SetConfig(self._mkdir, "userinfo", userid, name)
		end
	end
end
-------------------------------------------------------------------------------
function p_video:_RegistPropertyOnUser(userid)
	self._scriptControl:RemoveProperties("EditUser")

    self._scriptControl:BeginPropertyCata("EditUser")
    self._scriptControl:AddPropertyClass("EditUser", "人员")
	if ""~=userid then
		self._scriptControl:AddPropertyString("UserID", "用户ID", userid, false, false)

		local name = PX2_APP:GetConfig(self._mkdir, "userinfo", userid)
		self._scriptControl:AddPropertyString("UserName", "名称", name, false, false)
	end
    self._scriptControl:EndPropertyCata()

    self._propertyGridUser:RegistOnObject(self._scriptControl, "EditUser")

end
-------------------------------------------------------------------------------
function p_video:_UseRtsp(use)
	print("_UseRtsp:")
	print_i_b(use)
	PX2_OPENCVM:StartRTSPServer(use)
end
-------------------------------------------------------------------------------
function p_video:_UseRtmp(use)
	print(self._name.." p_video:_UseRtmp")
	print_i_b(use)

	if use then
		if self._cameraKey~="" then
			local url = "" .. self._ip_rtmp .. ":" .. p_net.g_port_minna_http .. "/camerartmp/get?streamname=" .. self._cameraKey
			print("url:"..url)
			
			local curl = CurlObj:NewThread()
			curl:Get(url, "_OnCreatePushStream", self._scriptControl)
		end
	else
		PX2_OPENCVM:StopRtmpPublisher()
	end
end
-------------------------------------------------------------------------------
function p_video:_OpenGunDetect(open)
	print(self._name.." p_video:_OpenGunDetect")
	print_i_b(open)

	self._isOpenAprilTag = open

	local strOpen = Utils.B2IS(open)
	PX2_PROJ:SetConfig("p_video_openapriltag", strOpen)

	local numCameras = PX2_OPENCVM:GetNumCVCameraObjPreCreate()
	for i = 0, numCameras-1, 1 do
		local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(i)
		if cvCamObj then
			local useage = cvCamObj.Useage

			if 0==self._aprilTagType or 1==self._aprilTagType then
				if "slam"==useage then
					local tstr = "Tag16h5"
					if 0==self._aprilTagType then
						tstr = "Tag16h5"
					else
						tstr = "Tag36h11"
					end
					cvCamObj:SetAprilTagDetect(open, tstr)
					
					cvCamObj:SetAprilTagDetectID(0)
					cvCamObj:SetAprilTagSize(self._aprilTagSize)
					local recV = self._aprilRectFloat4
					cvCamObj:SetAprilTagDetectRect(Rectf(recV:X(), recV:Y(), recV:Z(), recV:W()))
					cvCamObj:SetAprilTagDetectScale(self._aprilTagScale)
					cvCamObj:SetAprilTagDetectLight(self._aprilTagLight)
					cvCamObj:SetAprilTagDetectAlpha(self._aprilTagAlpha)
				else
					cvCamObj:SetAprilTagSize(self._aprilTagSize)
					cvCamObj:SetAprilTagDetect(false, "")
				end
			else	
				if "irgun"==useage then
					cvCamObj:SetAprilTagDetect(open, "irgun")
					cvCamObj:SetAprilTagDetectIRThresh(self._aprilTagIRThreshold)
				else
					cvCamObj:SetAprilTagDetect(false, "")
				end
			end
		end
	end	
end
-------------------------------------------------------------------------------
function p_video:_ShowAprilTag(show)
	print(self._name.." p_video:_ShowAprilTag")
	print_i_b(show)

	g_manykit._isShowAprilTag = show
	if g_manykit._nodeAprilTag then
		g_manykit._nodeAprilTag:Show(show)
	end

	local strShow = Utils.B2IS(show)
	PX2_PROJ:SetConfig("p_video_showapriltag", strShow)

	local numCameras = PX2_OPENCVM:GetNumCVCameraObjPreCreate()
	for i = 0, numCameras-1, 1 do
		local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(i)
		if cvCamObj then
			cvCamObj:ShowAprilTag(show)
		end
	end	
end
-------------------------------------------------------------------------------
function p_video:_OnCreatePushStream(ptr)
	print("manykit_OnCreatePushStream")

    local curlObj = Cast:ToO(ptr)
    local strMem = curlObj:GetGettedString() 

    local jsonData = JSONData()
    jsonData:LoadBuffer(strMem)
    local cStr = jsonData:GetMember("code")
    local cInt = cStr:ToInt()
    local data = jsonData:GetMember("data")
    if 0==cInt then
        local id = data:GetMember("id"):ToString()
        local name = data:GetMember("name"):ToString()
        local state = data:GetMember("state"):ToString()
        local streamname = data:GetMember("streamname"):ToString()
        local push_rtmpaddress = data:GetMember("push_rtmpaddress"):ToString()
        local pull_stream_rtmp_address = data:GetMember("pull_stream_rtmp_address"):ToString()
        local pull_stream_flv_address_http = data:GetMember("pull_stream_flv_address_http"):ToString()
        local pull_stream_flv_address_https = data:GetMember("pull_stream_flv_address_https"):ToString()

        print("push_rtmpaddress:"..push_rtmpaddress)
        print("pull_stream_rtmp_address:"..pull_stream_rtmp_address)
        print("pull_stream_flv_address_http:"..pull_stream_flv_address_http)
        print("pull_stream_flv_address_https:"..pull_stream_flv_address_https)

        PX2_OPENCVM:StartRtmpPublisher(push_rtmpaddress)
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_video)
-------------------------------------------------------------------------------