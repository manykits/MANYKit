-- engine_start.lua

-- classes & inheritance
function class(baseClass, body)
	local ret = body or {};
	
	-- if there's a base class, attach our new class to it
	if (baseClass ~= nil) then
		setmetatable(ret, ret);
		ret.__index = baseClass;
		ret.base = baseClass;
	end
	
	-- Add the New() function.  This will end up being added to each subclass which isn't ideal.  This 
	-- function should probably be stored in a single place so we only have to create it once.
	-- 		-self: The self pointer that's calling this function.
	--		-constructionData: The table sent in as construction data.  Think of it like a constructor.
	--		-originalSubClass: Used for recursion.  Don't pass anything into this parameter, it's filled 
	--						   automatically.  It's used in case the C++ side needs access to the leaf 
	--						   subclass that is being instantiated.  For an example, see ScriptProcess 
	--						   in C++.
	ret.New = function(self, constructionData, originalSubClass)
		local obj;
		if (self.__index ~= nil) then
			if (originalSubClass ~= nil) then
				obj = self.__index:New(constructionData, originalSubClass);
			else
				obj = self.__index:New(constructionData, self);
			end
		else
			obj = constructionData or {};
		end
		
		setmetatable(obj, obj);
		obj.__index = self;
		
		-- copy any operators over
		if (self.__operators ~= nil) then
			for key, val in pairs(self.__operators) do
				obj[key] = val;
			end
		end
		
		return obj;
	end
	
	-- Returns true if otherClass appears in this objects class hierarchy anywhere.
	ret.IsInstance = function(self, otherClass)
		local cls = self.__index;
		while cls do
			if cls == otherClass then 
				return true
			end
			cls = cls.base
		end
		return false
	end
	
	return ret;
end

-- redefine require and print
do
	local OldRequire = require;  -- save the old require() function
	--local resourceIdMap = {};  -- map of resource id's we've already loaded
	
	require = function(script)
		if (PX2_SC_LUA:CallFile(script)) then
			-- nothing to do
		else
			OldRequire(script);
		end
		--if (not resourceIdMap[script]) then
		--	if (PX2_SC_LUA:CallFile(script)) then
		--		resourceIdMap[script] = true;
		--	else
				-- failed to load file through the resource system so fall back to the old method
		--		OldRequire(script);
		--	end
		--end
	end
end

do
    local OldPrint = print;  -- save the old print() function
    
    print = function(text)
		if PX2_ENABLE_PRINT then
			if (text ~= nil) then
				PX2_LOGGER:LogInfo("script_lua", text)
			else
				PX2_LOGGER:LogInfo("script_lua", "<nil>")
			end
		end
	end
end
function print_i_bool(val)
	if val then
		PX2_LOGGER:LogInfo("script_lua", "true")
	else
		PX2_LOGGER:LogInfo("script_lua", "false")
	end
end
function print_i_b(val)
	print_i_bool(val)
end
function print_i(text)
	PX2_LOGGER:LogInfo("script_lua", text)
end
function print_e(text)
	PX2_LOGGER:LogError("script_lua", text)
end
function print_u(text)
	PX2_LOGGER:LogUser("script_lua", text)
end

-- Utility functions
Utils = {};

-- Concatenate the contents of the parameter list, separated by the string delimiter (just like in perl)
-- example: Utils.Join(", ", {"Anna", "Bob", "Charlie", "Dolores"})
-- results: "Anna, Bob, Charlie, Dolores"
function Utils.Join(delimiter, list)
	local len = table.getn(list)
	if len == 0 then
		return "" 
	end
	local string = list[1]
	for i = 2, len do
		string = string .. delimiter .. list[i] 
	end
	return string
end

-- Split text into a list consisting of the strings in text, separated by strings matching delimiter (which may be a pattern). 
-- example: Utils.Split(",%s*", "Anna, Bob, Charlie,Dolores")
-- results: {"Anna", "Bob", "Charlie", "Delores"}
function Utils.Split(delimiter, text)
	local list = {}
	local pos = 1
	if string.find("", delimiter, 1) then -- this would result in endless loops
		--error("delimiter matches empty string!")
		print("delimiter matches empty string!")
	end
	
	while 1 do
		local first, last = string.find(text, delimiter, pos)
		if first then -- found?
			if first < pos then
				print("[WARNING] Lua Split() function failed; first < pos\nfirst = "..first.."; last = "..last.."; pos = "..pos);
				break
			end
			table.insert(list, string.sub(text, pos, first-1))
			pos = last + 1
		else
			table.insert(list, string.sub(text, pos))
			break
		end
	end
	return list
end

function Utils.ConvertBoolToString(bool)
	if (bool == true) then
		return "true";
	else
		return "false";
	end
end

function Utils.DumpTable(table)
	for key, val in pairs(table) do
		print(key, val);
	end
end

