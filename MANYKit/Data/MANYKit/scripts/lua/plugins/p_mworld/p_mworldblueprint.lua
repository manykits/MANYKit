-- p_mworldblueprint.lua

-------------------------------------------------------------------------------
function p_mworld:_ShowFlowGraph(sh)
    print(self._name.." p_mworld:_ShowFlowGraph:")
    print_i_b(sh)

    if self._frameBluePrint then
        self._frameBluePrint:Show(sh)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_CreateFameBluePrint()
    local backFrame, frameCnt, btnClose, textTitle, backPic = manykit_createCommonDlg(0, 0, "蓝图")
    backFrame:LLY(-51.0)
    btnClose:SetName("BtnFlowGraphClose")
    btnClose:SetScriptHandler("_UICallback", self._scriptControl)

    local bpFrame = UIBluePrintFrame:New()
    frameCnt:AttachChild(bpFrame)
    bpFrame:LLY(-1.0)
    bpFrame:SetAnchorHor(0.0, 1.0)
    bpFrame:SetAnchorVer(0.0, 1.0)
    bpFrame:SetAnchorParamVer(0.0, -40.0)

    local frameMenu = PX2_APP:GetFrameMenu()
    frameCnt:AttachChild(frameMenu)
    frameMenu:LLY(-5)
    frameMenu:SetSize(200.0, 150.0)
    frameMenu:Show(false)
    frameMenu:EnableAnchorLayout(false)
    frameMenu:CreateAddBackgroundPicBox(true, Float3.BLACK)

    local tree = PX2_APP:GetTreeMenu()
    tree:SetSliderSize(20.0)
    local slider = tree:GetSlider()
    manykit_uiProcessSlider(slider)
    tree:SetScriptHandler("_UICallback", self._scriptControl)

    self:_BBAddParam()
    self:_BBAddOperator()
    self:_BBAddEvent()

    return backFrame
end
-------------------------------------------------------------------------------
function p_mworld:_CreateBPFile()
    print(self._name.." p_mworld:_CreateBPFile")

    local bpObj = PX2_BPEDIT:GetSelectBPObject()
    local szNode = Cast:ToSizeNode(bpObj)
    if szNode then
        local bpFile = PX2_BPM:CreateBPFile()
        PX2_BPM:AddBPObject(szNode, bpFile)
        bpFile:LLY(-1.0)
    end
end
-------------------------------------------------------------------------------
function p_mworld:_BBAddParam()	
    -- param
	PX2_LOGICM:BeginAddParam("_iValue", FunObject.PT_VARIABLE)
	PX2_LOGICM:AddInputInt("val", 0)
    PX2_LOGICM:AddOutput("val", FPT_INT)
	PX2_LOGICM:EndAddFun_Param("Param")
	
	PX2_LOGICM:BeginAddParam("_fValue", FunObject.PT_VARIABLE)
	PX2_LOGICM:AddInputFloat("val", 0.0)
    PX2_LOGICM:AddOutput("val", FPT_FLOAT)
	PX2_LOGICM:EndAddFun_Param("Param")
	
	PX2_LOGICM:BeginAddParam("_strValue", FunObject.PT_VARIABLE)
	PX2_LOGICM:AddInputString("val", "abc")
    PX2_LOGICM:AddOutput("val", FPT_STRING)
	PX2_LOGICM:EndAddFun_Param("Param")

    PX2_LOGICM:BeginAddParam("_bValue", FunObject.PT_VARIABLE)
	PX2_LOGICM:AddInputBool("true", true)
    PX2_LOGICM:AddOutput("true", FPT_BOOL)
	PX2_LOGICM:EndAddFun_Param("Param")

    -- set
    PX2_LOGICM:BeginAddFunObj("setInt")
    PX2_LOGICM:AddInput("variable", FPT_INT)
    PX2_LOGICM:AddInput("val", FPT_INT)
    PX2_LOGICM:EndAddFun_General("Param")
    
    PX2_LOGICM:BeginAddFunObj("setFloat")
    PX2_LOGICM:AddInput("variable", FPT_FLOAT)
    PX2_LOGICM:AddInput("val", FPT_FLOAT)
    PX2_LOGICM:EndAddFun_General("Param")
    
    PX2_LOGICM:BeginAddFunObj("setString")
    PX2_LOGICM:AddInput("variable", FPT_STRING)
    PX2_LOGICM:AddInput("val", FPT_STRING)
    PX2_LOGICM:EndAddFun_General("Param")
    
    PX2_LOGICM:BeginAddFunObj("setBool")
    PX2_LOGICM:AddInput("variable", FPT_BOOL)
    PX2_LOGICM:AddInput("val", FPT_BOOL)
    PX2_LOGICM:EndAddFun_General("Param")
    
    PX2_LOGICM:BeginAddFunObj("setObject")
    PX2_LOGICM:AddInput("variable", FPT_POINTER)
    PX2_LOGICM:AddInput("val", FPT_POINTER)
    PX2_LOGICM:EndAddFun_General("Param")
