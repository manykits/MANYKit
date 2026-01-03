-- p_actorgroup.lua

-------------------------------------------------------------------------------
function p_actor:_GetGroupByParty()
	local gp = 1

	if self._uin>0 then
		local id = self._node:GetID()

		local net = p_net._g_net
		if net then
			local peo = p_net._g_peoplesall[id]
			if peo then
				if ""==peo.party then
					gp = 0
				elseif "1"==peo.party then
					gp = 1
				elseif "2"==peo.party then
					gp = 2
				end
			end
		end
	end

	return gp
end
-------------------------------------------------------------------------------
function p_actor:_SetGroup(group)
	local act = self._actor
	if act and self._agent then	

		self._group = group

		p_actor:_sSetGroup(self._actor, group)

		if self._bdbar then
			local c = Float3.WHITE
			if 0==group then
				c = Float3(1.0, 1.0, 0.0)
			elseif 1==group then
				c = Float3(1.0, 0.0, 0.0)
			elseif 2==group then
				c = Float3(0.0, 0.0, 1.0)
			end
			self._bdbar:GetProgressPicBox():GetUIPicBox():SetColor(c)
			if self._fTextName then
				self._fTextName:GetText():SetFontColor(c)
			end
		end
	end
end
-------------------------------------------------------------------------------
function p_actor:_sSetGroup(act, group)
	print("group:"..group)

	if act then
		local sc = act:GetSkillChara()
		local agentBase = act:GetAIAgentBase()

		if 0==group then
			sc:SetGroupTypes(SkillChara.GT_0)
			agentBase:SetGroupTypes(AIAgentBase.GT_0)
		elseif 1==group then
			sc:SetGroupTypes(SkillChara.GT_1)
			agentBase:SetGroupTypes(AIAgentBase.GT_1)
		elseif 2==group then
			sc:SetGroupTypes(SkillChara.GT_2)
			agentBase:SetGroupTypes(AIAgentBase.GT_2)
		end
		
		local ctrl, scCtrl = g_manykit_GetControllerDriverFrom(act, "p_actor")
		if scCtrl then
			scCtrl._node:BeginPropertyCata("Actor")                
			PX2Table2Vector({ "0", "1", "2" })
			scCtrl._node:AddPropertyEnum("Group", "阵营", group, PX2_GH:Vec(), scCtrl._enablegp, scCtrl._enablegp)                 	
			scCtrl._node:EndPropertyCata()
		end
	end
end
-------------------------------------------------------------------------------