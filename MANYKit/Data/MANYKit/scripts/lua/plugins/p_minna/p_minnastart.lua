-- p_minnastart.lua

p_minnastart = class(p_ctrl,
{
	_name = "p_minnastart",

	_requires = {"p_holospace", "p_net", },

	-- ui
	_frameContent = nil,
	_propertyGridInfo = nil,
    _framePicBoxBack = nil,
    _framePicBox = nil,
	_updateFrame = nil,  -- 更新进度 Frame
	_updateProgressBar = nil,  -- 更新进度条
	_updateStatusText = nil,  -- 更新状态文本
	_updateCurrentFileText = nil,  -- 当前下载文件文本

	-- 开关状态
	_minnaJSEnabled = 0,
	_ollamaEnabled = 0,
	_sttEnabled = 0,
	_indexTTSEnabled = 0,
	_mongoDBEnabled = 0,
	_redisEnabled = 0,

	-- 进程配置
	_processConfig = nil,
	
	-- 公用路径
    _urlreadmedoc = "https://manykitty.feishu.cn/wiki/KtvFwXeEti7IFyk4Yyvcb3i0nwf",
	_basePath = "E:/MANYKit/minna_ext/",
    _urlmanykitminna = "http://manykit.com/minna",
    _ipminna = "127.0.0.1",
    _portminna = "6700",
	
	-- 状态（显示用）
	_healthStatusRedis = "未知",
	_healthStatusMongoDB = "未知",
	_healthStatusASR = "未知",
	_healthStatusMinnaJS = "未知",
	_healthStatusIndexTTS = "未知",
	
	-- 状态（布尔值，用于判断）
	_healthRedis = false,
	_healthMongoDB = false,
	_healthASR = false,
	_healthMinnaJS = false,
	_healthIndexTTS = false,
    
	_healthCheckTimer = 4.0,
	_healthCheckInterval = 5.0,  -- 每3秒检查一次
	
	-- 文件更新相关
	_maxConcurrentDownloads = 3,  -- 最大并发下载数量
	_activeDownloads = 0,  -- 当前正在下载的数量
	_completedDownloads = 0,  -- 已完成的下载数量
	_completedFileSet = {},  -- 已完成的文件集合（用于防止重复计数）
})
-------------------------------------------------------------------------------
function p_minnastart:OnAttached()
	PX2_LM_APP:AddItem(self._name, "minnastart", "启动")
	
	print(self._name.." p_minnastart:OnAttached")
    p_ctrl.OnAttached(self)

	-- 读取公用路径配置
	local basePath = PX2_PROJ:GetConfig("minna_path")
	if basePath == "" then
		basePath = "E:/MANYKit/minna_ext/"
	end
	self._basePath = basePath

	-- 读取 IPMinna 配置
	local ipminna = PX2_PROJ:GetConfig("minna_ipminna")
	if ipminna ~= "" then
		self._ipminna = ipminna
	end

	-- 初始化进程配置
	self:_InitProcessConfig()

	self:_CreateContentFrame()
end
-------------------------------------------------------------------------------
function p_minnastart:OnInitUpdate()
	p_ctrl.OnInitUpdate(self)

	print(self._name.." p_minnastart:OnInitUpdate")
end
-------------------------------------------------------------------------------
function p_minnastart:_Cleanup()
	print(self._name.." p_minnastart:_Cleanup")
	PX2_OPENCVM:SetScriptCallback("", nil)
	
	-- 清理时终止所有进程
	self:_TerminateAllProcesses()
end

function p_minnastart:OnPPlay()
	print(self._name.." p_minnastart:OnPPlay")
end
-------------------------------------------------------------------------------
function p_minnastart:OnPUpdate()
    local secs = PX2_APP:GetElapsedSecondsWidthSpeed()

    --print("secs:"..secs)
    --print("self._healthCheckTimer:"..self._healthCheckTimer)
    --print("self._healthCheckInterval:"..self._healthCheckInterval)

	-- 定期检查健康状态
	if self._healthCheckTimer >= self._healthCheckInterval then
		self._healthCheckTimer = 0.0
		self:_RequestHealthStatus()
	else
		self._healthCheckTimer = self._healthCheckTimer + secs
	end

    if self._framePicBoxBack then
        self._framePicBoxBack:AutoMakeSizeFixable(1)
    end

    if self._framePicBox then
        self._framePicBox:AutoMakeSizeFixable(0.4)
    end
end
-------------------------------------------------------------------------------
function p_minnastart:OnPluginInstanceSelected(act)
	print(self._name.." p_minnastart:OnPluginInstanceSelected")
    if act then print("1") else print("0") end

    p_ctrl.OnPluginInstanceSelected(self, act)

    if act then
        self:_UpdateProcessStates()
        self:_RegistOnPropertyInfo()
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_InitProcessConfig()
    print(self._name.." p_minnastart:_InitProcessConfig")
    
    local basePath = self._basePath
    -- 确保路径以 / 结尾
    if string.sub(basePath, -1) ~= "/" and string.sub(basePath, -1) ~= "\\" then
        basePath = basePath .. "/"
    end
    
    self._processConfig = {
        STT = {
            name = "STT-ASRWorker",
            path = basePath.."manykit-minna/python_apps/asr-worker/app.exe",
            workDir = basePath.."manykit-minna/python_apps/asr-worker/"
        },
        Redis = {
            name = "Redis",
            path = basePath.."manykit-minna/tools/redis64/redis-server.exe",
            workDir = basePath.."manykit-minna/tools/redis64/"
        },
        MongoDB = {
            name = "MongoDB",
            path = basePath.."manykit-minna/MongoDB/Server/3.2/bin/mongod.exe --auth --storageEngine=mmapv1 --dbpath mdata/",
            workDir = basePath.."manykit-minna/dbstart/"
        },
        MinnaJS = {
            name = "MinnaJS",
            path = basePath.."manykit-minna/minna.exe",
            workDir = basePath.."manykit-minna/"
        },
        Ollama = {
            name = "Ollama",
            path = basePath.."Ollama/ollama-serve.bat",
            workDir = basePath.."Ollama/",
            actualProcessName = "ollama.exe"
        },
        IndexTTS = {
            name = "IndexTTS",
            path = basePath.."indextts/start_webui.bat",
            workDir = basePath.."indextts/",
            actualProcessName = "indextts.exe"
        }
    }
