-- p_robotmusic.lua

p_robotmusic = class(p_ctrl,
{
    _requires = {"p_robot", },

	_name = "p_robotmusic",

    _url = "182.254.213.85",

    _listMusicLocal = nil,
    _editBoxMusicPathLocal = nil,

    _listMusicCloud = nil,
    _editBoxMusicName = nil,

	_listMusicStore = nil,

	_musicStore = {},

    _eidtboxgroup_minna = nil,
    _listmusic_minna = nil,
})
-------------------------------------------------------------------------------
function p_robotmusic:OnAttached()
	PX2_LM_APP:AddItem(self._name, "ROBOTMusic", "音乐")
    PX2_LM_APP:AddItem("Store", "Store", "存储")

	p_ctrl.OnAttached(self)
	print(self._name.." p_robotmusic:OnAttached")

    self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_robotmusic:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_robotmusic:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_robotmusic:OnPPlay()
	print(self._name.." p_robotmusic:OnPPlay")
end
-------------------------------------------------------------------------------
-- ui call back
function p_robotmusic:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

    if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
    elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

        if "BtnSearch"==name then            
            local textMusicName = self._editBoxMusicName:GetText()
            if ""~=textMusicName then
                self:_SearchMusicCloud(textMusicName)
            end
        elseif "BtnRefreshLocal"==name then
            self:_RefreshMusicLocal()
        elseif "BtnStore"==name then
            self:_MusicStore()
        elseif "BtnStoreDelete"==name then
            self:_MusicStoreDelete()
        elseif "BtnPlay"==name then
            self:_MusicPlay()
        elseif "BtnStop"==name then
            self:_MusicStop()
        elseif "BtnSearchMT"==name then
            if self._eidtboxgroup_minna then
                local txt = self._eidtboxgroup_minna:GetText()
                if ""~=txt then
                    p_net._g_net:_act_music_playgroup(txt, self._listmusic_minna)
                end
            end
        elseif "BtnPlayMT"==name then
            self:_MusicPlayMt()
        elseif "BtnStopMT"==name then
            p_net._g_net:_act_music_stop()
        end
    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_GH:PlayNormal(obj)
    end
end
-------------------------------------------------------------------------------
-- ui
function p_robotmusic:_CreateContentFrame()
    print(self._name.." p_robotmusic:_CreateContentFrame")

    local uiFrameBack, uiFrame, btnClose, textTitle, backPic = manykit_createCommonDlg(-10, -10, "")
    self._frame:AttachChild(uiFrameBack)
    
    local frameTab = UITabFrame:New()
    uiFrame:AttachChild(frameTab)
    frameTab:LLY(-2.0)
    frameTab:SetAnchorHor(0.0, 1.0)
    frameTab:SetAnchorParamHor(0.0, 0.0)
    frameTab:SetAnchorVer(0.0, 1.0)
    frameTab:SetAnchorParamVer(0.0, 0.0)
    manykit_uiProcessTable(frameTab)

    frameTab:AddTab("APP", "APP", self:_CreateFramePX())
    frameTab:AddTab("Minna", "Minna", self:_CreateFrameMT())

    frameTab:SetActiveTab("APP")

    btnClose:Show(false)
