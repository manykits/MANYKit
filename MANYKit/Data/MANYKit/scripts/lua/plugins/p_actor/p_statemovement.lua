-- p_statemovement.lua
-------------------------------------------------------------------------------
-- StateM_GoTo
StateM_GoTo = {}

StateM_GoTo["Enter"] = function(ptr)
  print("StateM_GoTo Enter")
  local agent = Cast:ToObject(ptr)
  local act = Cast:ToActor(agent:GetNode())
  if act then
    agent:SetSteeringBehaviorSetForward(true)

    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
    if scCtrl then        
        local userdata = act:GetUserDataString("simuuserdata")  
        
        local ldt = PX2JSon.decode(userdata)
        local type = ldt.type
        local pos = APoint:SFromString(ldt.pos)
        local speed = ldt.speed
        local state = ldt.state

        scCtrl:_StateMovementGoTo(pos, speed, state)
    end
  end
end

StateM_GoTo["Update"] = function(ptr)
  local agent = Cast:ToObject(ptr)

  -- bat check
  if p_net._g_net._islogicserver then
    local agent = Cast:ToObject(ptr)
    local act = agent:GetNode()
    local id = act:GetID()

    local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
    if scCtrl then
        local isOver = scCtrl._agent:GetAISteeringPath():IsFinished()        
        if isOver then    
          p_net._g_net:_RequestStateMachine("StateM_Stop", "", id, "movement")
        end
    end
  end
end

StateM_GoTo["Exit"] = function(ptr)
  print("StateM_GoTo Exit")
  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------
-- StateM_Stop
StateM_Stop = {}

StateM_Stop["Enter"] = function(ptr)
  print("StateM_Stop Enter")

  local agent = Cast:ToObject(ptr)
  agent:ClearPath()
  agent:SetSpeed(0.0)

  local act = Cast:ToActor(agent:GetNode())
  if act then
    local scene = PX2_PROJ:GetScene()
    if scene then
        local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_chara")
        if scCtrl then
            scCtrl:_CheckSetPosture(scCtrl._posture)
        end
    end
  end
end

StateM_Stop["Update"] = function(ptr)

  local agent = Cast:ToObject(ptr)

end

StateM_Stop["Exit"] = function(ptr)
  print("StateM_Stop Exit")

  local agent = Cast:ToObject(ptr)

end
-------------------------------------------------------------------------------