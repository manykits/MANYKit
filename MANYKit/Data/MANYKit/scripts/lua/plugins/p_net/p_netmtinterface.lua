-- p_netmtinterface.lua
-------------------------------------------------------------------------------
-- face
function p_net:_send_minna_face_peoplein(str)
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("face_peoplein")

    dt:Key("istranger")
    dt:String(str)

    dt:Key("content")
    dt:String("face_peoplein " .. str)

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
function p_net:_send_minna_face_peopleout(str)
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("face_peopleout")

    dt:Key("istranger")
    dt:String(str)

    dt:Key("content")
    dt:String("face_peopleout " .. str)

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
function p_net:_send_minna_face_identify(useridstr, name)
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("face_identify")

    dt:Key("userid")
    dt:String(useridstr)

    -- dt:Key("name")
    -- dt:String(name)

    dt:Key("content")
    dt:String("face_identify " .. useridstr)

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
function p_net:_send_minna_face_reset()
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("face_identify_reset")

    dt:Key("content")
    dt:String("face_identify_reset")

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
-- voice
function p_net:_send_minna_voice_wake()
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("voice_wake")

    dt:Key("content")
    dt:String("voice_wake");

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
function p_net:_send_minna_voice_text(text)
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("voice_text")

    dt:Key("text")
    dt:String(text)

    dt:Key("content")
    dt:String("voice_text " .. text)

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
function p_net:_send_minna_voice_answer_cmd(cmd)
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("voice_answer_cmd")

    dt:Key("cmd")
    dt:String(cmd)

    dt:Key("voice_answer_cmd")
    dt:String("voice_answer_cmd " .. cmd)

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
function p_net:_send_minna_voice_answer_text(text)
    local dt = JSONData()
    dt:CreateWriter()
    dt:StartObject()

    dt:Key("topic")
    dt:String("mt")

    dt:Key("type")
    dt:String("voice_answer_text")

    dt:Key("text")
    dt:String(text)

    dt:Key("content")
    dt:String("voice_answer_text " .. text)

    dt:EndObject()

    self:_send_minna_json(dt)
end
-------------------------------------------------------------------------------
-- act
function p_net:_act_music_playgroup(groupsubstr, list)
    print("_act_music_playgroup")
    print("groupsubstr:"..groupsubstr)
    
    if ""~=groupsubstr then
        local url = "" .. p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/resource/list?group=10000&groupsubname="..StringHelp:UrlEncode(groupsubstr)

        local curl = CurlObj:NewThread()
        if list then
            curl:SetUserDataPointer("list", list)
        end
        curl:Get(url, "_OnMusicMt", self._scriptControl)
    end
end
-------------------------------------------------------------------------------
function p_net:_OnMusicMt(ptr)
    print("_OnMusicMt")

    local curlObj = Cast:ToO(ptr)

    local listp = curlObj:GetUserDataPointer("list")
    local list = Cast:ToObject(listp)

    local ret = curlObj:GetThreadRunedResult()
    if 0==ret then
        local strMem = curlObj:GetGettedString()
        print("strMem:")
        print(strMem)

        if list then
            list:RemoveAllItems()
        end

        local jsonData = JSONData()
        jsonData:LoadBuffer(strMem)
        local cStr = jsonData:GetMember("code")
        local cInt = cStr:ToInt()
        if 0==cInt then
            local data = jsonData:GetMember("data")
            if data:IsArray() then
                local arrSize = data:GetArraySize()
                print("arrSize:"..arrSize)
                for i=0,arrSize-1,1 do
                    local e = data:GetArrayElement(i)
                    local name = e:GetMember("name"):ToString()
                    local filepath = e:GetMember("filepath"):ToString()

                    local url = "http://"..p_net.g_ip_minna .. ":" .. p_net.g_port_minna_http .. "/" .. filepath
       
                    if nil==list then
                        if PX2_SS then
                            PX2_SS:PlayMusic(g_manykit._channelMusic, url, false, 2.0)
                        end
                    end

                    if list then
                        local item = list:AddItem(name)
                        item:SetUserDataString("url", url)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_act_music_stop()
    print("_act_music_stop")

    if PX2_SS then
        PX2_SS:PlayMusic(g_manykit._channelMusic, nil, false, 0.0)
    end
end
-------------------------------------------------------------------------------
function p_net:_act_music_play(name, list)
    if list then
        for i=0, list:GetNumItems()-1, 1 do
            local item = list:GetItem(i)
            if item then
                local url = item:GetUserDataString("url")
                local na = item:GetUserDataString("name")
                if na==name then                    
                    print("url:"..url)        
                    if PX2_SS then
                        PX2_SS:PlayMusic(g_manykit._channelMusic, url, false, 2.0)
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_act_voice_getanswer(netid, str)
    print("_act_voice_getanswer")

    local ipport = p_net.g_ip_minna..":6700"
    if 0 == p_net.g_talkprocessserverindex then
        ipport = p_net.g_ip_minna..":6700"
    else
        ipport = p_net.g_ip_mk..":6900"
    end

    print("ipport:"..ipport)

    local url = "http://"..ipport.."/aitalk/getanswer?" .. "key=" ..netid .. "&text=" .. StringHelp:UrlEncode(str)
    local curlObj = CurlObj:NewThread()
    curlObj:Get(url, "_on_getAnswerCallBack", self._scriptControl)
