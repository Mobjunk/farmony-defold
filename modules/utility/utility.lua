local utility = {}

function utility.color(r, g, b)
	return vmath.vector4(r / 255, g / 255, b / 255, 255 / 255)
end

function utility.get_color(r, g, b, a)
	return vmath.vector4(r / 255, g / 255, b / 255, a / 255)
end

return utility