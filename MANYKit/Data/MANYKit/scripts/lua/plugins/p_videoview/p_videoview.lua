-- p_videoview.lua

p_videoview = class(p_ctrl,
{
	_name = "p_videoview",

    _requires = {},

    _listVideo = nil,
    _btnRefresh = nil,
    _frameVLC = nil,
    _pathSelectVideo = "",
    _videoDir = "",
    _framePlayer = nil,  -- 右侧播放器容器
    _lastVideoSize = nil,  -- 记录上次视频尺寸，避免重复计算
})
---------------------------------------------------------------
function p_videoview:OnAttached()
    PX2_LM_APP:AddItem(self._name, "videoview", "播放器")

    print(self._name.." p_videoview:OnAttached")
	p_ctrl.OnAttached(self)

    self._videoDir = ResourceManager:GetWriteablePath().."Write_MANYKit/video/"

    self:_CreateContentFrame()

    RegistEventObjectFunction("GraphicsES::GeneralString", self, function(myself, str, str1)
		if "minna_playvideo"==str then
			local indexStr = str1
			local index = StringHelp:StringToInt(indexStr, -1)

            print("minna_playvideo indexxxxxxxxxxxxxxxxxxxxxxxxxx:"..index)
			
			if index >= 0 and myself._listVideo then
                myself._listVideo:SelectItem(index)
            end
		end
	end)
end
-------------------------------------------------------------------------------
function p_videoview:_CreateContentFrame()
	print(self._name.." p_videoview:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frame:AttachChild(frame)
	frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

    -- 左侧：视频列表
    local frameList = UIFrame:New()
    frame:AttachChild(frameList)
    frameList:LLY(-2.0)
    frameList:SetAnchorHor(0.0, 0.2)
    frameList:SetAnchorParamHor(0.0, -0.0)
    frameList:SetAnchorVer(0.0, 1.0)
    frameList:SetAnchorParamVer(0.0, -5.0)
    frameList:CreateAddBackgroundPicBox()

    -- 刷新按钮
    local btnRefresh = UIButton:New("BtnRefresh")
    self._btnRefresh = btnRefresh
    frameList:AttachChild(btnRefresh)
    btnRefresh:LLY(-2.0)
    btnRefresh:SetAnchorHor(0.0, 1.0)
    btnRefresh:SetAnchorVer(1.0, 1.0)
    btnRefresh:SetAnchorParamVer(-20.0, -20.0)
    btnRefresh:SetHeight(40.0)
    btnRefresh:CreateAddFText("刷新列表")
    btnRefresh:SetScriptHandler("_UICallback", self._scriptControl)

    -- 视频列表
    local listVideo = UIList:New("ListVideo")
    self._listVideo = listVideo
    frameList:AttachChild(listVideo)
    listVideo:LLY(-2.0)
    listVideo:SetAnchorHor(0.0, 1.0)
    listVideo:SetAnchorVer(0.0, 1.0)
    listVideo:SetAnchorParamVer(0.0, -40.0)
    listVideo:SetItemBackColor(Float3(0.7, 0.7, 0.7))
    listVideo:SetReleasedDoSelect(true)
    listVideo:SetFontSize(16)
    listVideo:SetSliderSize(40.0)
    listVideo:SetItemHeight(50.0)
    listVideo:SetScriptHandler("_UICallback", self._scriptControl)

    -- 右侧：视频播放器
    local framePlayer = UIFrame:New()
    self._framePlayer = framePlayer  -- 保存引用
    frame:AttachChild(framePlayer)
    framePlayer:LLY(-2.0)
    framePlayer:SetAnchorHor(0.2, 1.0)
    framePlayer:SetAnchorParamHor(5.0, -5.0)
    framePlayer:SetAnchorVer(0.0, 1.0)
    framePlayer:SetAnchorParamVer(5.0, -5.0)

    local uiVLC = UIFrameVLC:New()
    self._frameVLC = uiVLC
    framePlayer:AttachChild(uiVLC)
    uiVLC:LLY(-1.0)
    -- 初始设置为全屏，后续会在 OnPUpdate 中动态调整
    uiVLC:SetAnchorHor(0.0, 1.0)
    uiVLC:SetAnchorVer(0.0, 1.0)

    -- 刷新视频列表
    self:_RefreshVideoList()

	self._scriptControl:ResetPlay()
end
---------------------------------------------------------------
function p_videoview:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)
	print(self._name.." p_videoview:OnInitUpdate")
end
---------------------------------------------------------------
function p_videoview:OnPPlay()
	print(self._name.." p_videoview:OnPPlay")
