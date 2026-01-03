-- p_netsend.lua

-- 角色
-------------------------------------------------------------------------------
-- 发送角色状态
-- mapid:地图id
-- actorid:角色id
-- postr:位置字符串(带括号)，例如"(100.0, 10.0, 10.0)"
-- rotstr:旋转字符串
function p_net:_n_SendStateTrans(mapid, actorid, posstr, rotstr)
    local dt = {
        t = "m_a_state_trans",
        mid = mapid,
        id = actorid,
        pos = posstr,
        rot = rotstr,
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
-- 发送角色属性
-- mapid:地图id
-- actorid:角色id
-- pjson:角色属性json数据
function p_net:_n_SendProperty(mapid, actorid,pjson)
    local dt = {
        t = "m_setobj",
        mid = mapid,
        id = actorid,
        data = pjson,        
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--地图
--更新地图
function p_net:_n_GetRefreshMap(listMap)
	print(" p_net:_n_GetRefreshMap")
    listMap:RemoveAllItems()--add 5
    local dt = {
        t = "map_list",
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--请求添加map
--name：txt
function p_net:_n_RequestAddMap(name)
	print(" p_net:_n_RequestAddMap:"..name)

    local dt = {
        t = "map_add",
        name = name,
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--请求重置map
--mid:地图id
function p_net:_n_RequestResetMap(mid)
	print(" p_net:_n_RequestResetMap:")
    local dt = {
        t = "map_reset",
        mapid = mid
    }	
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--发送关闭地图
--mid：地图id
--uin：角色头顶标识
--charaid：角色id
function p_net:_n_SendCloseMap(mapid)
    local dt = {
        t = "map_close",
        mid = mapid,
        uin = g_manykit._uin
    }

    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--请求删除地图
--id：地图id（str）
function p_net:_n_RequestDeleteMap(id)
    local dt = {
        t = "map_delete",
        id = id,
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--放置物品
--itemid：物品id
--typeid：物品类型
--posstr：位置(str)
--uinn：uin编号
--rotstr：旋转角度(str)
--scalestr：缩放比例(str)
--group：阵营
--hp：生命
--curmapid：当前地图id
function p_net:_n_RequestAddObject(itemid, typeid, posstr, uinn, rotstr,
    scalestr, group, hp, curmapid, allname, posliststr)

    local dt = {
        t = "m_addobj",
        mid = curmapid,
        itemid = itemid,
        typeid = typeid,
        pos = posstr,
        uin = uinn,
    }
    if rotstr and ""~=rotstr then
        dt.rot = rotstr
    else
        dt.rot = APoint(0.0, 0.0, 0.0):ToString()
    end
    if scalestr and ""~=scalestr then
        dt.scale = scalestr
    else
        dt.scale = APoint(1.0, 1.0, 1.0):ToString()
    end
    if group then
        dt.group = group
    else
        dt.group = 1
    end
    if hp then
        dt.hp = hp
    else
        dt.hp = -1
    end
    if allname then
        dt.allname = allname
    end
    if posliststr then
        dt.posliststr = posliststr
    end
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--修改快捷背包项
-- roomid：房间id
-- mapid：地图id
-- charaid：角色id
-- tag：标示
-- index：背包索引 最左边是0
-- itemid：物品的id
function p_net:_n_SendQuickBarItem(skillMapID,charaID, tag, index, itemID)
    local dt = {
        t = "m_a_quickbaritem",
        mapid = skillMapID,
        charaid = charaID,
        tag = tag,
        index = index,
        itemid = itemID
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--删除物品
-- mid:地图id
-- id:物品id
function p_net:_n_RequestDeleteObj(id, curmapid)
	print(self._name.." p_net:_RequestDeleteObj:"..id)
    local dt = {
        t = "m_delobj",
        mid = curmapid,
        id = id,
    }
    print(self._name.." p_net:_RequestDeleteObj:"..id)
    print(self._name.." p_net:_RequestDeleteObj:"..curmapid)
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
-- 设置物品方向
-- mid 默认0 
-- id 地图id
-- group 阵营
-- hp 血量
function p_net:_n_RequestSetObjDirect(id, group, hp, curmapid)
    local dt = {
        t = "m_setobjdirect",
        mid = curmapid,
        id = id,
        group = group,
        hp = hp,
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--对物品坐标轴进行操作
-- scale 比例（str）
--  pos:角色所在位置
--  rot:旋转角度
function p_net:_n_RequestTranslateObj(id, exceptme, scalestr, rotstr, posstr, curmapid)
    local dt = {
        t = "m_transobj",
        mid = curmapid,
        id = id,
        scale = scalestr,
        rot = rotstr,
        pos = posstr,
    }
    if exceptme then
        dt.a = "b1"
    end
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--获取场景数据并发送
-- mid:地图id
-- propname:场景名
-- data:json数据
function p_net:_n_GetScenePropertyAndSend(propName, pjson, curmapid)
    local dt = {
        t = "map_set",
        mid = curmapid,
        propname = propName,
        data = pjson,        
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--请求装备武器——红蓝
-- mapid:地图id
-- charaid:角色id
-- weaponid:武器id
-- itemtypeid:武器类型id
function p_net:_n_RequestEquipItem_RB(weaponid, mid, itemtypeid, charaid)
    local dt = {
        t = "m_a_equipitem_rb",
        mapid = mid,
        charaid = charaid,
        weaponid = weaponid,
        itemtypeid = itemtypeid
    }	
    print("mid"..mid)
    print("charaid"..charaid)
    print("weaponid"..weaponid)
    print("itemtypeid"..itemtypeid)
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--修改装备是否装备
-- roomid：房间id
-- mapid：地图id
-- charaid：角色id
-- tag：标示
-- index：背包索引 最左边是0
-- itemid：物品的id
-- isequip：是否已经装备
function p_net:_n_SendItemEquipOrUnEquip(skillMapID, tag, index, iseq,itemID,charaID)
    local dt = {
        t = "m_a_itemequipornot",
        mapid = skillMapID,
        charaid = charaID,
        tag = tag,
        index = index,
        itemid = itemID,
        isequip = iseq
    }
    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------
--Ai行为
--  mid:地图id
--  charaid:角色id
--  type:类型
--  data:标示
--  pos:角色所在位置
--  rot:旋转角度
function p_net:_n_SendSetWayPointIndex(typestr, idx, mid, id, agent)
    if agent then
        local dt = {
            t = "m_a_steeringbehavior",
            mid = mid,
            charaid = id,
            type = typestr,
            data = idx,
            pos = agent:GetPosition():ToString(),
            rot = agent:GetRotateDegreeXYZ():ToString(),
        }
        self:_NetLogicSendJSon(dt)
    end
end
-------------------------------------------------------------------------------
--切换角色状态
-- mapid:地图id
-- charaid:角色id
-- sm:状态字符串
-- userdata:用户数据
function p_net:_n_RequestStateMachine(statemachinestr, mid, userdata, id, statemode)
    local dt = {
        t = "m_a_statemachine",
        mapid = mid,
        charaid = id,
        sm = statemachinestr,
    }
    if userdata then
        dt.userdata = userdata
    end
    if statemode then
        dt.statemode = statemode
    end
    self:_NetLogicSendJSon(dt)
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------
--确认角色状态
--  mapid:地图id
--  charaid:角色id
--  posture:姿势
--  group:角色阵营
--  hp:角色血量
--  upper:俯仰角度
--  subobjectsstr:子物体字符串
--  userdata:用户数据

function p_net:_n_SRequestState_getdata(mapid, charaid, posture, group, hp, rot, upper,subobjectsstr, userdatastr, posstrdirect)
    local dt = {
        t = "m_a_state",
        mapid = mapid,
        charaid = charaid,
    }
    if posture then
        dt.posture = posture
    end
    if group then
        dt.group = group
    end
    if hp then
        dt.hp = hp
    end
    if upper then
        dt.upper = upper
    end
    if rot then
        dt.rot = rot:ToString()
    end

    if subobjectsstr then
        dt.subobjects = subobjectsstr
    end

    if userdatastr then
        dt.userdatastr = userdatastr
    end

    if posstrdirect then
        dt.pos = posstrdirect
    end

    return dt
end

function p_net:_n_SRequestState(mapid, charaid, posture, group, hp, rot, upper,subobjectsstr, userdatastr, posstrdirect)
    local dt = self:_n_SRequestState_getdata(mapid, charaid, posture, group, hp, rot, upper,subobjectsstr, userdatastr, posstrdirect)

    self:_NetLogicSendJSon(dt)
end
-------------------------------------------------------------------------------