end
-------------------------------------------------------------------------------
function p_net:_on_getAnswerCallBack(ptr)
	local curlObj = Cast:ToO(ptr)
    if curlObj:IsGettedOK() then
        local strMem = curlObj:GetGettedString()
        print("strMem:")
        print(strMem)

        local pjson = PX2JSon.decode(strMem)
        if pjson.code==0 then
            local action = pjson.data.action
            local txt = pjson.data.text
            local voiceurl = pjson.data.voiceurl

            print("voiceurl:")
            print(voiceurl)   

            print("action:")   
            print(action)
            
            print("voiceurl:")   
            print(voiceurl)    

            if ""~=voiceurl then
                self:_downloadVocieSoundAndPlay("answertts", voiceurl)
            end

            if action and ""~=action then
                self:_send_minna_voice_answer_cmd(action)

                if "action_controlmode_sandbox"==action then
                    g_manykit._mrControlMode = 0                    
                    PX2_GH:SendGeneralEvent("sandbox", "1")
                elseif "action_cm_genobject"==action then
                    if 0 == g_manykit._mrControlMode then

                    end
                elseif "action_cm_deleteobject"==action then
                    if 0 == g_manykit._mrControlMode then
    
                    end
                elseif "action_controlmode_officer"==action then
                    g_manykit._mrControlMode = 1
                elseif "action_controlmode_simu"==action then
                    PX2_GH:SendGeneralEvent("sandbox", "0")

                    g_manykit._mrControlMode = 2
                elseif "action_device_turnon"==action then
                    PX2_GH:SendGeneralEvent("voicectrl_hotcamera", "1")
                elseif "action_device_turnoff"==action then
                    PX2_GH:SendGeneralEvent("voicectrl_hotcamera", "0")
                end
            else
                self:_send_minna_voice_answer_text(txt)
                PX2_GH:SendGeneralEvent("voice_answer_text", txt)
            end
        end
	end
end
-------------------------------------------------------------------------------
function p_net:_act_voice_tts(text)
    print("_act_voice_tts")

    local ipport = p_net.g_ip_minna..":6700"
    if 0 == p_net.g_talkprocessserverindex then
        ipport = p_net.g_ip_minna..":6700"
    else
        ipport = p_net.g_ip_mk..":6900"
    end

    if ""~=text then
        local url = "http://" .. ipport .. "/aitalk/tts?text="..StringHelp:UrlEncode(text)

        local curl = CurlObj:NewThread()
        curl:Get(url, "_OnVoiceTTS", self._scriptControl)
    end
end
-------------------------------------------------------------------------------
function p_net:_OnVoiceTTS(ptr)
    print("_OnVoiceTTS")

    local curlObj = Cast:ToO(ptr)
    local ret = curlObj:GetThreadRunedResult()
    if 0==ret then
        local strMem = curlObj:GetGettedString()
        print("strMem:")
        print(strMem)

        local jsonData = JSONData()
        jsonData:LoadBuffer(strMem)
        local cStr = jsonData:GetMember("code")
        local cInt = cStr:ToInt()
        if 0==cInt then
            local data = jsonData:GetMember("data")
            local voiceurl = data.GetMember("voiceurl")

            print("voiceurl:"..voiceurl)

            if ""~=voiceurl then
                self:_downloadVocieSoundAndPlay("voicetts", voiceurl)
            end
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_downloadVocieSoundAndPlay(sayindex, voiceurl)
    local pathParent = ResourceManager:GetWriteablePath().."Write_MANYKit/"
    local pathVoice = pathParent.."say/"
    if not PX2_RM:IsFileFloderExist(pathVoice) then
        PX2_RM:CreateFloder(pathParent, "say/")
    end

    local wpath = pathVoice .. sayindex .. ".wav"
    local curlObj = CurlObj:NewThread()
    curlObj:Download(voiceurl, wpath, "p_OnDownloadSay", self._scriptControl)
    curlObj:SetUserDataString("wpath", wpath)
end
-------------------------------------------------------------------------------
function p_net:p_OnDownloadSay(ptr)
    local curlObj = Cast:ToO(ptr)
    local name = curlObj:GetName()
    local progress = curlObj:GetGettedProgress()
	local iProj = progress * 100

    print("iProj:"..iProj)

    if curlObj:IsGettedOK() then
        local wpath = curlObj:GetUserDataString("wpath")
        print("p_OnDownloadSay ok")
        print(wpath)

        if PX2_SS then
            PX2_SS:ClearSoundRes(wpath)
            PX2_SS:PlayASound(wpath, 2.5, 30.0)
        end

        if PLive2D then
            PLive2D:PlayMotion("Say", 0, wpath, 5.0)
        end
    end
end
-------------------------------------------------------------------------------
function p_net:_act_robot_charge()
    if p_robot._g_sceneInst then
       p_robot._g_sceneInst._isdowaypatrolbeforecharging = false
       p_robot._g_sceneInst._isdowaypatrol = false
       p_robot._g_sceneInst:_GoChargeFront()
    end
end
-------------------------------------------------------------------------------
function p_net:_act_robot_followpath(name)

end
-------------------------------------------------------------------------------
function p_net:_act_robot_gopos(posname)

end
-------------------------------------------------------------------------------