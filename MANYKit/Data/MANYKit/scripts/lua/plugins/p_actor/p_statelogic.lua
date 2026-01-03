-- p_statelogic.lua
-------------------------------------------------------------------------------
-- StateL_Null
StateL_Null = {}
StateL_Null["Enter"] = function(ptr)
  print("StateL_Null Enter")

  local agent = Cast:ToObject(ptr)
  agent:GetFSM_Posture():ChangeState("StateP_Idle")
  agent:GetFSM_Movement():ChangeState("StateM_Stop")
end
StateL_Null["Update"] = function(ptr)

end
StateL_Null["Exit"] = function(ptr)
  print("StateL_Null Exit")
  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------
-- StateL_Alive
StateL_Alive = {}
StateL_Alive["Enter"] = function(ptr)
  print("StateL_Alive Enter")

  local agent = Cast:ToObject(ptr)
  local act = agent:GetNode()

  agent:GetFSM_Posture():ChangeState("StateP_Idle")
  agent:GetFSM_Movement():ChangeState("StateM_Stop")

  local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
  if scCtrl then
      scCtrl:_OnReAlive()
  end 
end
StateL_Alive["Update"] = function(ptr)
  if p_net._g_net._islogicserver then
    local agent = Cast:ToObject(ptr)
    local act = agent:GetNode()

    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
    if scCtrl then
        scCtrl:_OnDetectBattleAttack()
    end
  end
end
StateL_Alive["Exit"] = function(ptr)
  print("StateL_Alive Exit")
  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------
-- StateL_Attack
StateL_Attack = {}
StateL_Attack["Enter"] = function(ptr)
  print("StateL_Attack Enter")
  local agent = Cast:ToObject(ptr)

  agent:GetFSM_Posture():ChangeState("StateP_Attack")
  agent:GetFSM_Movement():ChangeState("StateM_Stop")
end
StateL_Attack["Update"] = function(ptr)

  -- bat
  if p_net._g_net._islogicserver then
    local agent = Cast:ToObject(ptr)
    local act = agent:GetNode()

    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
    if scCtrl then
      scCtrl:_SL_AttackUpdate()
    end
  end
end
StateL_Attack["Exit"] = function(ptr)
  print("StateL_Attack Exit")
  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------
-- StateL_FreeAttack
StateL_FreeAttack = {}
StateL_FreeAttack["Enter"] = function(ptr)
  print("StateL_FreeAttack Enter")
  local agent = Cast:ToObject(ptr)
  local act = agent:GetNode()
  local skillChara = act:GetSkillChara()

  local userdata = act:GetUserDataString("simuuserdata")
  print("simuuserdata:"..userdata)
  
  local jsondata = PX2JSon.decode(userdata)
  local weaponTypeId = jsondata.weaponTypeId
  local points = jsondata.points

  agent:GetFSM_Posture():ChangeState("StateP_Attack")
  agent:GetFSM_Movement():ChangeState("StateM_Stop")

  local useAimingPosBefore = skillChara:IsFlyObjectUseAimingPos()      

  local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
  local ctrlHuman, scCtrlHuman = g_manykit_GetControllerDriverFrom(act, "p_human")
  local ctrlVehicle, scCtrlVehicle = g_manykit_GetControllerDriverFrom(act, "p_vehicle")
  if scCtrl then
    scCtrl._isControllingByOther = true

    coroutine.wrap(function()
      local lastsec = 0.0
      for key, value in pairs(points) do
        local delay = value.delay
        print("delay:"..delay)  
  
        local t = value.delay/1000.0
        local sec = t - lastsec
        lastsec = t
  
        local p = APoint(value.x, value.y, value.z);

        local dir = p - agent:GetPosition()

        local z = dir:Z()
        local degreeZ = Mathf:ATan(z/Mathf:Sqrt(dir:X()*dir:X() + dir:Y()*dir:Y()))*RAD_TO_DEG

        if scCtrlHuman then
          scCtrl:_SetUpperDegree(degreeZ)
        end
        if scCtrlVehicle then
          print("weaponTypeId:"..weaponTypeId)

          local defItem = PX2_SDM:GetDefItemByUserData(weaponTypeId)
          if defItem then
            scCtrlVehicle:_SetItemRot(defItem.ID, APoint(degreeZ, 0, 0))
          end
        end

        agent:SetForward(dir)
      end

      scCtrl._isControllingByOther = false
    end)()
  end
end
StateL_FreeAttack["Update"] = function(ptr)

  -- bat
  if p_net._g_net._islogicserver then
    local agent = Cast:ToObject(ptr)
    local act = agent:GetNode()

  end
end
StateL_FreeAttack["Exit"] = function(ptr)
  print("StateL_FreeAttack Exit")
  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------
-- StateL_Die
StateL_Die = {}
StateL_Die["Enter"] = function(ptr)
    print("StateL_Die Enter")
    local agent = Cast:ToObject(ptr)
    agent:GetFSM_Posture():ChangeState("StateP_Die")
    agent:GetFSM_Movement():ChangeState("StateM_Stop")

    local act = agent:GetNode()
    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
    if scCtrl then
      scCtrl:_OnDie()
    end
end
StateL_Die["Update"] = function(ptr)
  local agent = Cast:ToObject(ptr)
end
StateL_Die["Exit"] = function(ptr)
  print("StateL_Die Exit")
  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------
-- StateL_SelfCtrl
StateL_SelfCtrl = {}
StateL_SelfCtrl["Enter"] = function(ptr)
    print("StateL_SelfCtrl Enter")

end
StateL_SelfCtrl["Update"] = function(ptr)
  local agent = Cast:ToObject(ptr)
end
StateL_SelfCtrl["Exit"] = function(ptr)
  print("StateL_SelfCtrl Exit")
  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------