-- p_gmanykitfun.lua

-------------------------------------------------------------------------------
function manykit_start()
	print("manykit_start")

	PX2_LOGGER:GetFileHandler(0):SetLevels(LT_USER)
	PX2_LOGGER:AddFileHandler("./log_manykit.txt", LT_USER)
	print_u("log manykit start")

	if 1 == g_manykit._lessfullmode then
        PX2_APP:LoadPlugin("PExt", "PExt")

		PX2_OPENCVM:SetConfigName("MANYKit")
		PX2_OPENCVM:Initlize()

        if PX2_SS then
            PX2_SS:SetRecordingDeviceIndex(0)
            PX2_SS:StartRecording(1.0, true)
        end

        PX2_OPENCVM:CreateMediaSystem(Sizef(1280, 720), Sizef(1280, 720))
        PX2_OPENCVM:SetTexturePreCreateCombineName("name_0", "", "")
        PX2_OPENCVM:SetTexturePreCreateCombineSize(Sizef(640, 480))
    
        PX2_OPENCVM:EnableUpdate(true)
        PX2_OPENCVM:SetTexturePreCreateCombine(true)
	end

	-- unregist all events
	manykit_unRegistEvents()

	-- language set
	PX2_LM_APP:Clear()
	PX2_LM_APP:SetLanguage(1)

	-- create ui collect plugins, call
	g_manykit:Initlize()

	PX2_RM:SetUseGarbageCollect(true)
end
-------------------------------------------------------------------------------
function manykit_unRegistEvents()
	UnRegistAllEventFunctions("SerialES::Open")
    UnRegistAllEventFunctions("SerialES::Close")
    UnRegistAllEventFunctions("AIES::LiDarOpen")
    UnRegistAllEventFunctions("AIES::LiDarClose")
    UnRegistAllEventFunctions("AIES::AxisOpen")
    UnRegistAllEventFunctions("AIES::AxisClose")
	UnRegistAllEventFunctions("AIES::PathPlanerResult")
    UnRegistAllEventFunctions("GraphicsES::GeneralString")
    
	UnRegistAllEventFunctions("InputEventSpace::KeyPressed")
    UnRegistAllEventFunctions("InputEventSpace::KeyReleased")
	UnRegistAllEventFunctions("InputEventSpace::MousePressed")
	UnRegistAllEventFunctions("InputEventSpace::MouseReleased")
	UnRegistAllEventFunctions("InputEventSpace::SpatialLost")
	UnRegistAllEventFunctions("InputEventSpace::SpatialDetected")
	UnRegistAllEventFunctions("InputEventSpace::SpatialUpdate")
end
-------------------------------------------------------------------------------
function manykit_UpdateHand(handIndex)
	-- hand
	local handLeftSide = nil
	local handRightSide = nil
	
	if 0==handIndex then
		handLeftSide = g_manykit._handmarks.leftside.lefthand
		handRightSide = g_manykit._handmarks.rightside.lefthand
	else
		handLeftSide = g_manykit._handmarks.leftside.righthand
		handRightSide = g_manykit._handmarks.rightside.righthand
	end

	if handLeftSide and handRightSide then
		if 0==handIndex then
			p_net._g_net._rectHandTimingLeft = 0.0
		elseif 1==handIndex then
			p_net._g_net._rectHandTimingRight = 0.0
		end

		local landmarks_leftside = handLeftSide.landmarks
		local landmarks_rightside = handRightSide.landmarks
		local numl = #landmarks_leftside
		local numr = #landmarks_rightside

		local scene = PX2_PROJ:GetScene()
		local cameraNodeRoot = scene:GetMainCameraNodeRoot()  

		local ht = HT_LEFT
		if 0==handIndex then
			ht = HT_LEFT
		elseif 1==handIndex then
			ht = HT_RIGHT
		end
		PX2_INPUTM:SetHandGesture(ht, handLeftSide.gesture)

		landmarks_leftside.pos3ds = {}
		if numl==numr and 21==numl then
			for i, v in ipairs(landmarks_leftside) do
				local posl = v.pos2d

				local vr = landmarks_rightside[i]
				local posr = vr.pos2d

				local pos3d = manykit_CalCameraPos(posl, posr)
				pos3d = pos3d + g_manykit._camObjOffset

				pos3d = g_manykit._mapSlamTrans:Multip(pos3d)

				if 0==handIndex then
					PX2_INPUTM:SetHandPosition(ht, i-1, pos3d)
				elseif 1==handIndex then
					PX2_INPUTM:SetHandPosition(ht, i-1, pos3d)
				end

				table.insert(landmarks_leftside.pos3ds, pos3d)
			end
		end

		local handNode = Cast:ToNode(g_manykit._nodeHandsRoot:GetChild(handIndex))

		for i, v in ipairs(landmarks_leftside.pos3ds) do
			if handNode then
				local pos3d = landmarks_leftside.pos3ds[i]

				local box = handNode:GetChild(i-1)
				if box then
					local posOffSet = APoint(pos3d:X(), pos3d:Y(), pos3d:Z())
					box.LocalTransform:SetTranslate(posOffSet)
				end
			else
				print("hand null")
			end
		end
	end