end
---------------------------------------------------------------
function p_videoview:OnPUpdate()
	-- 动态调整视频尺寸以保持长宽比
	if self._frameVLC and self._framePlayer then
		if self._frameVLC:IsPlaying() then
			local mediaSize = self._frameVLC:GetMediaSize()
			if mediaSize and mediaSize.Width > 0 and mediaSize.Height > 0 then
				self:_UpdateVideoLayout(mediaSize)
			end
		end
	end
end
---------------------------------------------------------------
function p_videoview:_UICallback(ptr,callType)
    local obj=Cast:ToO(ptr)
    local name=obj:GetName()

	if UICT_PRESSED==callType then
        PX2_GH:PlayScale(obj)
	elseif UICT_RELEASED ==callType then
        PX2_GH:PlayNormal(obj)

        if "BtnRefresh"==name then
            self:_RefreshVideoList()
        end
	elseif UICT_RELEASED_NOTPICK == callType then
        PX2_GH:PlayNormal(obj)
    elseif UICT_LIST_SELECTED==callType then
        if "ListVideo"==name then
            local itemSel = obj:GetSelectedItem()
            if itemSel then
                self:_OnSelectItemVideo(itemSel)
            end
        end
	end
end
---------------------------------------------------------------
function p_videoview:_RefreshVideoList()
    if not self._listVideo then
        return
    end

    self._listVideo:RemoveAllItems()
    self._pathSelectVideo = ""

    if ""==self._videoDir then
        print("视频目录未设置")
        return
    end

    local dir = DirP()
    dir:GetAllFiles(self._videoDir, "");
    dir:SortFilesByTime()
    local numFiles = dir:GetNumFiles()
    
    print("找到 "..numFiles.." 个视频文件")
    
    for i=0,numFiles-1,1 do
        local filename = dir:GetFile(i)
        local ext = StringHelp:SplitFullFilename_OutExt(filename)
        
        -- 只添加视频文件
        if ext=="mp4" or ext=="avi" or ext=="mkv" or ext=="mov" or ext=="flv" or ext=="wmv" then
            local outBase = StringHelp:SplitFullFilename_OutBase(filename)
            local name = outBase.."."..ext
            
            local item = self._listVideo:AddItem(name)
            item:SetUserDataString("path", filename)
            item:SetUserDataString("name", name)
        end
    end
end
---------------------------------------------------------------
function p_videoview:_OnSelectItemVideo(item)
    if not item then
        return
    end

    local path = item:GetUserDataString("path")
    print("选择视频: "..path)

    if ""==path then
        print("视频路径为空")
        return
    end

    -- 如果选择了不同的视频，则播放新视频
    if path ~= self._pathSelectVideo then
        self._pathSelectVideo = path
        
        if self._frameVLC then
            print("开始播放视频: "..path)
            self._frameVLC:StartVLC(path)
        else
            print("视频播放器未初始化")
        end
    end
end
---------------------------------------------------------------
function p_videoview:_UpdateVideoLayout(mediaSize)
    if not self._frameVLC or not self._framePlayer then
        return
    end

    -- 获取容器尺寸
    local containerSize = self._framePlayer:GetSize()
    if not containerSize or containerSize.Width <= 0 or containerSize.Height <= 0 then
        return
    end

    -- 计算媒体和容器的长宽比
    local mediaAspect = mediaSize.Width / mediaSize.Height
    local containerAspect = containerSize.Width / containerSize.Height

    local targetWidth, targetHeight
    local offsetX, offsetY

    -- 根据长宽比决定如何填充容器
    if mediaAspect > containerAspect then
        -- 视频更宽，按宽度填充，高度居中
        targetWidth = containerSize.Width
        targetHeight = containerSize.Width / mediaAspect
        offsetX = 0.0
        offsetY = (containerSize.Height - targetHeight) / 2.0
    else
        -- 视频更高，按高度填充，宽度居中
        targetHeight = containerSize.Height
        targetWidth = containerSize.Height * mediaAspect
        offsetX = (containerSize.Width - targetWidth) / 2.0
        offsetY = 0.0
    end

    -- 计算锚点参数（相对于容器）
    local anchorParamHorMin = offsetX
    local anchorParamHorMax = -(containerSize.Width - targetWidth - offsetX)
    local anchorParamVerMin = offsetY
    local anchorParamVerMax = -(containerSize.Height - targetHeight - offsetY)

    -- 设置视频帧的锚点和参数
    self._frameVLC:SetAnchorHor(0.0, 1.0)
    self._frameVLC:SetAnchorParamHor(anchorParamHorMin, anchorParamHorMax)
    self._frameVLC:SetAnchorVer(0.0, 1.0)
    self._frameVLC:SetAnchorParamVer(anchorParamVerMin, anchorParamVerMax)
end
---------------------------------------------------------------
g_manykit:plugin_regist(p_videoview)
---------------------------------------------------------------