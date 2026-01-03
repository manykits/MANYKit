-- engine_updater.lua

local localversionupdater = PX2_APP:GetLocalUpdaterVersion()
local localversionengine = PX2_APP:GetLocalEngineVersion()
local isupdaterneedupdate = false
local isengineneedupdate = false;

function engine_createframeupdater()
    local frame = UIFrame:New("frameengineupdater")
    frame:SetWidget(true)
	frame:SetAnchorHor(0.0, 1.0)
	frame:SetAnchorVer(0.0, 1.0)

    local back = frame:CreateAddBackgroundPicBox()
    back:UseAlphaBlend(true)
    back:SetAlpha(0.6)
    back:SetColor(Float3.BLACK)

    local btnCancel = UIButton:New("engine_btnupdatecancel")
    frame:AttachChild(btnCancel)
	local txt = btnCancel:CreateAddFText("取消Cancel")
	txt:GetText():SetFontSize(24)
	txt:GetText():SetFontScale(0.9)
    btnCancel:LLY(-5.0)
    btnCancel:SetAnchorHor(0.5, 0.5)
    btnCancel:SetAnchorVer(0.0, 0.0)
	btnCancel:SetAnchorParamHor(-150.0, -150.0)
	btnCancel:SetAnchorParamVer(100.0, 100.0)
	btnCancel:SetSize(200.0, 60.0)
	btnCancel:SetScriptHandler("engine_uicallback")
	btnCancel:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
	btnCancel:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/but_normal.png")
	btnCancel:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)

    local btnUpdate = UIButton:New("engine_btnupdateok")
    frame:AttachChild(btnUpdate)
	local txt = btnUpdate:CreateAddFText("更新Update")
	txt:GetText():SetFontSize(24)
	txt:GetText():SetFontScale(0.9)
    btnUpdate:LLY(-5.0)
    btnUpdate:SetAnchorHor(0.5, 0.5)
    btnUpdate:SetAnchorVer(0.0, 0.0)
	btnUpdate:SetAnchorParamHor(150.0, 150.0)
	btnUpdate:SetAnchorParamVer(100.0, 100.0)
	btnUpdate:SetSize(200.0, 60.0)
	btnUpdate:SetScriptHandler("engine_uicallback")
	btnUpdate:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetPicBoxType(UIPicBox.PBT_NINE)
	btnUpdate:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexture("engine/but_normal.png")
	btnUpdate:GetPicBoxAtState(UIButtonBase.BS_NORMAL):SetTexCornerSize(8.0, 8.0, 8.0, 8.0)
    btnUpdate:Enable(false)
    btnUpdate:GetText():SetFontColor(Float3:MakeColor(100,100,100))

    local txtLocal = UIFText:New()
    frame:AttachChild(txtLocal)
    txtLocal:LLY(-1.0)
    txtLocal:SetAnchorHor(0.5, 0.5)
    txtLocal:SetAnchorVer(1.0, 1.0)
	txtLocal:SetWidth(400.0)
    txtLocal:SetAnchorParamVer(-100, -100)
    txtLocal:GetText():SetText("引擎更新EngineUpdate")
    txtLocal:GetText():SetFontColor(Float3.WHITE)
    txtLocal:GetText():SetFontSize(24)

    local ver = -160.0
    local v = 80.0

    local h0 = 0.3
    local h1 = 0.7

    local txtLocal = UIFText:New()
    frame:AttachChild(txtLocal)
    txtLocal:LLY(-1.0)
    txtLocal:SetAnchorHor(h0, h0)
    txtLocal:SetAnchorVer(1.0, 1.0)
    txtLocal:SetAnchorParamVer(ver, ver)
    txtLocal:GetText():SetText("当前版本")
    txtLocal:GetText():SetFontColor(Float3.WHITE)
    txtLocal:GetText():SetFontSize(24)

    local txtLocal = UIFText:New()
    frame:AttachChild(txtLocal)
    txtLocal:LLY(-1.0)
    txtLocal:SetAnchorHor(h1, h1)
    txtLocal:SetAnchorVer(1.0, 1.0)
    txtLocal:SetAnchorParamVer(ver, ver)
    txtLocal:GetText():SetText("服务器版本")
    txtLocal:GetText():SetFontColor(Float3.WHITE)
    txtLocal:GetText():SetFontSize(24)
    txtLocal:SetWidth(150.0)

    ver = ver - v

    local txtEngine = UIFText:New()
    frame:AttachChild(txtEngine)
    txtEngine:LLY(-1.0)
    txtEngine:SetAnchorHor(0.1, 0.1)
    txtEngine:SetAnchorVer(1.0, 1.0)
    txtEngine:SetAnchorParamVer(ver, ver)
    txtEngine:GetText():SetText("引擎")
    txtEngine:GetText():SetFontColor(Float3.WHITE)
    txtEngine:GetText():SetFontSize(24)

    local txtEngine1 = UIFText:New("engine_localengine")
    frame:AttachChild(txtEngine1)
    txtEngine1:LLY(-1.0)
    txtEngine1:SetAnchorHor(h0, h0)
    txtEngine1:SetAnchorVer(1.0, 1.0)
    txtEngine1:SetAnchorParamVer(ver, ver)
    txtEngine1:GetText():SetText("-.-.-.-")
    txtEngine1:GetText():SetFontColor(Float3.WHITE)
    txtEngine1:GetText():SetFontSize(24)

    local txtEngine2 = UIFText:New("engine_webengine")
    frame:AttachChild(txtEngine2)
    txtEngine2:LLY(-1.0)
    txtEngine2:SetAnchorHor(h1, h1)
    txtEngine2:SetAnchorVer(1.0, 1.0)
    txtEngine2:SetAnchorParamVer(ver, ver)
    txtEngine2:GetText():SetText("-.-.-.-")
    txtEngine2:GetText():SetFontColor(Float3.WHITE)
    txtEngine2:GetText():SetFontSize(24)

    ver = ver - v

    local txtUpdater = UIFText:New()
    frame:AttachChild(txtUpdater)
    txtUpdater:LLY(-1.0)
    txtUpdater:SetAnchorHor(0.1, 0.1)
    txtUpdater:SetAnchorVer(1.0, 1.0)
    txtUpdater:SetAnchorParamVer(ver, ver)
    txtUpdater:GetText():SetText("更新器")
    txtUpdater:GetText():SetFontColor(Float3.WHITE)
    txtUpdater:GetText():SetFontSize(24)

    local txtUpdater1 = UIFText:New("engine_localupdater")
    frame:AttachChild(txtUpdater1)
    txtUpdater1:LLY(-1.0)
    txtUpdater1:SetAnchorHor(h0, h0)
    txtUpdater1:SetAnchorVer(1.0, 1.0)
    txtUpdater1:SetAnchorParamVer(ver, ver)
    txtUpdater1:GetText():SetText("-.-.-.-")
    txtUpdater1:GetText():SetFontColor(Float3.WHITE)
    txtUpdater1:GetText():SetFontSize(24)

    local txtUpdater2 = UIFText:New("engine_webupdater")
    frame:AttachChild(txtUpdater2)
    txtUpdater2:LLY(-1.0)
    txtUpdater2:SetAnchorHor(h1, h1)
    txtUpdater2:SetAnchorVer(1.0, 1.0)
    txtUpdater2:SetAnchorParamVer(ver, ver)
    txtUpdater2:GetText():SetText("-.-.-.-")
    txtUpdater2:GetText():SetFontColor(Float3.WHITE)
    txtUpdater2:GetText():SetFontSize(24)

    ver = ver - v

    local txtNetInfo = UIFText:New("engine_netinfo")
    frame:AttachChild(txtNetInfo)
    txtNetInfo:LLY(-1.0)
    txtNetInfo:SetAnchorHor(0.5, 0.5)
    txtNetInfo:SetAnchorVer(1.0, 1.0)
    txtNetInfo:SetAnchorParamVer(ver, ver)
    txtNetInfo:SetWidth(400.0)
    txtNetInfo:GetText():SetText("网络连接良好 Net OK")
    txtNetInfo:GetText():SetFontColor(Float3.WHITE)
    txtNetInfo:GetText():SetFontSize(24)
    txtNetInfo:GetText():SetFontScale(0.8)

    return frame
