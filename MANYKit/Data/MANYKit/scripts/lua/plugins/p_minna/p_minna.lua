-- p_minna.lua

p_minna = class(p_ctrl,
{
	_name = "p_minna",

	_requires = {},
	
	-- UI 控件
	_textFrame = nil,
	_webFrame = nil,
	
	-- 状态记录
	_isWebFrameShown = false,
	_currentURL = "",
	
	-- 检查定时器
	_healthCheckTimer = 0.0,
	_healthCheckInterval = 1.0,  -- 每秒检查一次
})
-------------------------------------------------------------------------------
function p_minna:OnAttached()
	PX2_LM_APP:AddItem(self._name, "minna", "minna")
	
	print(self._name.." p_minna:OnAttached")

	p_ctrl.OnAttached(self)

	self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_minna:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_minna:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_minna:_Cleanup()
	print(self._name.." p_minna:_Cleanup")
	PX2_OPENCVM:SetScriptCallback("", nil)
end

function p_minna:OnPPlay()
	print(self._name.." p_minna:OnPPlay")
end
-------------------------------------------------------------------------------
function p_minna:OnPUpdate()
	local secs = PX2_APP:GetElapsedSecondsWidthSpeed()
	
	-- 定期检查健康状态
	if self._healthCheckTimer >= self._healthCheckInterval then
		self._healthCheckTimer = 0.0
		self:_CheckHealthAndUpdateUI()
	else
		self._healthCheckTimer = self._healthCheckTimer + secs
	end
end
-------------------------------------------------------------------------------
function p_minna:_CreateContentFrame()
	print(self._name.." p_minna:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frame:AttachChild(frame)
	frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)

	-- 创建文本提示
	local textFrame = UIFText:New()
	self._textFrame = textFrame
	frame:AttachChild(textFrame)
	textFrame:LLY(-2.0)
	textFrame:SetAnchorHor(0.0, 1.0)
	textFrame:SetAnchorVer(0.0, 1.0)
	textFrame:SetAnchorParamHor(10.0, -10.0)
	textFrame:SetAnchorParamVer(0.0, 0.0)
	textFrame:GetText():SetFontColor(Float3.WHITE)
	textFrame:GetText():SetAligns(TEXTALIGN_HCENTER + TEXTALIGN_VCENTER)
	textFrame:GetText():SetFontSize(32)
	textFrame:GetText():SetFontScale(1.0)
	textFrame:GetText():SetText('在"启动项"启动MinnaJS本地服务器')
	textFrame:Show(true)

	-- 创建网页控件（默认隐藏）
	if nil~=UIFrameCEF then
        local fminna = UIFrameCEF:New("UIFrameCEFMinna")
        self._webFrame = fminna
        frame:AttachChild(fminna)
        fminna:LLY(-2.0)
        fminna:SetAnchorHor(0.0, 1.0)
        fminna:SetAnchorVer(0.0, 1.0)
        fminna:Show(false)
    end

	self._scriptControl:ResetPlay()
end
-------------------------------------------------------------------------------
function p_minna:_CheckHealthAndUpdateUI()
	-- 获取 p_minnastart 插件实例
	local minnastartInst = g_manykit:GetPluginTreeInstanceByName("p_minnastart")
	if not minnastartInst then
		return
	end
	
	-- 检查所有服务的健康状态
	local allHealthy = minnastartInst._healthRedis and 
	                   minnastartInst._healthMongoDB and
	                   minnastartInst._healthMinnaJS
	
	-- 根据健康状态切换显示
	if allHealthy then
		-- 所有服务正常，显示网页
		if self._textFrame then
			self._textFrame:Show(false)
		end
		if self._webFrame then
			-- 构建 URL
			local ipminna = minnastartInst._ipminna or "127.0.0.1"
			local url = "http://"..ipminna..":6700"
			
			-- 只在状态变化或 URL 变化时才设置 URL，避免重复刷新
			if not self._isWebFrameShown or self._currentURL ~= url then
				self._webFrame:SetURL(url)
				self._currentURL = url
			end
			
			if not self._isWebFrameShown then
				self._webFrame:Show(true)
				self._isWebFrameShown = true
			end
		end
	else
		-- 服务未就绪，显示文本
		if self._textFrame then
			self._textFrame:Show(true)
		end
		if self._webFrame and self._isWebFrameShown then
			self._webFrame:Show(false)
			self._isWebFrameShown = false
		end
	end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_minna)
-------------------------------------------------------------------------------