end
-------------------------------------------------------------------------------
function p_mworld:_BBAddOperator()
	PX2_LOGICM:BeginAddFunObj("+")
	PX2_LOGICM:AddInput("a", FPT_FLOAT)
	PX2_LOGICM:AddInput("b", FPT_FLOAT)
	PX2_LOGICM:AddOutput("out", FPT_FLOAT)
	PX2_LOGICM:EndAddFun_Operator("Math")
	
	PX2_LOGICM:BeginAddFunObj("-")
	PX2_LOGICM:AddInput("a", FPT_FLOAT)
	PX2_LOGICM:AddInput("b", FPT_FLOAT)
	PX2_LOGICM:AddOutput("out", FPT_FLOAT)
	PX2_LOGICM:EndAddFun_Operator("Math")
	
	PX2_LOGICM:BeginAddFunObj("*")
	PX2_LOGICM:AddInput("a", FPT_FLOAT)
	PX2_LOGICM:AddInput("b", FPT_FLOAT)
	PX2_LOGICM:AddOutput("out", FPT_FLOAT)
	PX2_LOGICM:EndAddFun_Operator("Math")
	
	PX2_LOGICM:BeginAddFunObj("/")
	PX2_LOGICM:AddInput("a", FPT_FLOAT)
	PX2_LOGICM:AddInput("b", FPT_FLOAT)
	PX2_LOGICM:AddOutput("out", FPT_FLOAT)
	PX2_LOGICM:EndAddFun_Operator("Math")
	
	PX2_LOGICM:BeginAddFunObj("!")
	PX2_LOGICM:AddInput("b", FPT_BOOL)
	PX2_LOGICM:AddOutput("out", FPT_BOOL)
	PX2_LOGICM:EndAddFun_Operator("Math")
	
	PX2_LOGICM:BeginAddFunObj("&&")
	PX2_LOGICM:AddInput("a", FPT_BOOL)
	PX2_LOGICM:AddInput("b", FPT_BOOL)
	PX2_LOGICM:AddOutput("out", FPT_BOOL)
	PX2_LOGICM:EndAddFun_Operator("Math")
	
	PX2_LOGICM:BeginAddFunObj("||")
	PX2_LOGICM:AddInput("a", FPT_BOOL)
	PX2_LOGICM:AddInput("b", FPT_BOOL)
	PX2_LOGICM:AddOutput("out", FPT_BOOL)
	PX2_LOGICM:EndAddFun_Operator("Math")
end
-------------------------------------------------------------------------------
function p_mworld:_BBAddEvent()
	PX2_LOGICM:BeginAddEvent("Event", "onEvent")
	PX2_LOGICM:AddInput("Event", FPT_STRING)
	PX2_LOGICM:AddOutput("EventDo", FPT_LINK)
	PX2_LOGICM:EndAddFun_Event("Event")

	PX2_LOGICM:BeginAddParam("BBlockEventS", FunObject.PT_ENUMSTRING)
	PX2_LOGICM:AddInputString("Play", "")
	PX2_LOGICM:AddInputString("Stop", "")
	PX2_LOGICM:AddInputString("String", "")
	PX2_LOGICM:AddInputString("UIButtonPressed", "")
	PX2_LOGICM:AddInputString("UIButtonReleased", "")
	PX2_LOGICM:AddInputString("UIButtonReleasedNotPick", "")
	PX2_LOGICM:AddInputString("UIRoundDragChanged", "")
	PX2_LOGICM:AddInputString("UISliderChanged", "")
	PX2_LOGICM:AddInputString("VoiceResult", "")
	PX2_LOGICM:AddInputString("BluetoothReceive", "")
	PX2_LOGICM:AddInputString("IRReceive", "")
	PX2_LOGICM:AddOutput("val", FPT_STRING)
	PX2_LOGICM:EndAddFun_Param("Event")

    PX2_LOGICM:BeginAddClassFunObj("BBlockSystem", "sendEvent", false, "PX2BBLOCK_SYS")
	PX2_LOGICM:AddInput("str", FPT_STRING)
	PX2_LOGICM:EndAddFun_General("Event")

    PX2_LOGICM:BeginAddClassFunObj("BBlockSystem", "getEventObjectName", false, "PX2BBLOCK_SYS")
	PX2_LOGICM:AddOutput("name", FPT_STRING)
	PX2_LOGICM:EndAddFun_General("Event")

    PX2_LOGICM:BeginAddClassFunObj("BBlockSystem", "getEventDataFloat", false, "PX2BBLOCK_SYS")
	PX2_LOGICM:AddOutput("val", FPT_FLOAT)
	PX2_LOGICM:EndAddFun_General("Event")

	PX2_LOGICM:BeginAddClassFunObj("BBlockSystem", "getEventDataString", false, "PX2BBLOCK_SYS")
    PX2_LOGICM:AddInputString("aa", "")
	PX2_LOGICM:AddOutput("str", FPT_STRING)
	PX2_LOGICM:EndAddFun_General("Event")
end
-------------------------------------------------------------------------------
function p_mworld:_CreateBPLogicObj(cata, cata1, name)
    print(self._name.." p_mworld:_CreateBPLogicObj cata:"..cata.." cata1:"..cata1.." name:"..name)

    local bpObject = PX2_BPEDIT:GetSelectBPObject()
	if nil~=bpObject then
        local obj = nil

        if cata=="Event" then
            obj = PX2_BPM:CreateBPEvent("BBlockEventS", name)
        elseif cata=="Params" then        
            obj = PX2_BPM:CreateBPParam(name)
        elseif cata=="Ctrl" then
            obj = PX2_BPM:CreateBPOption(name)
        elseif cata=="Operators" then
            obj = PX2_BPM:CreateBPOperator(name) 
        elseif cata=="Functions" then
            if name=="FunctionStart" then
                obj = PX2_BPM:CreateBPModuleFunctionStart()
            else  
                obj = PX2_BPM:CreateBPModuleGeneral(name)
            end
        end    
        if obj then
            bpObject:AttachChild(obj)
            obj:LLY(-1.0)
        end
    end
end
-------------------------------------------------------------------------------