end

engine_frameupdater = PX2_ENGINECANVAS:GetObjectByName("frameengineupdater") 
if nil==engine_frameupdater then
	engine_frameupdater = engine_createframeupdater()
	engine_frameupdater:LLY(-500.0)
	PX2_ENGINECANVAS:AttachChild(engine_frameupdater)
end
local engine_iscancelupdatecount = false

function engine_OnDownloadedWebEngineUpdaterVersion(strMem)
    if ""~=strMem then
        local jsonData = JSONData()
        jsonData:LoadBuffer(strMem)
        local cStr = jsonData:GetMember("code")
        local cInt = cStr:ToInt()
        if 0==cInt then
            local data = jsonData:GetMember("data")

            local engine = data:GetMember("engine"):ToString()
            local updater = data:GetMember("updater"):ToString()
            local downloadurl = data:GetMember("downloadurl"):ToString()
            
            print("v_enginelocal:"..localversionengine)
            print("v_updaterlocal:"..localversionupdater)

            print("v_engine:"..engine)
            print("v_updater:"..updater)
            print("v_downloadurl:"..downloadurl)

            local updateURL = ""
            if ""==downloadurl then
                updateURL = PX2_APP:GetVersionURL()
            else
                updateURL = downloadurl
            end
            print("updateURL:"..updateURL)
            PX2_APP:SetUpdateURL(updateURL)
            
            if ""~=engine and""~=updater then
                isupdaterneedupdate = updater~=localversionupdater
                isengineneedupdate = engine~=localversionengine

                if isengineneedupdate or isupdaterneedupdate then
                    engine_frameupdatershow(true, engine, updater)

                    local btnUpdate = engine_frameupdater:GetObjectByName("engine_btnupdateok")
                    btnUpdate:Enable(true)
                    btnUpdate:GetText():SetFontColor(Float3:MakeColor(255,255,255))
                            
                    local fTextNetInfo = engine_frameupdater:GetObjectByName("engine_netinfo")
                    coroutine.wrap(function()
                        local ss = 5.0
                        for i=0,5,1 do
                            local ss = 5.0-i
                            if not engine_iscancelupdatecount then
                                if i==5 then
                                    fTextNetInfo:GetText():SetText("网络连接良好 Net OK 自动更新中")
                                    sleep(0.1)
                                    engine_doupdate()
                                else
                                    fTextNetInfo:GetText():SetText("网络连接良好 Net OK "..ss.."秒后,自动更新")
                                    sleep(1.0)
                                end
                            end
                        end
                    end)()
                else
                    engine_frameupdatershow(true, engine, updater)

                    local fTextNetInfo = engine_frameupdater:GetObjectByName("engine_netinfo")
                    coroutine.wrap(function()
                        coroutine.wrap(function()
                            local ss = 3.0
                            for i=0,3,1 do
                                local ss = 3-i
                                if not engine_iscancelupdatecount then
                                    if i==3 then
                                        fTextNetInfo:GetText():SetText("网络连接良好 Net OK 打开项目中")
                                        sleep(0.1)
                                        engine_frameupdatershow(false, engine, updater)
                                        engine_loadproject()
                                    else
                                        fTextNetInfo:GetText():SetText("网络连接良好 Net OK "..ss.."秒后,自动打开项目")
                                        sleep(1.0)
                                    end
                                end
                            end
                        end)()
                    end)()
                end
            else
                engine_frameupdatershow(false, "", "")
                engine_loadproject()
            end
        else
            engine_frameupdatershow(false, "", "")
            engine_loadproject()
        end
    else
        engine_frameupdatershow(false, "", "")
        engine_loadproject()
    end