end
-------------------------------------------------------------------------------
function p_robotmusic:_CreateFramePX()
    local frame = UIFrame:New()
    frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorParamHor(10.0, -10.0)
    frame:SetAnchorVer(0.0, 1.0)
    frame:SetAnchorParamVer(10.0, -10.0)

    local posV = -40.0
    local posM = 60.0
    local ver = 120

    -- Left
    local posVer = posV
	local textLocal = UIFText:New()
	frame:AttachChild(textLocal)
	textLocal:LLY(-1.0)
	textLocal:SetAnchorHor(0.0, 0.0)
	textLocal:SetAnchorParamHor(0.0, 0.0)
	textLocal:SetAnchorVer(1.0, 1.0)
	textLocal:SetAnchorParamVer(posVer, posVer)
	textLocal:SetPivot(0.0, 0.5)
	textLocal:SetSize(350, g_manykit._hBtn)
	textLocal:GetText():SetText("本地文件夹名称,末尾带/")
	textLocal:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    manykit_uiProcessFText(textLocal)

    local list = UIList:New("ListLocal")
    self._listMusicLocal = list
    frame:AttachChild(list)
    --list:SetSwitchSelect(true)
    list:LLY(-2.0)
    list:SetAnchorHor(0.0, 0.33)
    list:SetAnchorParamHor(0.0, 0.0)
    list:SetAnchorVer(0.0, 1.0)
    list:SetAnchorParamVer(ver, -160.0)
    list:SetReleasedDoSelect(true)
    list:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(list)

    posVer = posVer - posM

    local uiEditBoxMusicPath = UIEditBox:New("EditBoxMusicPath")
	frame:AttachChild(uiEditBoxMusicPath)
    self._editBoxMusicPathLocal = uiEditBoxMusicPath
	uiEditBoxMusicPath:LLY(-2.0)
	uiEditBoxMusicPath:SetAnchorHor(0.0, 0.33)
	uiEditBoxMusicPath:SetAnchorParamHor(0.0, -75.0)
    uiEditBoxMusicPath:SetAnchorVer(1.0, 1.0)
    uiEditBoxMusicPath:SetAnchorParamVer(posVer, posVer)
	uiEditBoxMusicPath:SetPivot(0.5, 0.5)
	uiEditBoxMusicPath:SetHeight(g_manykit._hBtn)
    local pathText = PX2_PROJ:GetConfig("localmusicpath")
    print("localmusicpath:"..pathText)
    uiEditBoxMusicPath:SetText(pathText)

    local btnRefresh = UIButton:New("BtnRefreshLocal")
    frame:AttachChild(btnRefresh)
	btnRefresh:LLY(-2.0)
	btnRefresh:SetAnchorHor(0.33, 0.33)
	btnRefresh:SetAnchorParamHor(-45.0, -45.0)
    btnRefresh:SetAnchorVer(1.0, 1.0)
    btnRefresh:SetAnchorParamVer(posVer, posVer)
	btnRefresh:SetPivot(0.5, 0.5)
    btnRefresh:SetSize(g_manykit._hBtn, g_manykit._hBtn)
    btnRefresh:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessBtn(btnRefresh)
    btnRefresh:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnRefresh:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/refresh.png")

    -- Right
    posVer = posV

    local textOnline = UIFText:New()
	frame:AttachChild(textOnline)
	textOnline:LLY(-1.0)
	textOnline:SetAnchorHor(0.33, 0.33)
	textOnline:SetAnchorParamHor(20.0, -20.0)
	textOnline:SetAnchorVer(1.0, 1.0)
	textOnline:SetAnchorParamVer(posVer, posVer)
	textOnline:SetPivot(0.0, 0.5)
	textOnline:SetSize(128, 80)
	textOnline:GetText():SetText("在线")
    manykit_uiProcessFText(textOnline)

    posVer = posVer - posM

    local uiEditBoxMusicName = UIEditBox:New("EditBoxSearchMusicName")
	frame:AttachChild(uiEditBoxMusicName)
    self._editBoxMusicName = uiEditBoxMusicName
	uiEditBoxMusicName:LLY(-2.0)
	uiEditBoxMusicName:SetAnchorHor(0.33, 0.66)
	uiEditBoxMusicName:SetAnchorParamHor(20.0, -75.0)
    uiEditBoxMusicName:SetAnchorVer(1.0, 1.0)
    uiEditBoxMusicName:SetAnchorParamVer(posVer, posVer)
	uiEditBoxMusicName:SetPivot(0.5, 0.5)
	uiEditBoxMusicName:SetHeight( g_manykit._hBtn)
    uiEditBoxMusicName:SetText("")

    local btnSearch = UIButton:New("BtnSearch")
    frame:AttachChild(btnSearch)
	btnSearch:LLY(-2.0)
	btnSearch:SetAnchorHor(0.66, 0.66)
	btnSearch:SetAnchorParamHor(-45.0, -45.0)
    btnSearch:SetAnchorVer(1.0, 1.0)
    btnSearch:SetAnchorParamVer(posVer, posVer)
	btnSearch:SetPivot(0.5, 0.5)
    btnSearch:SetSize(g_manykit._hBtn, g_manykit._hBtn)
    btnSearch:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessBtn(btnSearch)
    btnSearch:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnSearch:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/search.png")

    local listOnline = UIList:New("ListCloud")
    self._listMusicCloud = listOnline
    frame:AttachChild(listOnline)
    --listOnline:SetSwitchSelect(true)
    listOnline:LLY(-2.0)
    listOnline:SetAnchorHor(0.33, 0.66)
    listOnline:SetAnchorParamHor(20.0, 0.0)
    listOnline:SetAnchorVer(0.0, 1.0)
    listOnline:SetAnchorParamVer(ver, -160.0)
    listOnline:SetReleasedDoSelect(true)
    listOnline:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(listOnline)

    -- store
    posVer = posV

    local textStore = UIFText:New()
	frame:AttachChild(textStore)
	textStore:LLY(-1.0)
	textStore:SetAnchorHor(0.66, 0.66)
	textStore:SetAnchorParamHor(20.0, 40.0)
	textStore:SetAnchorVer(1.0, 1.0)
	textStore:SetAnchorParamVer(posVer, posVer)
	textStore:SetPivot(0.0, 0.5)
	textStore:SetSize(128, 80)
	textStore:GetText():SetText(""..PX2_LM_APP:V("Store"))
	textStore:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)
    manykit_uiProcessFText(textStore)

    posVer = posVer - posM

    local btnStoreDelete = UIButton:New("BtnStoreDelete")
    frame:AttachChild(btnStoreDelete)
	btnStoreDelete:LLY(-2.0)
	btnStoreDelete:SetAnchorHor(1.0, 1.0)
	btnStoreDelete:SetAnchorParamHor(-45.0, -45.0)
    btnStoreDelete:SetAnchorVer(1.0, 1.0)
    btnStoreDelete:SetAnchorParamVer(posVer, posVer)
	btnStoreDelete:SetPivot(0.5, 0.5)
    btnStoreDelete:SetSize(g_manykit._hBtn, g_manykit._hBtn)
    manykit_uiProcessBtn(btnStoreDelete)
    btnStoreDelete:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnStoreDelete:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/delete.png")
    btnStoreDelete:SetScriptHandler("_UICallback", self._scriptControl)

    local btnStore = UIButton:New("BtnStore")
    frame:AttachChild(btnStore)
	btnStore:LLY(-2.0)
	btnStore:SetAnchorHor(1.0, 1.0)
	btnStore:SetAnchorParamHor(-105.0, -105.0)
    btnStore:SetAnchorVer(1.0, 1.0)
    btnStore:SetAnchorParamVer(posVer, posVer)
	btnStore:SetPivot(0.5, 0.5)
    btnStore:SetSize(g_manykit._hBtn, g_manykit._hBtn)
    manykit_uiProcessBtn(btnStore)
    btnStore:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnStore:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/cross.png")
    btnStore:SetScriptHandler("_UICallback", self._scriptControl)

    local listMusicStore = UIList:New("ListMusicStore")
    frame:AttachChild(listMusicStore)
    self._listMusicStore = listMusicStore
    --listMusicStore:SetSwitchSelect(true)
    listMusicStore:LLY(-2.0)
    listMusicStore:SetAnchorHor(0.66, 1.0)
    listMusicStore:SetAnchorParamHor(20.0, 0.0)
    listMusicStore:SetAnchorVer(0.0, 1.0)
    listMusicStore:SetAnchorParamVer(ver, -160.0)
    listMusicStore:SetReleasedDoSelect(true)
    listMusicStore:SetScriptHandler("_UICallback", self._scriptControl)
    manykit_uiProcessList(listMusicStore)
    
    -- bottom
    local btnPlay = UIButton:New("BtnPlay")
    frame:AttachChild(btnPlay)
    btnPlay:LLY(-2.0)
    btnPlay:SetSize(g_manykit._hBtn*2, g_manykit._hBtn*2)
    btnPlay:SetAnchorHor(0.0, 0.0)
    btnPlay:SetAnchorParamHor(40.0, 40.0)
    btnPlay:SetAnchorVer(0.0, 0.0)
    btnPlay:SetAnchorParamVer(60.0, 60.0)
    manykit_uiProcessBtn(btnPlay)
    btnPlay:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnPlay:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/play.png")
    btnPlay:SetScriptHandler("_UICallback", self._scriptControl)

    local btnStop = UIButton:New("BtnStop")
    frame:AttachChild(btnStop)
    btnStop:LLY(-1.0)
    btnStop:SetSize(g_manykit._hBtn*2, g_manykit._hBtn*2)
    btnStop:SetAnchorHor(0.0, 0.0)
    btnStop:SetAnchorParamHor(130.0, 130.0)
    btnStop:SetAnchorVer(0.0, 0.0)
    btnStop:SetAnchorParamVer(60.0, 60.0)
    manykit_uiProcessBtn(btnStop)
    btnStop:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NORMAL)
    btnStop:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("common/images/ui/stop.png")
    btnStop:SetScriptHandler("_UICallback", self._scriptControl)

	self:_LoadStoreMusic()

    return frame