end
-------------------------------------------------------------------------------
function manykit_UpdateMRTranslate()
    local platType = PX2_APP:GetPlatformType()
    if Application.PLT_UWP==platType then
    else
        local posCam = PX2_OPENCVM:GetSlamCameraPos(3)
		local rd = PX2_OPENCVM:GetSlamCameraRotDegree(3)

		g_manykit._mapPosSlam = posCam
		g_manykit._mapRotSlam = rd

        g_manykit._mapPos = posCam
        g_manykit._mapRot = rd

		local posLast = APoint(g_manykit._mapPos:X(), g_manykit._mapPos:Y(), g_manykit._mapPos:Z()+g_manykit._mrHeightAdjust)
		local rotLast = AVector(g_manykit._mapRot:X() + g_manykit._mapRotOffset:X(), g_manykit._mapRot:Y() + g_manykit._mapRotOffset:Y(),
			g_manykit._mapRot:Z() + g_manykit._mapRotOffset:Z())

        local scene = PX2_PROJ:GetScene()
        if scene then
            -- camera
			p_holospace._g_cameraPlayCtrl:Enable(false)   
            local cameraNodeRoot = scene:GetMainCameraNodeRoot()

			g_manykit._mapSlamTrans:SetRotateDegree(rotLast:X(), rotLast:Y(), rotLast:Z())
			g_manykit._mapSlamTrans:SetTranslate(posLast)

            cameraNodeRoot.LocalTransform:SetRotateDegree(rotLast:X(), rotLast:Y(), rotLast:Z())
			cameraNodeRoot.LocalTransform:SetTranslate(posLast)
            cameraNodeRoot:Update()

			local offZBox = 1.0
            -- vslam box
            if g_manykit._boxVSlam then
                local pos = PX2_OPENCVM:GetSlamCameraPos(0)
                local rot = PX2_OPENCVM:GetSlamCameraRotDegree(0)
                --g_manykit._boxVSlam.LocalTransform:SetRotateDegree(rot:X(), rot:Y(), rot:Z())
                g_manykit._boxVSlam.LocalTransform:SetTranslate(APoint(-1,  5, offZBox))
            end

            -- imu box
            if g_manykit._boxIMU then
                local pos = PX2_OPENCVM:GetSlamCameraPos(1)
                local rot = PX2_OPENCVM:GetSlamCameraRotDegree(1)
                --g_manykit._boxIMU.LocalTransform:SetRotateDegree(rot:X(), rot:Y(), rot:Z())
                g_manykit._boxIMU.LocalTransform:SetTranslate(APoint(0,  5, offZBox))
            end

            -- slam box
            if g_manykit._boxSlam then
                local pos = PX2_OPENCVM:GetSlamCameraPos(3)
                local rot = PX2_OPENCVM:GetSlamCameraRotDegree(3)
                --g_manykit._boxSlam.LocalTransform:SetRotateDegree(rot:X(), rot:Y(), rot:Z())
                g_manykit._boxSlam.LocalTransform:SetTranslate(APoint(1,  5, offZBox))
            end
        end
    end
