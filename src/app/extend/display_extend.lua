local _M=display or {}

function _M.newLabel(text,size,color)
	local size=size or 28
    local color=color or cc.c3b(255,255,255)
    local outlineColor = outlineColor or cc.c4b(0, 0, 0, 255)
    local outline = outline or 0  
    local label=cc.Label:createWithTTF(text or "","fonts/graphicpixel-webfont.ttf",size)
    label:enableOutline(outlineColor, outline)
    label:setColor(color)
    return label
end