end
-------------------------------------------------------------------------------
function p_robotmusic:_CreateFrameMT()
    local frameOut = UIFrame:New()
    frameOut:LLY(-1.0)
    frameOut:SetAnchorHor(0.0, 1.0)
    frameOut:SetAnchorParamHor(0.0, 0.0)
    frameOut:SetAnchorVer(0.0, 1.0)
    frameOut:SetAnchorParamVer(0.0, 0.0)   
    frameOut:CreateAddBackgroundPicBox(true, Float3(0.5, 0.5, 0.5)) 

    local frame = UIFrame:New()
    frameOut:AttachChild(frame)
    frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorParamHor(10.0, -10.0)
    frame:SetAnchorVer(0.0, 1.0)
    frame:SetAnchorParamVer(10.0, -10.0)   
    frame:CreateAddBackgroundPicBox(true, Float3(0.5, 0.5, 0.5)) 

    local fText = UIFText:New()
    frame:AttachChild(fText)
    fText:LLY(-1.0)
    fText:SetAnchorHor(0.0, 1.0)
    fText:SetAnchorParamHor(5.0, -5.0)
    fText:SetAnchorVer(1.0, 1.0)
    fText:SetAnchorParamVer(-15.0, -15.0)
    fText:GetText():SetFontColor(Float3(1.0, 1.0, 1.0))
    fText:GetText():SetText("输入Minna资源分组,点击播放进行播放")
    fText:GetText():SetAligns(TEXTALIGN_LEFT + TEXTALIGN_VCENTER)

    local editBoxGroup = UIEditBox:New("EditBoxGroup")
    self._eidtboxgroup_minna = editBoxGroup
	frame:AttachChild(editBoxGroup)
	editBoxGroup:LLY(-2.0)
	editBoxGroup:SetAnchorHor(0.0, 1.0)
	editBoxGroup:SetAnchorParamHor(0.0, -3.0*g_manykit._hBtn-5)
    editBoxGroup:SetAnchorVer(1.0, 1.0)
    editBoxGroup:SetAnchorParamVer(-50.0, -50.0)
	editBoxGroup:SetPivot(0.5, 0.5)
    editBoxGroup:SetHeight(g_manykit._hBtn)

    local btnSearch = UIButton:New("BtnSearchMT")
    frame:AttachChild(btnSearch)
	btnSearch:LLY(-2.0)
	btnSearch:SetAnchorHor(1.0, 1.0)
	btnSearch:SetAnchorParamHor(-g_manykit._hBtn*2.5, -g_manykit._hBtn*2.5)
    btnSearch:SetAnchorVer(1.0, 1.0)
    btnSearch:SetAnchorParamVer(-50.0, -50.0)
	btnSearch:SetPivot(0.5, 0.5)
    btnSearch:SetSize(g_manykit._hBtn-2, g_manykit._hBtn-2)
    btnSearch:SetScriptHandler("_UICallback", self._scriptControl)
    btnSearch:CreateAddFText("搜索")
    manykit_uiProcessBtn(btnSearch)

    local btnPlay = UIButton:New("BtnPlayMT")
    frame:AttachChild(btnPlay)
	btnPlay:LLY(-2.0)
	btnPlay:SetAnchorHor(1.0, 1.0)
	btnPlay:SetAnchorParamHor(-g_manykit._hBtn*1.5, -g_manykit._hBtn*1.5)
    btnPlay:SetAnchorVer(1.0, 1.0)
    btnPlay:SetAnchorParamVer(-50.0, -50.0)
	btnPlay:SetPivot(0.5, 0.5)
    btnPlay:SetSize(g_manykit._hBtn-2, g_manykit._hBtn-2)
    btnPlay:SetScriptHandler("_UICallback", self._scriptControl)
    btnPlay:CreateAddFText("播放")
    manykit_uiProcessBtn(btnPlay)

    local btnStop = UIButton:New("BtnStopMT")
    frame:AttachChild(btnStop)
	btnStop:LLY(-2.0)
	btnStop:SetAnchorHor(1.0, 1.0)
	btnStop:SetAnchorParamHor(-g_manykit._hBtn*0.5, -g_manykit._hBtn*0.5)
    btnStop:SetAnchorVer(1.0, 1.0)
    btnStop:SetAnchorParamVer(-50.0, -50.0)
	btnStop:SetPivot(0.5, 0.5)
    btnStop:SetSize(g_manykit._hBtn-2, g_manykit._hBtn-2)
    btnStop:SetScriptHandler("_UICallback", self._scriptControl)
    btnStop:CreateAddFText("停止")
    manykit_uiProcessBtn(btnStop)

    local listMusic = UIList:New()
    frame:AttachChild(listMusic)
    self._listmusic_minna = listMusic
    listMusic:LLY(-1.0)
    listMusic:SetAnchorHor(0.0, 1.0)
    listMusic:SetAnchorVer(0.0, 1.0)
    listMusic:SetAnchorParamVer(0.0, -50 - g_manykit._hBtn*0.5)
    manykit_uiProcessList(listMusic)

    return frameOut
