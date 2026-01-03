-- p_stateposture.lua
-------------------------------------------------------------------------------
-- StateP_Idle
StateP_Idle = {}
StateP_Idle["Enter"] = function(ptr)
  print("StateP_Idle Enter")

  local agent = Cast:ToObject(ptr)

  local actor = agent:GetNode()
  if actor then
    local ctrlHuman, scCtrlHuman = g_manykit_GetControllerDriverFrom(actor, "p_human")
    if scCtrlHuman then
        scCtrlHuman:_CheckSetPosture(scCtrlHuman._posture)
    end
  end
end
StateP_Idle["Update"] = function(ptr)
  local agent = Cast:ToObject(ptr)

end
StateP_Idle["Exit"] = function(ptr)
  print("StateP_Idle Exit")

  local agent = Cast:ToObject(ptr)

end
-------------------------------------------------------------------------------
-- StateP_Die
StateP_Die = {}
StateP_Die["Enter"] = function(ptr)
  print("StateP_Die Enter")

  local agent = Cast:ToObject(ptr)
  local actor = agent:GetNode()
  if actor then
    local mctrl = actor:GetModelController()
    if mctrl then
      actor:PlayAnimationWithItem("die")
    end
  end
end
StateP_Die["Update"] = function(ptr)
  local agent = Cast:ToObject(ptr)

end
StateP_Die["Exit"] = function(ptr)
  print("StateP_Die Exit")

  local agent = Cast:ToObject(ptr)

end
-------------------------------------------------------------------------------
-- StateP_Attack
StateP_Attack = {}
StateP_Attack["Enter"] = function(ptr)
  print("StateP_Attack Enter")

  local agent = Cast:ToObject(ptr)
end
StateP_Attack["Update"] = function(ptr)
  local agent = Cast:ToObject(ptr)

end
StateP_Attack["Exit"] = function(ptr)
  print("StateP_Attack Exit")

  local agent = Cast:ToObject(ptr)
end
-------------------------------------------------------------------------------