end

function engine_frameupdatershow(sw, engine, updater)
    engine_frameupdater:Show(sw)

    local textLocalupdater = engine_frameupdater:GetObjectByName("engine_localupdater")
    if nil~=textLocalupdater then
        textLocalupdater:GetText():SetText(localversionupdater)
    end

    local textLocalengine = engine_frameupdater:GetObjectByName("engine_localengine")
    if nil~=textLocalengine then
        textLocalengine:GetText():SetText(localversionengine)
    end

    local textWebupdater = engine_frameupdater:GetObjectByName("engine_webupdater")
    if nil~=textWebupdater then
        textWebupdater:GetText():SetText(updater)
    end

    local textWebengine = engine_frameupdater:GetObjectByName("engine_webengine")
    if nil~=textWebengine then
        textWebengine:GetText():SetText(engine)
    end
end

function engine_loadproject()
	local projname = PX2_APP:GetBoostProjectName()
	PX2_APP:LoadProject(projname)
	PX2_APP:Play(Application.PT_PLAY)
end

function engine_chekdoupdate()
	if PX2_APP:IsDoUpdate() then
		local versionurl = PX2_APP:GetVersionURL()
		if ""~=urversionurll then
            print("versionurl:"..versionurl)

            engine_frameupdater:Show(true)

            local curlOb = CurlObj:New()
            local isNetOk = curlOb:IsNetOK(versionurl.."info")
            CurlObj:Delete(curlOb)
            engine_onnetstate(isNetOk)
		else
			engine_frameupdatershow(false, "", "")
		end
	else
		engine_frameupdatershow(false, "", "")
		engine_loadproject()
	end