end
-------------------------------------------------------------------------------
-- lcoal
function p_robotmusic:_RefreshMusicLocal()
	print(self._name.." p_robotmusic:_RefreshMusicLocal")

    self._listMusicLocal:RemoveAllItems()

    local path = self._editBoxMusicPathLocal:GetText()
    PX2_PROJ:SetConfig("localmusicpath", path)

    if ""~= path then
        local allPath = path
        local dir = DirP()
        dir:GetAllFiles(allPath, "");
        local numFiles = dir:GetNumFiles()
        print("numFiles:"..numFiles)
        for i=0,numFiles-1,1 do
            local filename = dir:GetFile(i)
            print("filename:"..filename)

            local outPath = StringHelp:SplitFullFilename_OutBase(filename)
            local extStr = StringHelp:SplitFullFilename_OutExt(filename)

            if "mp3"==extStr or "ogg"==extStr then
                local item = self._listMusicLocal:AddItem(outPath)
                item:SetUserDataString("path", filename)
            end
        end
    end
end
-------------------------------------------------------------------------------
-- cloud
function p_robotmusic:_SearchMusicCloud(musicName)
    print(self._name.." p_robotmusic:_SearchMusicCloud:"..musicName)

    self._listMusicCloud:RemoveAllItems()

    local url = "http://".. self._url .. "/robot/musicurllist?name=" .. StringHelp:UrlEncode(musicName)
    print("url:")
    print(url)
    local curlObj = CurlObj:NewThread()
    curlObj:Get(url, "_OnSearchedMusicCloud", self._scriptControl)