end
-------------------------------------------------------------------------------
function manykit_UpdateGunTranslate()
	-- camobjs	april tag
	local numCameraPreCreate = PX2_OPENCVM:GetNumCVCameraObjPreCreate()
	for i=0, numCameraPreCreate-1, 1 do
		local cvCamObj = PX2_OPENCVM:GetCVCameraObjPreCreate(i)
		if cvCamObj then
			local isOpen = cvCamObj:IsOpenAprilTagDetect()
			--print_i_b(isOpen)
			if isOpen then
				if CVCameraObjBase.VCT_CARINA==cvCamObj.TheVCType then
					local p0, ret0 = manykit_CalAprilTagPos(cvCamObj, 1)
					local p1, ret1 = manykit_CalAprilTagPos(cvCamObj, 8)

					p0 = p0 + g_manykit._camObjOffset
					local p00 = g_manykit._mapSlamTrans:Multip(p0)
					if ret0 then				
						g_manykit._nodeAprilTagBox0.LocalTransform:SetTranslate(p00)

						g_manykit._nodeAprilTagBox0:Show(true)
					else
						g_manykit._nodeAprilTagBox0:Show(false)
					end

					g_manykit._nodeAprilTag:Show(false)

					p1 = p1 + g_manykit._camObjOffset
					local p01 = g_manykit._mapSlamTrans:Multip(p1)
					if ret1 then
						g_manykit._nodeAprilTagBox1.LocalTransform:SetTranslate(p01)

						g_manykit._nodeAprilTagBox1:Show(true)
					else
						g_manykit._nodeAprilTagBox1:Show(false)
					end

					if ret0 and ret1 then
						PX2_GH:SetSpaceInputTrans(p00, p01, g_manykit._camObjOffsetRot)
						local dir = PX2_GH:GetSpaceInputDirection()

						local p001 = p00 + dir*1000
						PX2_ENGINESCENECANVAS:AddDebugLine(p00, p001, Float4(0.0, 1.0, 0.0, 1.0))
					end
				elseif cvCamObj.VCT_V4L2==cvCamObj.TheVCType or cvCamObj.VCT_NORMAL==cvCamObj.TheVCType then

					local aTag00 = cvCamObj:GetAprilTagDetectObjByTagID(0, 0)
					local c00 = aTag00.Center
					local tagID0 = aTag00.TagID
					local dir = aTag00.Dir
					local degree = aTag00.Degree
					local detCurFrame = aTag00.IsDetectedCurFrame
					g_manykit._nodeAprilTagBox0:Show(true)

					if detCurFrame then
						local c00_offset = c00 + g_manykit._camObjOffset
						local c00_offset1 = c00_offset + dir * 100.0

						local c00_offset_trans = g_manykit._mapSlamTrans:Multip(c00_offset)
						local c00_offset_trans1 = g_manykit._mapSlamTrans:Multip(c00_offset1)

						g_manykit._nodeAprilTagBox0.LocalTransform:SetTranslate(c00_offset_trans)
						g_manykit._nodeAprilTagBox0.LocalTransform:SetRotateDegree(degree:X(), degree:Y(), degree:Z())

						PX2_ENGINESCENECANVAS:AddDebugLine(c00_offset_trans, c00_offset_trans1, Float4(0.0, 1.0, 0.0, 1.0))
					end
				end	
			end			
		end
	end
end
-------------------------------------------------------------------------------
function manykit_CalAprilTagPos(cvCamObj, tagID)
	--
	local aTag00 = cvCamObj:GetAprilTagDetectObjByTagID(0, tagID)
	local c00 = aTag00.Center
	local tagID0 = aTag00.TagID
	local detCurFrame = aTag00.IsDetectedCurFrame
		
	local aTag10 = cvCamObj:GetAprilTagDetectObjByTagID(1, tagID)
	local c10 = aTag10.Center
	local tagID1 = aTag10.TagID
	local detCurFrame1 = aTag10.IsDetectedCurFrame

	if detCurFrame and detCurFrame1 then
		return manykit_CalCameraPos(c00, c10), true
	else
		return APoint(0,0,0), false
	end
end
-------------------------------------------------------------------------------
function manykit_CalCameraPos(c00, c10)
	local dist = 0.08394980069220727

	local fxfycxcy = PX2_OPENCVM:GetCameraMatrixParamFXFYCXCY(0, 0)
	local ck = PX2_OPENCVM:GetCameraMatrixParamCoeffesK(0, 0)
	local cp = PX2_OPENCVM:GetCameraMatrixParamCoeffesP(0, 0)

	local fxfycxcy1 = PX2_OPENCVM:GetCameraMatrixParamFXFYCXCY(0, 1)
	local ck1 = PX2_OPENCVM:GetCameraMatrixParamCoeffesK(0, 1)
	local cp1 = PX2_OPENCVM:GetCameraMatrixParamCoeffesP(0, 1)

	ck = Float4(0.0, 0.0, 0.0, 0.0)
	cp = Float4(0.0, 0.0, 0.0, 0.0)

	ck1 = Float4(0.0, 0.0, 0.0, 0.0)
	cp1 = Float4(0.0, 0.0, 0.0, 0.0)

	-- 
	local p = PX2_OPENCVM:Calculate3DPoint(c00:X(), c00:Y(), c10:X(), c10:Y(),
	fxfycxcy:X(), fxfycxcy:Y(), fxfycxcy:Z(), fxfycxcy:W(),
	dist,
	ck:X(), ck:Y(), cp:X(), cp:Y())
	p = APoint(p:X(), p:Z(), -p:Y())

	local pl2 = PX2_OPENCVM:Calculate3DPoint(
		c00:X(), c00:Y(), c10:X(), c10:Y(),
		fxfycxcy:X(), fxfycxcy:Y(), fxfycxcy:Z(), fxfycxcy:W(),
		ck:X(), ck:Y(), cp:X(), cp:Y(),
		fxfycxcy1:X(), fxfycxcy1:Y(), fxfycxcy1:Z(), fxfycxcy1:W(),
		ck1:X(), ck1:Y(), cp1:X(), cp1:Y(),
		dist)

	pl2 = APoint(pl2:X() - dist/2.0, pl2:Z(), -pl2:Y())

	return pl2
end
-------------------------------------------------------------------------------