end


function engine_onnetstate(stat)
    local fTextNetInfo = engine_frameupdater:GetObjectByName("engine_netinfo")
    local btnUpdate = engine_frameupdater:GetObjectByName("engine_btnupdateok")
    btnUpdate:Enable(stat)

    if stat then
        fTextNetInfo:GetText():SetText("网络连接良好 Net OK")
        fTextNetInfo:GetText():SetColor(Float3.WHITE)
        btnUpdate:GetText():SetFontColor(Float3.WHITE)

        PX2_APP:DownLoadWebEngineUpdaterVersion("engine_OnDownloadedWebEngineUpdaterVersion")
    else
        fTextNetInfo:GetText():SetText("网络不通 Net Bad")
        fTextNetInfo:GetText():SetColor(Float3.RED)
        btnUpdate:GetText():SetFontColor(Float3:MakeColor(100.0,100.0,100.0))
        engine_frameupdatershow(true, "", "")

        coroutine.wrap(function()
            coroutine.wrap(function()
                local ss = 5.0
                for i=0,5,1 do
                    local ss = 5.0-i
                    if not engine_iscancelupdatecount then
                        if i==5 then
                            fTextNetInfo:GetText():SetText("网络不通 Net Bad 打开项目中")
                            sleep(0.1)
                            engine_frameupdatershow(false, nil, nil)
                            engine_loadproject()
                        else
                            fTextNetInfo:GetText():SetText("网络不通 Net Bad "..ss.."秒后,自动打开项目")
                            sleep(1.0)
                        end
                    end
                end
            end)()
		end)()
    end
end

function engine_uicallback(ptr, callType)
    local obj = Cast:ToO(ptr) 
    local name = obj:GetName()	
    
    if UICT_PRESSED==callType then
        PX2_PlayFrameScale(obj)

	elseif UICT_RELEASED==callType then
        PX2_PlayFrameNormal(obj)
		
		if "engine_btnupdatecancel"==name then
            engine_iscancelupdatecount = true
            engine_frameupdatershow(false, nil, nil)
			engine_loadproject()
        elseif "engine_btnupdateok"==name then
            engine_iscancelupdatecount = true
            engine_doupdate()
		end
    elseif UICT_RELEASED_NOTPICK==callType then
        PX2_PlayFrameNormal(obj)
	end
end

function engine_doupdate()
    print("engine_doupdate~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    local btnCancel = engine_frameupdater:GetObjectByName("engine_btnupdatecancel")
    local btnOK = engine_frameupdater:GetObjectByName("engine_btnupdateok")

    btnCancel:Show(false)
    btnOK:Show(false)

    if isupdaterneedupdate then
        PX2_APP:DoUpdateUpdater()
    end

    if isengineneedupdate then
        PX2_APP:DoUpdateEngine()
    else
        engine_frameupdatershow(false, nil, nil)
        engine_loadproject()
    end
end

engine_chekdoupdate()