end
function p_robotmusic:_OnSearchedMusicCloud(ptr)
    local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
        local strMem = curlObj:GetGettedString()

        print("strMem:")
        print(strMem)

        local jsonData = JSONData()
        jsonData:LoadBuffer(strMem)

        local cStr = jsonData:GetMember("code")
        local cInt = cStr:ToInt()
        if 0==cInt then
            local data = jsonData:GetMember("data")
            if data:IsArray() then
                local arrSize = data:GetArraySize()
                for i=0,arrSize-1,1 do
                    local e = data:GetArrayElement(i)

                    local name = e:GetMember("name"):ToString()
                    local singername = e:GetMember("singername"):ToString()
                    local url = e:GetMember("url"):ToString()
                    local hash = e:GetMember("hash"):ToString()
                    
                    local infoStr = ""..name.." "..singername
                    local item = self._listMusicCloud:AddItem(infoStr)
                    item:SetUserDataString("hash", hash)
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
-- store
function p_robotmusic:_MusicStore()
	print(self._name.." p_robotmusic:_MusicStore")

    local urlpath = ""
    local nameLabel = ""
    local islocalstr = "false"
    local itemLocal = self._listMusicLocal:GetSelectedItem()
    if itemLocal then
        islocalstr = "true"
        urlpath = itemLocal:GetUserDataString("path")
        nameLabel = itemLocal:GetLabel()
    else
        local item = self._listMusicCloud:GetSelectedItem()
        if item then
            islocalstr = "false"
            urlpath = item:GetUserDataString("hash")
            nameLabel = item:GetLabel()
        end
    end

    if ""~=urlpath then
        local tA = {
            name=nameLabel,
            islocal=islocalstr,
            urlpath=urlpath
        }
        table.insert(self._musicStore, #self._musicStore+1, tA)
        
        self:_RefreshStoreList()
        self:_SaveStoreMusic()
    end
end
function p_robotmusic:_MusicStoreDelete()
	print(self._name.." p_robotmusic:_MusicStoreDelete")

    local selectItem = self._listMusicStore:GetSelectedItem()
    if nil~=selectItem then      
        local index = selectItem:GetUserDataString("index") + 0

        table.remove(self._musicStore, index)

        self:_RefreshStoreList()
        self:_SaveStoreMusic()
    end
end
function p_robotmusic:_LoadStoreMusic()
	print(self._name.." p_robotmusic:_LoadStoreMusic")

    local wp = ResourceManager:GetWriteablePath()
    local projName = PX2_PROJ:GetName()
	local writePath = "" .. wp .. "Write_" .. projName .. "/musicstore.xml" 
    if PX2_RM:IsFileFloderExist(writePath) then
        --self._timeAlarams = {}
        local ret = PX2_RM:LoadXML(writePath)  
        local data = PX2_RM:GetXMLData()  
        local rootNode = data:GetRootNode()
        if ret and data:IsOpened() and not rootNode:IsNull() then
            local nodeChild = rootNode:IterateChild()
            local num = 1
            while not nodeChild:IsNull() do
                local name = nodeChild:GetName()

                local na = nodeChild:AttributeToString("name")
                local isLStr = nodeChild:AttributeToString("islocal")
                local urlp = nodeChild:AttributeToString("urlpath")

                local val = {
                    name=na,
                    islocal=isLStr,
                    urlpath=urlp
                }

                table.insert(self._musicStore, num, val)

                num = num + 1
                nodeChild = rootNode:IterateChild(nodeChild)
            end
        end

        PX2_RM:ClearRes(writePath)
    end
    
    self:_RefreshStoreList()
end
function p_robotmusic:_SaveStoreMusic()
	print(self._name.." p_robotmusic:_SaveStoreMusic")

    local data = XMLData()
    data:Create()
    local boostNode = data:NewChild("storemusic");

    for i=1,#self._musicStore,1 do
        local ms = self._musicStore[i]

        local taNode = boostNode:NewChild("music")
        taNode:SetAttributeString("name", ms.name)
        taNode:SetAttributeString("islocal", ms.islocal)
        taNode:SetAttributeString("urlpath", ms.urlpath)
    end

	local wp = ResourceManager:GetWriteablePath()
	local projName = PX2_PROJ:GetName()
	local writePath = "" .. wp .. "Write_" .. projName .. "/musicstore.xml"
    data:SaveFile(writePath)
    data:Clear()
end
function p_robotmusic:_RefreshStoreList()
    print(self._name.." p_robotmusic:_RefreshStoreList")

    self._listMusicStore:RemoveAllItems()
    for i=1,#self._musicStore,1 do
        local val = self._musicStore[i]
        local na = val.name
        local urlpath = val.urlpath
        local islocal = val.islocal

        local item = self._listMusicStore:AddItem(na)
        item:SetUserDataString("urlpath", urlpath)
        item:SetUserDataString("islocal", islocal)
        item:SetUserDataString("index", i)
    end
end
-------------------------------------------------------------------------------
-- music play
function p_robotmusic:_MusicPlay()
    print(self._name.." p_robotmusic:_MusicPlay")

    local itemMusicStore = self._listMusicStore:GetSelectedItem()
    if itemMusicStore then
        local islocal = itemMusicStore:GetUserDataString("islocal")
        local path = itemMusicStore:GetUserDataString("urlpath")
        if "true"==islocal then
            if PX2_SS then
                PX2_SS:ClearAllSounds()
                PX2_SS:PlayMusic(g_manykit._channel_music, path, true, 0.0)
            end
        else
            print(path)
            if PX2_SS then
                PX2_SS:ClearAllSounds()
                self:_PlayMusicHash(path)
            end
        end
    else
        local sel0 = false
        local itemLocal = self._listMusicLocal:GetSelectedItem()
        if itemLocal then
            sel0 = true
            local path = itemLocal:GetUserDataString("path")
            print("path")
            print(path)
            if path then
                if nil~=PX2_SS then
                    PX2_SS:ClearAllSounds()
                    PX2_SS:PlayMusic(g_manykit._channel_music, path, true, 0.0)
                end
            end
        end

        local itemCloud = self._listMusicCloud:GetSelectedItem()
        if itemCloud then
            sel0 = true
            local hash = itemCloud:GetUserDataString("hash")
            print("hash")
            print(hash)
            if hash and ""~=hash then
                self:_PlayMusicHash(hash)
            end
        end

        if not sel0 then
            self:_MusicStop()
        end
    end
end
function p_robotmusic:_PlayMusicHash(hash)
    print(self._name.." p_robotmusic:_PlayMusicHash:"..hash)

    if PX2_SS then
        PX2_SS:ClearAllSounds()
    end
 
    local curlObj = CurlObj:NewThread()
	local url = "http://" .. self._url .. "/robot/musichash?hash=" .. hash
    curlObj:Get(url, "_OnPlayMusicHash", self._scriptControl)
end
function p_robotmusic:_OnPlayMusicHash(ptr)
    print(self._name.." p_robotmusic:_OnPlayMusicHash:")

    local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
        local strMem = curlObj:GetGettedString()

        print("strMem:")
        print(strMem)

        local dt = PX2JSon.decode(strMem)
        local code = dt.code
        local msg = dt.msg
        if 0==code then
            local url = dt.data.url
            print("url:")
            print(url)
            if PX2_SS then
                PX2_SS:PlayASound(url, g_manykit._soundVolume, 400.0)
            end
        end
    end
end
function p_robotmusic:_MusicStop()
    print(self._name.." p_robotmusic:_MusicStop")

    if nil~=PX2_SS then
        PX2_SS:ClearAllSounds()
        PX2_SS:PlayMusic(g_manykit._channel_music, nil, true, 0.0)
    end
end
-------------------------------------------------------------------------------
-- mt
function p_robotmusic:_MusicPlayMt()
    print(self._name.." p_robotmusic:_MusicPlayMt")

    local item = self._listmusic_minna:GetSelectedItem()
    if item then
        local url = item:GetUserDataString("url")
        print("url:"..url)

        if PX2_SS then
            PX2_SS:PlayMusic(g_manykit._channel_music, url, false, 2.0)
        end
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_robotmusic)
-------------------------------------------------------------------------------