end
-------------------------------------------------------------------------------
function p_minnastart:_UpdateProcessStates()
    print(self._name.." p_minnastart:_UpdateProcessStates")
    
    -- 检查每个进程的运行状态并更新开关状态
    if self._processConfig then
        if PX2_APP:IsProcessRunning(self._processConfig.MinnaJS.name) then
            self._minnaJSEnabled = 1
        else
            self._minnaJSEnabled = 0
        end
        
        -- Ollama 使用实际进程名称检查
        if self._processConfig.Ollama.actualProcessName then
            if PX2_APP:IsProcessRunningByActualName(self._processConfig.Ollama.actualProcessName) then
                self._ollamaEnabled = 1
            else
                self._ollamaEnabled = 0
            end
        else
            if PX2_APP:IsProcessRunning(self._processConfig.Ollama.name) then
                self._ollamaEnabled = 1
            else
                self._ollamaEnabled = 0
            end
        end
        
        if PX2_APP:IsProcessRunning(self._processConfig.STT.name) then
            self._sttEnabled = 1
        else
            self._sttEnabled = 0
        end
        
        if PX2_APP:IsProcessRunning(self._processConfig.IndexTTS.name) then
            self._indexTTSEnabled = 1
        else
            self._indexTTSEnabled = 0
        end
        
        if PX2_APP:IsProcessRunning(self._processConfig.MongoDB.name) then
            self._mongoDBEnabled = 1
        else
            self._mongoDBEnabled = 0
        end
        
        if PX2_APP:IsProcessRunning(self._processConfig.Redis.name) then
            self._redisEnabled = 1
        else
            self._redisEnabled = 0
        end
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_StartProcess(processName)
    print(self._name.." p_minnastart:_StartProcess: "..processName)
    
    if not self._processConfig then
        print("Process config not initialized")
        return false
    end
    
    local config = self._processConfig[processName]
    if not config then
        print("Process config not found: "..processName)
        return false
    end
    
    -- 检查进程是否已经在运行（如果有 actualProcessName，使用新接口）
    local isRunning = false
    if config.actualProcessName then
        isRunning = PX2_APP:IsProcessRunningByActualName(config.actualProcessName)
        if isRunning then
            print("Process already running: "..config.actualProcessName)
        end
    else
        isRunning = PX2_APP:IsProcessRunning(config.name)
        if isRunning then
            print("Process already running: "..config.name)
        end
    end
    if isRunning then
        return true
    end

    if "MongoDB" == processName then
        local basePath = self._basePath
        if string.sub(basePath, -1) ~= "/" and string.sub(basePath, -1) ~= "\\" then
            basePath = basePath .. "/"
        end
        local lockFilePath = basePath.."manykit-minna/dbstart/mdata/mongod.lock"
        local f = File(lockFilePath)
        if f:IsExists() then
            print("MongoDB lock file exists, deleting...")
            f:Delete()
            print("MongoDB lock file deleted")
        else
            print("MongoDB lock file does not exist")
        end
    end
    
    -- 启动进程，传入工作目录（如果为空字符串则不传入）
    local workDir = config.workDir or ""
    if workDir == "" then
        PX2_APP:RunFileHidden(config.name, config.path)
    else
        PX2_APP:RunFileHidden(config.name, config.path, workDir)
    end
    print("Started process: "..config.name.." with path: "..config.path)
    if workDir ~= "" then
        print("Working directory: "..workDir)
    end
    
    return true
end
-------------------------------------------------------------------------------
function p_minnastart:_StopProcess(processName)
    print(self._name.." p_minnastart:_StopProcess: "..processName)
    
    if not self._processConfig then
        print("Process config not initialized")
        return false
    end
    
    local config = self._processConfig[processName]
    if not config then
        print("Process config not found: "..processName)
        return false
    end
    
    -- 检查进程是否在运行（如果有 actualProcessName，使用新接口）
    local isRunning = false
    if config.actualProcessName then
        isRunning = PX2_APP:IsProcessRunningByActualName(config.actualProcessName)
        if not isRunning then
            print("Process not running: "..config.actualProcessName)
            return true
        end
    else
        isRunning = PX2_APP:IsProcessRunning(config.name)
        if not isRunning then
            print("Process not running: "..config.name)
            return true
        end
    end
    
    -- 终止进程（如果有 actualProcessName，使用新接口）
    local result = false
    if config.actualProcessName then
        result = PX2_APP:TerminateProcessByActualName(config.actualProcessName)
        if result then
            print("Terminated process: "..config.actualProcessName)
        else
            print("Failed to terminate process: "..config.actualProcessName)
        end
    else
        result = PX2_APP:TerminateProcess(config.name)
        if result then
            print("Terminated process: "..config.name)
        else
            print("Failed to terminate process: "..config.name)
        end
    end
    
    return result
end
-------------------------------------------------------------------------------
function p_minnastart:_TerminateAllProcesses()
    print(self._name.." p_minnastart:_TerminateAllProcesses")
    
    if not self._processConfig then
        return
    end
    
    -- 终止所有进程
    for processName, config in pairs(self._processConfig) do
        local isRunning = false
        if config.actualProcessName then
            isRunning = PX2_APP:IsProcessRunningByActualName(config.actualProcessName)
            if isRunning then
                PX2_APP:TerminateProcessByActualName(config.actualProcessName)
                print("Terminated process: "..config.actualProcessName)
            end
        else
            isRunning = PX2_APP:IsProcessRunning(config.name)
            if isRunning then
                PX2_APP:TerminateProcess(config.name)
                print("Terminated process: "..config.name)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_RequestHealthStatus()
    print(self._name.." p_minnastart:_RequestHealthStatus")

    -- 构建健康检查 URL
    local url = "http://"..self._ipminna..":6700/health"
    
    -- 发送 HTTP GET 请求
    local curlObj = CurlObj:NewThread()
    curlObj:SetTimeOutSeconds(2.0)
    curlObj:Get(url, "_OnHealthStatusResponse", self._scriptControl)
    
    -- 同时请求 IndexTTS 健康状态
    self:_RequestIndexTTSHealthStatus()