-- private function used by Utils.DumpObject()
function Utils._BuildMemberSet(obj, memberSet)
	if (obj.__index ~= nil and obj ~= obj.__index) then
		Utils._BuildMemberSet(obj.__index, memberSet);
	end
	
	for key, val in pairs(obj) do
		if (key ~= "__index" and memberSet[key] == nil) then
			memberSet[key] = true;
		end
	end
end

function Utils.DumpObject(obj)
	-- There might be copies of the same variable at various levels in the hierarchy so we need to build an
	-- exclusive set of names.
	local memberSet = {};
	Utils._BuildMemberSet(obj, memberSet);
	
	-- Loop through the set of member names and print them out, along with the value from the original object's
	-- perspective.
	for key, val in pairs(memberSet) do
		print(key, obj[key]);
	end
end

function Utils.B2IS(b)
	if false==b then
		return "0"
	else
		return "1"
	end
end

function Utils.IS2B(is)
	if is=="0" or is==0 then
		return false
	else
		return true
	end
end

function Utils.GetRandomString(n) 
    local t = {
        "0","1","2","3","4","5","6","7","8","9",
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
        "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    }    
    local s = ""
    for i =1, n do
        s = s .. t[math.random(#t)]        
    end;
    return s
end

function Utils.Lerp(a, b, t)
	local val = a + (b-a)*t
	return val
end

function wrap(func, ...)
	local args = {...}
	local co = coroutine.running()
	table.insert(args, function()
		coroutine.resume(co)
	end)
	func(unpack(args))
	coroutine.yield()
end

local _sleep = sleep
function sleep(second)
	wrap(_sleep, second)
end

local _sleepName = sleepName
function sleepName(second, name)
	wrap(_sleepName, second, name)
end

-----------------------------------------------------------------------------------------------------------------------
-- Vec3 class
-----------------------------------------------------------------------------------------------------------------------
Vec3 = class(nil, 
{
	x = 0,
	y = 0,
	z = 0,
	__operators = {},
});

function Vec3:Length()
	return math.sqrt((self.x * self.x) + (self.y * self.y) + (self.z * self.z));
end

function Vec3:Length2()
	return ((self.x * self.x) + (self.y * self.y) + (self.z * self.z));
end

function Vec3:Normalize()
	local len = self:Length();
	if 0.0==len then
		return 0.0
	end
	self.x = self.x / len;
	self.y = self.y / len;
	self.z = self.z / len;
	return len;
end

function Vec3:From(x, y, z)
	local temp = Vec3:New();
	temp.x = x;
	temp.y = y;
	temp.z = z;
	return temp;
end

function Vec3:FromVec(vecPX)
	local temp = Vec3:New();
	temp.x = vecPX[0];
	temp.y = vecPX[1];
	temp.z = vecPX[2];
	return temp;
end

function Vec3:ToAPoint()
	return APoint(self.x, self.y, self.z)
end

function Vec3:ToAVector()
	return AVector(self.x, self.y, self.z)
end

function Vec3:ToVector3()
	return Vector3(self.x, self.y, self.z)
end

function Vec3:Dot(vec3)
	return self.x * vec3.x + self.y * vec3.y + self.z * vec3.z
end

function Vec3.__operators.__add(left, right)
	local temp = Vec3:New();
	if (type(right) == "number") then
		temp.x = left.x + right;
		temp.y = left.y + right;
		temp.z = left.z + right;
	else
		temp.x = left.x + right.x;
		temp.y = left.y + right.y;
		temp.z = left.z + right.z;
	end
	return temp;
end

function Vec3.__operators.__sub(left, right)
	local temp = Vec3:New();
	if (type(right) == "number") then
		temp.x = left.x - right;
		temp.y = left.y - right;
		temp.z = left.z - right;
	else
		temp.x = left.x - right.x;
		temp.y = left.y - right.y;
		temp.z = left.z - right.z;
	end
	return temp;
end

function Vec3.__operators.__mul(left, right)
	local temp = Vec3:New();
	if (type(right) == "number") then
		temp.x = left.x * right;
		temp.y = left.y * right;
		temp.z = left.z * right;
	else
		temp.x = left.x * right.x;
		temp.y = left.y * right.y;
		temp.z = left.z * right.z
	end
	return temp;
end

function Vec3.__operators.__div(left, right)
	local temp = Vec3:New();
	if (type(right) == "number") then
		temp.x = left.x / right;
		temp.y = left.y / right;
		temp.z = left.z / right;
	else
		temp.x = left.x / right.x;
		temp.y = left.y / right.y;
		temp.z = left.z / right.z;
	end
	return temp;
end

function DeepCopy(tmp)
	if nil == tmp then 
		return nil 
	end
	local res = {}
	for key, val in pairs(tmp) do
		if type(val) == "table" then
			res[key] = DeepCopy(val)
		else
			res[key] = v
		end
	end
	return res
end

function isTableContain(tbl, value)
    for k,v in pairs(tbl) do
      if v == value then
          return true
      end
    end
    return false
end

function table.nums( t )
    local count = 0
    for k, v in pairs( t ) do
        count = count + 1
    end
    return count
end

-- agent
require("engine/scripts/lua/agent/engine_agent.lua")
require("engine/scripts/lua/json.lua")

function PX2_PlayFrameScale(frame)
	local ctrlPlay = frame:GetControllerByName("_ScaleCtrlPlay")
	if nil==ctrlPlay then
		ctrlPlay = InterpCurveUniformScaleController:New("_ScaleCtrlPlay")
		frame:AttachController(ctrlPlay)
		ctrlPlay:Clear()
		ctrlPlay:AddPoint(0.0, 1.0, ICM_CURVE_AUTO)
		ctrlPlay:AddPoint(0.1, 0.8, ICM_CURVE_AUTO)
	end
	ctrlPlay:ResetPlay()

	local ctrlStop = frame:GetControllerByName("_ScaleCtrlStop")
	if nil==ctrlStop then
		ctrlStop = InterpCurveUniformScaleController:New("_ScaleCtrlStop")
		frame:AttachController(ctrlStop)
		ctrlStop:Clear()
		ctrlStop:AddPoint(0.0, 0.8, ICM_CURVE_AUTO)
		ctrlStop:AddPoint(0.1, 1.0, ICM_CURVE_AUTO)
	end
	ctrlStop:Pause()
end

function PX2_PlayFrameNormal(frame)
	local ctrlPlay = frame:GetControllerByName("_ScaleCtrlPlay")
	if nil~=ctrlPlay then
		ctrlPlay:Pause()
	end

	local ctrlStop = frame:GetControllerByName("_ScaleCtrlStop")
	if nil~=ctrlStop then
		ctrlStop:ResetPlay()
	end
end

FES_NORMAL = 0
FES_ITALIC = 1
FES_UNDERLINE = 2

FD_NORMAL = 0
FD_SHADOW = 1
FD_BORDER = 2

TEXTALIGN_LEFT		=	1
TEXTALIGN_HCENTER	=	2
TEXTALIGN_RIGHT		=	4
TEXTALIGN_TOP		=	8
TEXTALIGN_VCENTER	=	16
TEXTALIGN_BOTTOM	=	32

RU_NONE		= 0
RU_ALIGNS	= 1
RU_CLIPWARP = 2

UIPT_NONE = 0
UIPT_PRESSED = 1
UIPT_RELEASED = 2
UIPT_DOUBLE_PRESSED = 3
UIPT_MOVED = 4
UIPT_WHELLED = 5
UIPT_MAX_TYPE = 6

DEG_TO_RAD = 0.01745
RAD_TO_DEG = 57.29578
PI = 3.1415926

PX2_ENABLE_PRINT = true

CMD_EngineUDPInfoTag = "myudpinfo"
CMD_EngineUDPConnectMeStr = "connectme"
CMD_PushProject = "pushproject"
CMD_LoadProject = "loadproject"
CMD_CloseProject = "closeproject"

function engine_AddLanguage()
	PX2_LM_ENGINE:Clear()
	PX2_LM_ENGINE:AddItem1("Phoenix", "PHOENIX")
	PX2_LM_ENGINE:AddItem1("PhoenixCreate", "PHOENIXCreate")
	PX2_LM_ENGINE:AddItem1("PhoenixFrame", "PHOENIXFrame")
	PX2_LM_ENGINE:AddItem1("Engine", "引擎")
	PX2_LM_ENGINE:AddItem1("Project", "项目")
	PX2_LM_ENGINE:AddItem1("Device", "设备")
	PX2_LM_ENGINE:AddItem1("Bluetooth", "蓝牙")
	PX2_LM_ENGINE:AddItem1("Scan", "扫描")
	PX2_LM_ENGINE:AddItem1("Connect", "连接")
	PX2_LM_ENGINE:AddItem1("DisConnect", "断开")
	PX2_LM_ENGINE:AddItem1("Infos", "信息")
	PX2_LM_ENGINE:AddItem1("Open", "打开")
	PX2_LM_ENGINE:AddItem1("Close", "关闭")
	PX2_LM_ENGINE:AddItem1("Serial", "串口")
	PX2_LM_ENGINE:AddItem1("Reload", "重载")
	PX2_LM_ENGINE:AddItem1("Clear", "清空")
	PX2_LM_ENGINE:AddItem1("Updating", "更新中")
	PX2_LM_ENGINE:AddItem1("Login", "登录")
	PX2_LM_ENGINE:AddItem1("Logout", "登出")
	PX2_LM_ENGINE:AddItem1("Download", "下载")
end

function engine_start()
	engine_AddLanguage()
	PX2_LOGGER:LogInfo("script_lua", "engine_start")
end
engine_start()

function engine_update(appSeconds, elapsedSeconds)
	-- important to do things to clear
	--collectgarbage("collect")
end