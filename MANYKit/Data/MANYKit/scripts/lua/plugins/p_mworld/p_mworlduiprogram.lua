-- p_mworlduiprogram.lua
-------------------------------------------------------------------------------
function p_mworld:_CreateFrameProgram(w, h)
    local uiFrame = UIFrame:New()
	uiFrame:SetAnchorHor(0.0, 1.0)
	uiFrame:SetAnchorVer(0.0, 1.0)

    if nil~=UIFrameCEF then
        local fsnappy = UIFrameCEF:New("UIFrameCEFSnappy")
        self._frameSnappy = fsnappy
        uiFrame:AttachChild(fsnappy)
        fsnappy:LLY(-2.0)
        fsnappy:SetAnchorHor(0.0, 1.0)
        fsnappy:SetAnchorVer(0.0, 1.0)
        fsnappy:SetURL("http://127.0.0.1:6606/snappy/snappypx.html")
    end

    return uiFrame
end
-------------------------------------------------------------------------------