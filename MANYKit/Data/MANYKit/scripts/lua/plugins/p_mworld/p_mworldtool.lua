-- p_mworldtool.lua

-------------------------------------------------------------------------------
function p_mworld:_CreateModelOutPut()
    local scene = PX2_PROJ:GetScene()
    local nodeHelp = scene:GetObjectByID(p_holospace._g_IDNodeHelp)
    if nodeHelp then
        if FBXImporter then
            local fbxI = FBXImporter:New()
            fbxI:Import("models/actors/zhanshi/test123.fbx", true)
            local n = fbxI:GetPX2Node()
            if n then
                fbxI:SavePX2Node("models/actors/zhanshi/modelindia.px2obj")
                nodeHelp:AttachChild(n)
                n.LocalTransform:SetUniformScale(0.01)
                n.LocalTransform:SetRotateDegree(90, 0.0, 0.0)
                n.LocalTransform:SetTranslateZ(11.0)
                n:ResetPlay()
            end

            local obj = PX2_RM:BlockLoadCopy("models/actors/zhanshi/modelindia.px2obj")
            local mov = Cast:ToMovable(obj)
            if mov then
                nodeHelp:AttachChild(mov)
                mov.LocalTransform:SetUniformScale(0.01)
                mov.LocalTransform:SetRotateDegree(90, 0.0, 0.0)
                mov.LocalTransform:SetTranslateX(2.0)
                mov.LocalTransform:SetTranslateZ(11.0)
                mov:ResetPlay()
            end
        end
    end
end
-------------------------------------------------------------------------------