end
-------------------------------------------------------------------------------
function p_minnastart:_RequestIndexTTSHealthStatus()
    -- 构建 IndexTTS 健康检查 URL
    local url = "http://127.0.0.1:7861/health"
    
    -- 发送 HTTP GET 请求
    local curlObj = CurlObj:NewThread()
    curlObj:SetTimeOutSeconds(2.0)
    curlObj:Get(url, "_OnIndexTTSHealthStatusResponse", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_minnastart:_OnIndexTTSHealthStatusResponse(ptr)
    local curlObj = Cast:ToO(ptr)

    if curlObj:IsThreadRunOK() then
        local runRet = curlObj:GetThreadRunedResult()        
        print("runRet:"..runRet)

        if 0==runRet then
            if curlObj:IsGettedOK() then
                local strMem = curlObj:GetGettedString()
                print("IndexTTS health status response: "..strMem)
                
                local dt = PX2JSon.decode(strMem)
                if dt and dt.status then
                    if dt.status == "healthy" then
                        self._healthStatusIndexTTS = "已连接"
                        self._healthIndexTTS = true
                    else
                        self._healthStatusIndexTTS = "未连接"
                        self._healthIndexTTS = false
                    end
                else
                    self._healthStatusIndexTTS = "未连接"
                    self._healthIndexTTS = false
                end
                
                self:_RefreshHealthStatus()
            end
        else
            self._healthStatusIndexTTS = "未连接"
            self._healthIndexTTS = false
            self:_RefreshHealthStatus()
        end
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_OnHealthStatusResponse(ptr)
    local curlObj = Cast:ToO(ptr)

    if curlObj:IsThreadRunOK() then
        local runRet = curlObj:GetThreadRunedResult()        
        print("runRet:"..runRet)

        if 0==runRet then
            if curlObj:IsGettedOK() then
                local strMem = curlObj:GetGettedString()
                print("Health status response: "..strMem)
                
                -- 如果能请求到 health，说明 MinnaJS 运行正常
                self._healthStatusMinnaJS = "已连接"
                self._healthMinnaJS = true
                
                local dt = PX2JSon.decode(strMem)
                if dt and dt.data then
                    -- 更新 Redis 状态
                    if dt.data.redis then
                        if dt.data.redis.connected then
                            self._healthStatusRedis = "已连接"
                            self._healthRedis = true
                        else
                            self._healthStatusRedis = "未连接"
                            self._healthRedis = false
                        end
                    else
                        self._healthStatusRedis = "未连接"
                        self._healthRedis = false
                    end
                    
                    -- 更新 MongoDB 状态
                    if dt.data.mongodb then
                        if dt.data.mongodb.connected then
                            self._healthStatusMongoDB = "已连接"
                            self._healthMongoDB = true
                        else
                            self._healthStatusMongoDB = "未连接"
                            self._healthMongoDB = false
                        end
                    else
                        self._healthStatusMongoDB = "未连接"
                        self._healthMongoDB = false
                    end
                    
                    -- 更新 ASR 状态
                    if dt.data.aitalk_numasrworks then
                        local asrCount = dt.data.aitalk_numasrworks
                        if asrCount and asrCount > 0 then
                            self._healthStatusASR = "已连接 ("..asrCount..")"
                            self._healthASR = true
                        else
                            self._healthStatusASR = "未连接"
                            self._healthASR = false
                        end
                    else
                        self._healthStatusASR = "未连接"
                        self._healthASR = false
                    end
                    
                    -- 刷新属性显示
                    self:_RefreshHealthStatus()
                else
                    print("Failed to parse health status response")
                    self._healthStatusMinnaJS = "错误"
                    self._healthStatusRedis = "错误"
                    self._healthStatusMongoDB = "错误"
                    self._healthStatusASR = "错误"
                    self._healthMinnaJS = false
                    self._healthRedis = false
                    self._healthMongoDB = false
                    self._healthASR = false
                    self:_RefreshHealthStatus()
                end
            end
        else
            print("Failed to get health status")
            self._healthStatusMinnaJS = "未连接"
            self._healthStatusRedis = "未连接"
            self._healthStatusMongoDB = "未连接"
            self._healthStatusASR = "未连接"
            self._healthMinnaJS = false
            self._healthRedis = false
            self._healthMongoDB = false
            self._healthASR = false
            self:_RefreshHealthStatus()
        end
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_RefreshHealthStatus()
    if not self._propertyGridInfo then
        return
    end
    
    self._scriptControl:BeginPropertyCata("MinnaStart")
    self._scriptControl:AddPropertyClass("Status", "状态")  
    self._scriptControl:AddPropertyString("StatusRedis", "Redis状态", self._healthStatusRedis, false, false)
    self._scriptControl:AddPropertyString("StatusMongoDB", "MongoDB状态", self._healthStatusMongoDB, false, false)
    self._scriptControl:AddPropertyString("StatusMinnaJS", "MinnaJS状态", self._healthStatusMinnaJS, false, false)
    self._scriptControl:AddPropertyString("StatusASR", "ASR状态", self._healthStatusASR, false, false)
    self._scriptControl:AddPropertyString("StatusIndexTTS", "IndexTTS状态", self._healthStatusIndexTTS, false, false)
    self._scriptControl:EndPropertyCata()
    
    self._propertyGridInfo:UpdateOnObject(self._scriptControl, "MinnaStart", "StatusMinnaJS")
    self._propertyGridInfo:UpdateOnObject(self._scriptControl, "MinnaStart", "StatusRedis")
    self._propertyGridInfo:UpdateOnObject(self._scriptControl, "MinnaStart", "StatusMongoDB")
    self._propertyGridInfo:UpdateOnObject(self._scriptControl, "MinnaStart", "StatusASR")
    self._propertyGridInfo:UpdateOnObject(self._scriptControl, "MinnaStart", "StatusIndexTTS")
end
-------------------------------------------------------------------------------
function p_minnastart:_UpdateEnvFile(newIP)
    print(self._name.." p_minnastart:_UpdateEnvFile: "..newIP)
    
    -- 构建 .env 文件路径
    local basePath = self._basePath
    if string.sub(basePath, -1) ~= "/" and string.sub(basePath, -1) ~= "\\" then
        basePath = basePath .. "/"
    end
    local envFilePath = basePath.."manykit-minna/.env"
    
    -- 读取 .env 文件
    local fileContent = FileIO:Load(envFilePath, true)
    if fileContent == "" then
        print("Warning: .env file is empty or does not exist: "..envFilePath)
        return false
    end
    
    print("Original .env content loaded")
    
    -- 从 MINNA_WEBURL 中提取端口号（如果有的话）
    local port = "6700"  -- 默认端口
    local weburlPattern = 'MINNA_WEBURL%s*=%s*"http://[^:]+:(%d+)/"'
    local extractedPort = string.match(fileContent, weburlPattern)
    if extractedPort then
        port = extractedPort
    end
    
    -- 替换 MINNA_WEBURL
    local newWebURL = 'MINNA_WEBURL = "http://'..newIP..':'..port..'/"'
    fileContent = string.gsub(fileContent, 'MINNA_WEBURL%s*=%s*"[^"]*"', newWebURL)
    
    -- 替换 MINNA_IP
    local newIPLine = 'MINNA_IP="'..newIP..'"'
    fileContent = string.gsub(fileContent, 'MINNA_IP%s*=%s*"[^"]*"', newIPLine)
    
    -- 保存文件
    local saveResult = FileIO:Save(envFilePath, fileContent)
    if saveResult then
        print("Successfully updated .env file with new IP: "..newIP)
        return true
    else
        print("Failed to save .env file")
        return false
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_CreateContentFrame()
	print(self._name.." p_minnastart:_CreateContentFrame")

	local frame = UIFrame:New()
    self._frameContent = frame
    self._frame:AttachChild(frame)
	frame:LLY(-1.0)
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
	local back = frame:CreateAddBackgroundPicBox(true, Float3(0.0, 0.0, 0.0))
    back:UseAlphaBlend(true)
    back:SetAlpha(0.65)

    --[[
    local framePicBox = UIFrame:New("FramePicBox")
    frame:AttachChild(framePicBox)
    framePicBox:LLY(-1.0)
    framePicBox:SetAnchorHor(0.0, 1.0)
    framePicBox:SetAnchorVer(1.0, 1.0)
    framePicBox:SetPivot(0.5, 1.0)
    framePicBox:SetSize(0.0, 100.0)
    framePicBox:CreateAddBackgroundPicBox(true, Float3(1.0, 1.0, 1.0))

    local fPicBoxBack = UIFPicBox:New("FPicBoxMinnaBack")
    self._framePicBoxBack = fPicBoxBack
	framePicBox:AttachChild(fPicBoxBack)
	fPicBoxBack:LLY(-1.0)
	fPicBoxBack:GetUIPicBox():SetTexture("scripts/lua/plugins/p_minna/minnback.png")

    local fPicBox = UIFPicBox:New("FPicBoxMinna")
    self._framePicBox = fPicBox
	framePicBox:AttachChild(fPicBox)
    fPicBox:SetAnchorHor(0.5, 0.5)
    fPicBox:SetAnchorVer(0.5, 0.5)
	fPicBox:LLY(-2.0)
	fPicBox:GetUIPicBox():SetTexture("scripts/lua/plugins/p_minna/minna.png")
    ]]--

    local pg = UIPropertyGrid:New("PropertyGridInfo")
    self._propertyGridInfo = pg
    frame:AttachChild(pg)
    pg:CreateAddBackgroundPicBox(true, Float3(0.0, 0.0, 0.0))
    pg:LLY(-5.0)
    pg:SetSliderSize(g_manykit._hBtn)
    pg:SetItemHeight(g_manykit._hBtn-5.0)
    pg:CreateRoot()
    pg:ShowRootItem(false)
    pg:SetAnchorHor(0.0, 1.0)
    pg:SetAnchorVer(0.0, 1.0)
    pg:SetAnchorParamVer(0.0, 0.0)
    pg:SetIconArrowSpace(24.0)
    pg:SetLevelSpace(20.0)
    pg:SetScriptHandler("_UICallback", self._scriptControl)
    pg:GetUISplitterFrame():SetAnchorHor(0.45, 0.45)
    	
    local frameUpdate = self:_CreateUpdateFrame()
	self._updateFrame = frameUpdate
	frame:AttachChild(frameUpdate)
    frameUpdate:LLY(-20.0)
    frameUpdate:SetAnchorHor(0.0, 1.0)
    frameUpdate:SetAnchorVer(0.0, 1.0)
    frameUpdate:Show(false)

	self._scriptControl:ResetPlay()
end
-------------------------------------------------------------------------------
function p_minnastart:_GetVersionFromFilelist(workDir)
    -- 构建 filelist.xml 文件路径
    local filelistPath = workDir .. "filelist.xml"
    
    -- 读取文件内容
    local fileContent = FileIO:Load(filelistPath, true)
    if fileContent == "" then
        return ""
    end
    
    -- 使用正则表达式提取版本号
    local version = string.match(fileContent, 'version%s*=%s*"([^"]+)"')
    if version then
        return version
    end
    
    return ""
end
-------------------------------------------------------------------------------
function p_minnastart:_RegistOnPropertyInfo()
    print(self._name.." p_minnastart:_RegistOnPropertyInfo")

    self._scriptControl:RemoveProperties("MinnaStart")

    self._scriptControl:BeginPropertyCata("MinnaStart")

    self._scriptControl:AddPropertyClass("Version", "版本更新")
    self._scriptControl:AddPropertyButton("ReadMeDoc", "文档", "查看文档")
    self._scriptControl:AddPropertyString("UrlManykitMinna", "UrlManykitMinna", self._urlmanykitminna, false, false)
	self._scriptControl:AddPropertyButton("BtnUpdateFiles", "MinnaJS检查更新", "检查更新")

    self._scriptControl:AddPropertyClass("Settings", "设置")

    self._scriptControl:AddPropertyString("BasePath", "主路径", self._basePath, true, false)

    local iptabs = {"127.0.0.1"}
	local numAddr = PX2_APP:GetLocalAddressSize()
    for i=0, numAddr-1, 1 do
        local ip = PX2_APP:GetLocalAddressStr(i)
        if ""~=ip then
            table.insert(iptabs, #iptabs + 1, ip)
        end
    end
    PX2Table2Vector(iptabs)
	local vec = PX2_GH:Vec()
	PX2Table2Vector(iptabs)
	local vec1 = PX2_GH:Vec()
	PX2Table2Vector({})
	local vec2 = PX2_GH:Vec()
	self._scriptControl:AddPropertyEnumUserData1("IPMinna", "IPMinna", self._ipminna, vec, vec1, vec2, true, false)
	self._scriptControl:AddPropertyInt("PortMinna", "PortMinna", self._portminna, false, false)
    self._scriptControl:AddPropertyButton("OpenMinnaJS", "OpenMinnaJS", "打开MinnaJS")

    self._scriptControl:AddPropertyClass("Start", "开启")
    
    PX2Table2Vector({"关闭", "开启"})
    local vec = PX2_GH:Vec()
    PX2Table2Vector({"0", "1"})
    local vec1 = PX2_GH:Vec()
    PX2Table2Vector({})
    local vec2 = PX2_GH:Vec()

    -- 获取三个服务的版本号
    local minnaJSVersion = ""
    local ollamaVersion = ""
    local indexTTSVersion = ""
    
    if self._processConfig then
        if self._processConfig.MinnaJS and self._processConfig.MinnaJS.workDir then
            minnaJSVersion = self:_GetVersionFromFilelist(self._processConfig.MinnaJS.workDir)
        end
        if self._processConfig.Ollama and self._processConfig.Ollama.workDir then
            ollamaVersion = self:_GetVersionFromFilelist(self._processConfig.Ollama.workDir)
        end
        if self._processConfig.IndexTTS and self._processConfig.IndexTTS.workDir then
            indexTTSVersion = self:_GetVersionFromFilelist(self._processConfig.IndexTTS.workDir)
        end
    end
    
    -- 构建带版本号的标题
    local minnaJSTitle = "MinnaJS(Minna主服务)"
    local ollamaTitle = "Ollama(AI大模型)"
    local indexTTSTitle = "IndexTTS(语音转文字)"
    
    if minnaJSVersion ~= "" then
        minnaJSTitle = minnaJSTitle .. " v" .. minnaJSVersion
    end
    if ollamaVersion ~= "" then
        ollamaTitle = ollamaTitle .. " v" .. ollamaVersion
    end
    if indexTTSVersion ~= "" then
        indexTTSTitle = indexTTSTitle .. " v" .. indexTTSVersion
    end

    -- 添加六个开启/关闭属性
    self._scriptControl:AddPropertyEnumUserData("Redis", "MinnaJS-Redis(数据库)", self._redisEnabled, vec, vec1, vec2, true, true)
    self._scriptControl:AddPropertyEnumUserData("MongoDB", "MinnaJS-MongoDB(数据库)", self._mongoDBEnabled, vec, vec1, vec2, true, true)
    self._scriptControl:AddPropertyEnumUserData("STT", "MinnaJS-STT(文字转语音)", self._sttEnabled, vec, vec1, vec2, true, true)
    self._scriptControl:AddPropertyEnumUserData("MinnaJS", minnaJSTitle, self._minnaJSEnabled, vec, vec1, vec2, true, true)
    self._scriptControl:AddPropertyEnumUserData("Ollama", ollamaTitle, self._ollamaEnabled, vec, vec1, vec2, true, true)
    self._scriptControl:AddPropertyEnumUserData("IndexTTS", indexTTSTitle, self._indexTTSEnabled, vec, vec1, vec2, true, true)

    self._scriptControl:AddPropertyClass("Status", "状态")
    self._scriptControl:AddPropertyString("StatusMinnaJS", "MinnaJS状态", self._healthStatusMinnaJS, false, false)
    self._scriptControl:AddPropertyString("StatusRedis", "Redis状态", self._healthStatusRedis, false, false)
    self._scriptControl:AddPropertyString("StatusMongoDB", "MongoDB状态", self._healthStatusMongoDB, false, false)
    self._scriptControl:AddPropertyString("StatusASR", "ASR状态", self._healthStatusASR, false, false)
    self._scriptControl:AddPropertyString("StatusIndexTTS", "IndexTTS状态", self._healthStatusIndexTTS, false, false)

    self._scriptControl:EndPropertyCata()

    self._propertyGridInfo:RegistOnObject(self._scriptControl, "MinnaStart")
end
-------------------------------------------------------------------------------
function p_minnastart:_UICallback(ptr, callType)
    local obj = Cast:ToO(ptr)
    local name = obj:GetName()

    if UICT_PRESSED == callType then
        PX2_GH:PlayScale(obj)
    elseif UICT_RELEASED == callType then
        PX2_GH:PlayNormal(obj)
    elseif UICT_PROPERTY_CHANGED == callType then
        print("UICT_PROPERTY_CHANGED "..name)
        if "PropertyGridInfo" == name then
            local pObj = obj:GetPorpertyObject()
            print("obj.Name:"..pObj.Name)

            if "MinnaJS" == pObj.Name then
                local newValueStr = self._scriptControl:PEnumData2("MinnaJS")
                local newValue = StringHelp:StringToInt(newValueStr)
                if newValue ~= self._minnaJSEnabled then
                    self._minnaJSEnabled = newValue
                    print("MinnaJS: "..self._minnaJSEnabled)
                    if self._minnaJSEnabled == 1 then
                        self:_StartProcess("MinnaJS")
                    else
                        self:_StopProcess("MinnaJS")
                    end
                end
            elseif "Ollama" == pObj.Name then
                local newValueStr = self._scriptControl:PEnumData2("Ollama")
                local newValue = StringHelp:StringToInt(newValueStr)
                if newValue ~= self._ollamaEnabled then
                    self._ollamaEnabled = newValue
                    print("Ollama: "..self._ollamaEnabled)
                    if self._ollamaEnabled == 1 then
                        self:_StartProcess("Ollama")
                    else
                        self:_StopProcess("Ollama")
                    end
                end
            elseif "STT" == pObj.Name then
                local newValueStr = self._scriptControl:PEnumData2("STT")
                local newValue = StringHelp:StringToInt(newValueStr)
                if newValue ~= self._sttEnabled then
                    self._sttEnabled = newValue
                    print("STT: "..self._sttEnabled)
                    if self._sttEnabled == 1 then
                        self:_StartProcess("STT")
                    else
                        self:_StopProcess("STT")
                    end
                end
            elseif "IndexTTS" == pObj.Name then
                local newValueStr = self._scriptControl:PEnumData2("IndexTTS")
                local newValue = StringHelp:StringToInt(newValueStr)
                if newValue ~= self._indexTTSEnabled then
                    self._indexTTSEnabled = newValue
                    print("IndexTTS: "..self._indexTTSEnabled)
                    if self._indexTTSEnabled == 1 then
                        self:_StartProcess("IndexTTS")
                    else
                        self:_StopProcess("IndexTTS")
                    end
                end
            elseif "MongoDB" == pObj.Name then
                local newValueStr = self._scriptControl:PEnumData2("MongoDB")
                local newValue = StringHelp:StringToInt(newValueStr)
                if newValue ~= self._mongoDBEnabled then
                    self._mongoDBEnabled = newValue
                    print("MongoDB: "..self._mongoDBEnabled)
                    if self._mongoDBEnabled == 1 then
                        self:_StartProcess("MongoDB")
                    else
                        self:_StopProcess("MongoDB")
                    end
                end
            elseif "Redis" == pObj.Name then
                local newValueStr = self._scriptControl:PEnumData2("Redis")
                local newValue = StringHelp:StringToInt(newValueStr)
                if newValue ~= self._redisEnabled then
                    self._redisEnabled = newValue
                    print("Redis: "..self._redisEnabled)
                    if self._redisEnabled == 1 then
                        self:_StartProcess("Redis")
                    else
                        self:_StopProcess("Redis")
                    end
                end
            elseif "BasePath" == pObj.Name then
                local newBasePath = pObj:PString()
                if newBasePath ~= self._basePath then
                    self._basePath = newBasePath
                    PX2_PROJ:SetConfig("minna_path", newBasePath)
                    print("BasePath changed to: "..newBasePath)
                    -- 重新初始化进程配置
                    self:_InitProcessConfig()
                end
            elseif "IPMinna" == pObj.Name then
                local newIP = pObj:PString()
                if newIP ~= self._ipminna then
                    self._ipminna = newIP
                    PX2_PROJ:SetConfig("minna_ipminna", newIP)
                    print("IPMinna changed to: "..newIP)
                    -- 更新 .env 文件
                    self:_UpdateEnvFile(newIP)
                end
            elseif "BtnUpdateFiles" == pObj.Name then
                -- 先弹出确认对话框
                manykit_ShowInfoPopUp("check", "确定要检查更新吗？", "manykit_ConfirmUpdateFiles()", "")
            elseif "ReadMeDoc" == pObj.Name then
                PX2_APP:OpenURL(self._urlreadmedoc)
            elseif "OpenMinnaJS" == pObj.Name then
                -- 检查 MinnaJS 连接状态
                if self._healthMinnaJS then
                    -- 已连接，打开网页
                    local url = "http://"..self._ipminna..":"..self._portminna
                    PX2_APP:OpenURL(url)
                else
                    -- 未连接，弹窗提示
                    manykit_ShowInfoPopUp("info", "当前未连接，未启动", "", "")
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_StartUpdateFiles()
    print(self._name.." p_minnastart:_StartUpdateFiles")
    
    -- 确保 basePath 以 / 结尾
    local basePath = self._basePath
    if string.sub(basePath, -1) ~= "/" and string.sub(basePath, -1) ~= "\\" then
        basePath = basePath .. "/"
    end
    
    -- MinnaJS 的工作目录
    local workDir = basePath.."manykit-minna/"
    if self._processConfig and self._processConfig.MinnaJS and self._processConfig.MinnaJS.workDir then
        workDir = self._processConfig.MinnaJS.workDir
    end
    
    -- 构建远程 filelist.xml 的 URL 和本地路径
    local baseURL = self._urlmanykitminna.."/ota/Achieve/manykit-minna/"
    --local baseURL = "http://"..self._ipminna..":" .. self._portminna .. "/ota/Achieve/manykit-minna/"
    local filelistURL = baseURL .. "filelist.xml"
    local filelistTempPath = workDir .. "filelist_temp.xml"
    
    print("Downloading remote filelist.xml to: "..filelistTempPath)
    print("From URL: "..filelistURL)
    
    -- 保存 baseURL 和 workDir 供后续使用
    self._updateBaseURL = baseURL
    self._updateWorkDir = workDir

    coroutine.wrap(function()
        self:_UpdateProgressText("正在下载 filelist.xml...", "")
        self:_ShowUpdateFrame()
        sleep(1.0)
        local curlObj = CurlObj:NewThread("DownloadFilelistTemp")
        curlObj:SetTimeOutSeconds(30.0)
        curlObj:Download(filelistURL, filelistTempPath, "_OnFilelistTempDownloaded", self._scriptControl)
    end)()
end
-------------------------------------------------------------------------------
function p_minnastart:_OnFilelistTempDownloaded(ptr)
    local curlObj = Cast:ToO(ptr)

    local runRet = curlObj:GetThreadRunedResult()        
    print("runRettttttttttttttttttttttttttttt:"..runRet)

    if curlObj:IsGettedOK() then
        local filelistTempPath = self._updateWorkDir .. "filelist_temp.xml"
        
        print("Filelist_temp.xml downloaded successfully")
        
        -- 读取并解析 filelist_temp.xml
        local filelistContent = FileIO:Load(filelistTempPath, true)
        if filelistContent == "" then
            print("ERROR: filelist_temp.xml is empty or does not exist")
            return
        end
        
        print("Parsing filelist_temp.xml, length: "..string.len(filelistContent))
        
        -- 获取远程版本号
        local remoteVersion = string.match(filelistContent, 'version%s*=%s*"([^"]+)"')
        if not remoteVersion then
            remoteVersion = ""
        end
        
        -- 获取本地版本号
        local localVersion = self:_GetVersionFromFilelist(self._updateWorkDir)
        
        print("Remote version: "..remoteVersion)
        print("Local version: "..localVersion)
        
        -- 比较版本号
        if remoteVersion ~= "" and localVersion ~= "" and remoteVersion == localVersion then
            print("Version is the same, no update needed")
            self:_UpdateProgressText("版本号相同，无需更新", "")
            self:_HideUpdateFrame()
            -- 显示提示信息
            manykit_ShowInfoPopUp("info", "已是最新版本，无需更新", "", "")
            return
        end
        
        self:_UpdateProgressText("filelist_temp.xml 下载完成，正在解析文件列表...", "")

        -- 解析远程 filelist.xml
        local remoteFiles = self:_ParseFilelist(filelistContent)
        if remoteFiles then
            -- 比对并下载文件
            self:_CompareAndDownloadFiles(remoteFiles)
        else
            print("Failed to parse filelist_temp.xml")
        end
    else
        print("Failed to download filelist_temp.xml")
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_ParseFilelist(filelistContent)
    print(self._name.." p_minnastart:_ParseFilelist")
    
    if filelistContent == "" then
        return nil
    end
    
    local files = {}
    
    -- 使用正则表达式提取所有文件信息
    -- 匹配格式: <file filename="xxx" md5="xxx"/> 或 <file filename="xxx" md5="xxx"></file>
    -- 支持属性顺序可能不同，以及可能的换行和空格
    for filename, md5 in string.gmatch(filelistContent, '<file[^>]*filename%s*=%s*"([^"]+)"[^>]*md5%s*=%s*"([^"]+)"') do
        files[filename] = md5
        print("Found file0: "..filename.." md5: "..md5)
    end
    
    -- 如果上面的匹配失败，尝试另一种格式（md5在前）
    if next(files) == nil then
        for md5, filename in string.gmatch(filelistContent, '<file[^>]*md5%s*=%s*"([^"]+)"[^>]*filename%s*=%s*"([^"]+)"') do
            files[filename] = md5
            print("Found file1 (reverse order): "..filename.." md5: "..md5)
        end
    end
    
    return files
end
-------------------------------------------------------------------------------
function p_minnastart:_CompareAndDownloadFiles(remoteFiles)
    print(self._name.." p_minnastart:_CompareAndDownloadFiles")
    
    if not remoteFiles then
        return
    end
    
    local workDir = self._updateWorkDir
    local baseURL = self._updateBaseURL
    
    if not workDir or not baseURL then
        print("ERROR: workDir or baseURL not set")
        return
    end
    
    -- 使用协程读取本地 filelist.xml，避免阻塞UI
    coroutine.wrap(function()
        local localFilelistPath = workDir .. "filelist.xml"
        local localFiles = {}
        local hasLocalFilelist = false
        
        -- 检查文件是否存在
        self:_UpdateProgress(0.0, "正在检查本地 filelist.xml...", "")
        sleep(0.01)  -- 让UI刷新
        
        if PX2_RM:IsFileFloderExist(localFilelistPath) then
            -- 读取文件内容
            self:_UpdateProgress(0.02, "正在读取本地 filelist.xml...", "")
            sleep(0.01)  -- 让UI刷新
            
            local localFilelistContent = FileIO:Load(localFilelistPath, true)
            if localFilelistContent ~= "" then
                -- 解析文件列表
                self:_UpdateProgress(0.04, "正在解析本地 filelist.xml...", "")
                sleep(0.01)  -- 让UI刷新
                
                localFiles = self:_ParseFilelist(localFilelistContent)
                hasLocalFilelist = true
                local fileCount = localFiles and self:_CountTable(localFiles) or 0
                print("Loaded local filelist.xml with "..fileCount.." files")
                
                self:_UpdateProgress(0.05, "本地 filelist.xml 解析完成", "共 "..fileCount.." 个文件")
                sleep(0.1)  -- 短暂显示完成信息
            end
        end
        
        -- 如果本地没有filelist.xml，跳过更新
        if not hasLocalFilelist then
            print("Local filelist.xml not found, skipping update")
            self:_UpdateProgressText("更新失败：未找到本地 filelist.xml", "")
            sleep(2.0)
            self:_HideUpdateFrame()
            return
        end
        
        -- 开始比对文件列表
        local filesToDownload = {}
        local fileIndex = 0
        
        -- 统计总文件数（用于显示准备进度）
        local totalRemoteFiles = 0
        for _ in pairs(remoteFiles) do
            totalRemoteFiles = totalRemoteFiles + 1
        end
        
        local processedCount = 0
        local updateInterval = math.max(1, math.floor(totalRemoteFiles / 100))  -- 每处理1%或至少1个文件更新一次
        local sleepInterval = math.max(10, math.floor(totalRemoteFiles / 50))  -- 每处理约2%的文件就sleep一次，让UI刷新
        
        -- 本地有filelist.xml，比较内部条目
        for filename, remoteMD5 in pairs(remoteFiles) do
            processedCount = processedCount + 1
            
            -- 每处理一定数量文件就更新一次准备进度（准备阶段占0-10%）
            if processedCount % updateInterval == 0 or processedCount == totalRemoteFiles then
                local prepareProgress = processedCount / totalRemoteFiles
                self:_UpdateProgress(0.05 + prepareProgress * 0.05, "正在比对文件列表...", "已处理 "..processedCount.."/"..totalRemoteFiles.." 个文件")
            end
            
            -- 每处理一定数量文件就sleep一次，让UI能够刷新
            if processedCount % sleepInterval == 0 then
                sleep(0.01)  -- 短暂sleep，让UI刷新
            end
            
            -- 跳过包含 /Updater 的文件（参考C++代码）
            if string.find(filename, "/Updater") then
                print("Skipping file with /Updater: "..filename)
            else
                local needDownload = false
                
                -- 检查本地filelist中是否有这个条目
                if localFiles and localFiles[filename] then
                    -- 本地filelist中有这个条目，比较MD5
                    local localMD5 = localFiles[filename]
                    if localMD5 ~= remoteMD5 then
                        needDownload = true
                        print("MD5 mismatch, need to download: "..filename.." Local: "..localMD5.." Remote: "..remoteMD5)
                    else
                        print("MD5 match, skip: "..filename)
                    end
                else
                    -- 本地filelist中没有这个条目，需要下载
                    needDownload = true
                    print("File not in local filelist, need to download: "..filename)
                end
                
                if needDownload then
                    fileIndex = fileIndex + 1
                    print("["..fileIndex.."] Need to download: "..filename)
                    table.insert(filesToDownload, {index = fileIndex, filename = filename, md5 = remoteMD5})
                end
            end
        end
        sleep(1) 
        print("filesToDownload: "..#filesToDownload)
        self:_UpdateProgressText("对比完成，需要下载 "..#filesToDownload.." 个文件...", "")
        sleep(1) 
        
        -- 比对完成，开始下载需要更新的文件
        if #filesToDownload > 0 then
            print("Found "..#filesToDownload.." files to download (max concurrent: "..self._maxConcurrentDownloads..")")
            self._filesToDownload = filesToDownload
            self._currentDownloadIndex = 1
            self._activeDownloads = 0
            self._completedDownloads = 0  -- 重置已完成计数
            self._completedFileSet = {}  -- 重置已完成文件集合
            self._needDownloadFilelist = true  -- 标记最后需要下载filelist.xml
            self:_UpdateProgressText("准备下载 "..#filesToDownload.." 个文件...", "")
            sleep(0.5)
            self:_StartConcurrentDownloads()
        else
            print("No files need to be downloaded")
            self:_UpdateProgressText("所有文件已是最新版本，正在更新 filelist.xml...", "")
            sleep(0.5)
            self:_ReplaceFilelist()
        end
    end)()
end
-------------------------------------------------------------------------------
function p_minnastart:_CountTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end
-------------------------------------------------------------------------------
function p_minnastart:_StartConcurrentDownloads()
    -- 启动并发下载，直到达到最大并发数或没有更多文件
    while self._activeDownloads < self._maxConcurrentDownloads and self._currentDownloadIndex <= #self._filesToDownload do
        self:_DownloadNextFile()
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_DownloadNextFile()
    if not self._filesToDownload or not self._currentDownloadIndex then
        return
    end
    
    if self._currentDownloadIndex > #self._filesToDownload then
        -- 所有文件都已启动下载，等待完成
        -- 检查是否所有文件都已完成（通过检查已完成数量）
        if self._completedDownloads >= #self._filesToDownload and self._activeDownloads == 0 then
            print("All files downloaded successfully! Completed: "..self._completedDownloads.."/"..#self._filesToDownload)
            -- 所有文件下载完成，用filelist_temp.xml替换本地的filelist.xml
            if self._needDownloadFilelist then
                self:_ReplaceFilelist()
            end
            self._filesToDownload = nil
            self._currentDownloadIndex = nil
            self._needDownloadFilelist = nil
            self._completedDownloads = 0
            self._completedFileSet = {}
        end
        return
    end
    
    local fileInfo = self._filesToDownload[self._currentDownloadIndex]
    local filename = fileInfo.filename
    local remoteMD5 = fileInfo.md5
    local fileIndex = fileInfo.index
    
    print("["..fileIndex.."/"..#self._filesToDownload.."] Downloading: "..filename)
    
    -- 更新进度显示（开始下载，文件进度为0%）
    -- 准备阶段占10%，下载阶段占90%，基于已完成的文件数计算
    local downloadProgress = self._completedDownloads / #self._filesToDownload
    local overallProgress = 0.1 + downloadProgress * 0.9  -- 10% + 90% * 下载进度
    self:_UpdateProgress(overallProgress, "正在下载: "..filename, "["..self._completedDownloads.."/"..#self._filesToDownload.."] 0%")
    
    -- 构建下载 URL（将反斜杠转换为正斜杠用于URL）
    local urlFilename = string.gsub(filename, "\\", "/")
    local url = self._updateBaseURL .. urlFilename
    local localFilePath = self._updateWorkDir .. filename
    
    -- 目的：确保下载文件所在的目录存在，如果不存在则创建
    -- 因为下载的文件可能包含多级目录结构（如 common/common.js），需要先创建目录才能保存文件
    -- CreateFloder接口支持递归创建，会自动处理多级目录
    local dirPath = StringHelp:SplitFullFilename_OutPath(localFilePath)
    if dirPath ~= "" then
        -- 标准化路径分隔符为 /（PX2_RM接口要求使用/）
        dirPath = string.gsub(dirPath, "\\", "/")
        -- 确保末尾有 /（PX2_RM:IsFileFloderExist要求路径末尾必须有/）
        if string.sub(dirPath, -1) ~= "/" then
            dirPath = dirPath .. "/"
        end
        
        -- 检查目录是否存在
        if not PX2_RM:IsFileFloderExist(dirPath) then
            print("Creating directory: "..dirPath)
            -- CreateFloder接口支持递归创建多级目录，会自动处理路径中的所有/
            -- 只需要传入workDir作为父目录，以及相对于workDir的路径作为子目录
            -- 例如：workDir = "E:/path/manykit-minna/", dirPath = "E:/path/manykit-minna/common/subdir/"
            -- 会提取相对路径 "common/subdir/" 并自动创建 common/ 和 common/subdir/
            local workDirNormalized = string.gsub(self._updateWorkDir, "\\", "/")
            if string.sub(workDirNormalized, -1) ~= "/" then
                workDirNormalized = workDirNormalized .. "/"
            end
            local relativePath = string.sub(dirPath, string.len(workDirNormalized) + 1)
            if relativePath ~= "" then
                PX2_RM:CreateFloder(workDirNormalized, relativePath)
            end
        end
    end
    
    -- 增加活跃下载计数
    self._activeDownloads = self._activeDownloads + 1
    self._currentDownloadIndex = self._currentDownloadIndex + 1
    
    -- 下载文件（使用进度回调来实时更新下载进度）
    local curlObj = CurlObj:NewThread("DownloadFile_"..fileIndex)
    curlObj:SetUserDataString("filename", filename)
    curlObj:SetUserDataString("fileIndex", ""..fileIndex)
    curlObj:SetUserDataString("totalFiles", ""..#self._filesToDownload)
    curlObj:SetTimeOutSeconds(30.0)
    -- 使用进度回调来实时更新下载进度
    curlObj:Download(url, localFilePath, "_OnFileDownloadProgress", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_minnastart:_ReplaceFilelist()
    print("Replacing local filelist.xml with filelist_temp.xml...")
    
    -- 直接使用 self._updateWorkDir
    local filelistTempPath = self._updateWorkDir .. "filelist_temp.xml"
    local filelistPath = self._updateWorkDir .. "filelist.xml"
    
    -- 检查 filelist_temp.xml 是否存在
    local tempFile = File(filelistTempPath)
    if not tempFile:IsExists() then
        print("ERROR: filelist_temp.xml does not exist: "..filelistTempPath)
        return
    end
    
    -- 读取 filelist_temp.xml 的内容
    local tempContent = FileIO:Load(filelistTempPath, true)
    if tempContent == "" then
        print("ERROR: filelist_temp.xml is empty")
        return
    end
    
    -- 保存到 filelist.xml
    local saveResult = FileIO:Save(filelistPath, tempContent)
    if saveResult then
        print("filelist.xml replaced successfully!")
        print("File update process completed!")
        
        -- 更新完成，显示完成信息并关闭 Frame
        self:_UpdateProgress(1.0, "更新完成！", "")
        -- 延迟关闭 Frame，让用户看到完成信息
        -- 注意：如果 _ReplaceFilelist 可能从非协程中被调用，需要保留 coroutine.wrap
        -- 如果确定所有调用都在协程中，可以直接使用 sleep(2.0)
        coroutine.wrap(function()
            sleep(2.0)
            self:_HideUpdateFrame()
        end)()
        
        -- 可选：删除临时文件
        -- tempFile:Delete()
    else
        print("ERROR: Failed to save filelist.xml")
        self:_UpdateProgressText("更新失败：无法保存 filelist.xml", "")
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_OnFileDownloadProgress(ptr)
    local curlObj = Cast:ToO(ptr)
    
    local filename = curlObj:GetUserDataString("filename")
    local fileIndex = curlObj:GetUserDataString("fileIndex")
    local totalFiles = curlObj:GetUserDataString("totalFiles")
    local fileProgress = curlObj:GetGettedProgress()  -- 当前文件的下载进度 (0.0-1.0)

    if curlObj:IsGettedOK() then
        -- 文件下载完成
        -- 检查是否已经计数过（防止重复计数）
        if not self._completedFileSet[filename] then
            print("["..fileIndex.."/"..totalFiles.."] File downloaded: "..filename)
            
            -- 标记为已完成
            self._completedFileSet[filename] = true
            
            -- 减少活跃下载计数，增加已完成计数
            self._activeDownloads = self._activeDownloads - 1
            self._completedDownloads = self._completedDownloads + 1
            
            -- 更新进度显示（基于已完成的文件数，而不是文件索引）
            -- 准备阶段占10%，下载阶段占90%
            local downloadProgress = self._completedDownloads / tonumber(totalFiles)
            local overallProgress = 0.1 + downloadProgress * 0.9  -- 10% + 90% * 下载进度
            self:_UpdateProgress(overallProgress, "已完成: "..filename, "["..self._completedDownloads.."/"..totalFiles.."] 100%")
            
            -- 检查是否所有文件都已完成
            if self._completedDownloads >= tonumber(totalFiles) and self._activeDownloads == 0 then
                print("All files downloaded successfully! Completed: "..self._completedDownloads.."/"..totalFiles)
                -- 所有文件下载完成，用filelist_temp.xml替换本地的filelist.xml
                if self._needDownloadFilelist then
                    self:_ReplaceFilelist()
                end
                self._filesToDownload = nil
                self._currentDownloadIndex = nil
                self._needDownloadFilelist = nil
                self._completedDownloads = 0
                self._completedFileSet = {}
            else
                -- 继续下载下一个文件（如果还有）
                self:_StartConcurrentDownloads()
            end
        end
    else
        -- 文件还在下载中，更新进度
        -- 计算整体进度：基于已完成的文件数，当前文件进度只用于显示，不加入整体进度计算
        -- 这样可以避免并发下载时进度计算混乱
        local downloadProgress = self._completedDownloads / tonumber(totalFiles)
        local overallProgress = 0.1 + downloadProgress * 0.9  -- 10% + 90% * 下载进度
        local fileProgressPercent = math.floor(fileProgress * 100)
        
        self:_UpdateProgress(overallProgress, "正在下载: "..filename, "["..self._completedDownloads.."/"..totalFiles.."] "..fileProgressPercent.."%")
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_CreateUpdateFrame()
    print(self._name.." p_minnastart:_CreateUpdateFrame")
    
    -- 创建更新进度 Frame
    local frame = UIFrame:New("UpdateFrame")
    frame:SetAnchorHor(0.0, 1.0)
    frame:SetAnchorVer(0.0, 1.0)
    frame:SetWidget(true)
    
    -- 创建半透明背景
    local back = frame:CreateAddBackgroundPicBox(true, Float3(0.2, 0.2, 0.2))
    back:UseAlphaBlend(true)
    back:SetAlpha(0.8)
    
    -- 创建内容容器 Frame（居中显示）
    local contentFrame = UIFrame:New("UpdateContentFrame")
    frame:AttachChild(contentFrame)
    contentFrame:LLY(-5.0)
    contentFrame:SetAnchorHor(0.5, 0.5)
    contentFrame:SetAnchorVer(0.5, 0.5)
    contentFrame:SetPivot(0.5, 0.5)
    contentFrame:SetSize(600.0, 400.0)
    local back = contentFrame:CreateAddBackgroundPicBox(true, Float3(0.8, 0.8, 0.8))
    
    -- 创建标题文本
    local titleText = UIFText:New("UpdateTitle")
    contentFrame:AttachChild(titleText)
    titleText:LLY(-2.0)
    titleText:SetAnchorHor(0.5, 0.5)
    titleText:SetAnchorVer(1.0, 1.0)
    titleText:SetAnchorParamVer(-20.0, -20.0)
    titleText:SetPivot(0.5, 1.0)
    titleText:SetSize(580.0, 40.0)
    titleText:GetText():SetFontColor(Float3.WHITE)
    titleText:GetText():SetAligns(TEXTALIGN_HCENTER + TEXTALIGN_VCENTER)
    titleText:GetText():SetFontSize(28)
    titleText:GetText():SetText("更新...")
    
    -- 创建进度条
    local progressBar = UIProgressBar:New("UpdateProgressBar")
    self._updateProgressBar = progressBar
    contentFrame:AttachChild(progressBar)
    progressBar:LLY(-2.0)
    progressBar:SetAnchorHor(0.5, 0.5)
    progressBar:SetAnchorVer(0.5, 0.5)
    progressBar:SetAnchorParamVer(-40.0, -40.0)
    progressBar:SetPivot(0.5, 0.5)
    progressBar:SetSize(580.0, 30.0)
    progressBar:SetProgress(0.0)
    progressBar:GetBackPicBox():GetUIPicBox():SetTexture("engine/white.png")
    progressBar:GetBackPicBox():GetUIPicBox():SetColor(Float3(0.2, 0.2, 0.2))
    progressBar:GetBackPicBox():GetUIPicBox():SetAlpha(0.8)
    progressBar:GetProgressPicBox():GetUIPicBox():SetTexture("engine/white.png")
    progressBar:GetProgressPicBox():GetUIPicBox():SetColor(Float3(0.2, 0.6, 1.0))
    progressBar:GetProgressPicBox():GetUIPicBox():SetAlpha(1.0)
    
    -- 创建状态文本（显示当前操作）
    local statusText = UIFText:New("UpdateStatus")
    self._updateStatusText = statusText
    contentFrame:AttachChild(statusText)
    statusText:LLY(-2.0)
    statusText:SetAnchorHor(0.5, 0.5)
    statusText:SetAnchorVer(0.5, 0.5)
    statusText:SetAnchorParamVer(-80.0, -80.0)
    statusText:SetPivot(0.5, 0.5)
    statusText:SetSize(580.0, 30.0)
    statusText:GetText():SetFontColor(Float3.WHITE)
    statusText:GetText():SetAligns(TEXTALIGN_HCENTER + TEXTALIGN_VCENTER)
    statusText:GetText():SetFontSize(20)
    statusText:GetText():SetText("准备中...")
    
    -- 创建当前文件文本（显示当前下载的文件）
    local currentFileText = UIFText:New("UpdateCurrentFile")
    self._updateCurrentFileText = currentFileText
    contentFrame:AttachChild(currentFileText)
    currentFileText:LLY(-2.0)
    currentFileText:SetAnchorHor(0.5, 0.5)
    currentFileText:SetAnchorVer(0.5, 0.5)
    currentFileText:SetAnchorParamVer(-120.0, -120.0)
    currentFileText:SetPivot(0.5, 0.5)
    currentFileText:SetSize(580.0, 30.0)
    currentFileText:GetText():SetFontColor(Float3(0.8, 0.8, 0.8))
    currentFileText:GetText():SetAligns(TEXTALIGN_HCENTER + TEXTALIGN_VCENTER)
    currentFileText:GetText():SetFontSize(16)
    currentFileText:GetText():SetText("")
    
    -- 默认隐藏
    --frame:Show(false)

    return frame
end
-------------------------------------------------------------------------------
function p_minnastart:_ShowUpdateFrame()
    if self._updateFrame then
        self._updateFrame:Show(true)
        -- 重置进度
        if self._updateProgressBar then
            self._updateProgressBar:SetProgress(0.0)
        end
        if self._updateStatusText then
            self._updateStatusText:GetText():SetText("准备中...")
        end
        if self._updateCurrentFileText then
            self._updateCurrentFileText:GetText():SetText("")
        end
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_HideUpdateFrame()
    if self._updateFrame then
        self._updateFrame:Show(false)
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_UpdateProgress(progress, statusText, currentFileText)
    -- 限制进度在 0.0-1.0 之间
    progress = math.max(0.0, math.min(1.0, progress))
    
    if self._updateProgressBar then
        self._updateProgressBar:SetProgress(progress)
    end
    if self._updateStatusText and statusText then
        self._updateStatusText:GetText():SetText(statusText)
    end
    if self._updateCurrentFileText and currentFileText then
        self._updateCurrentFileText:GetText():SetText(currentFileText)
    end
end
-------------------------------------------------------------------------------
function p_minnastart:_UpdateProgressText(statusText, currentFileText)
    if self._updateStatusText and statusText then
        self._updateStatusText:GetText():SetText(statusText)
    end
    if self._updateCurrentFileText and currentFileText then
        self._updateCurrentFileText:GetText():SetText(currentFileText)
    end
end
-------------------------------------------------------------------------------
-- 全局函数：确认更新文件
function manykit_ConfirmUpdateFiles()
    print("manykit_ConfirmUpdateFiles called")
    local pluginInstance = g_manykit:GetPluginTreeInstanceByName("p_minnastart")
    if pluginInstance then
        print("Found plugin instance, calling _StartUpdateFiles")
        pluginInstance:_StartUpdateFiles()
    else
        print("ERROR: Could not find plugin instance p_minnastart")
    end
end
-------------------------------------------------------------------------------
g_manykit:plugin_regist(p_minnastart)
-------------------------------------------------------------------------------