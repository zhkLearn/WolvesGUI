-- lua.exe script.lua

--io.write("Waiting for debug hook...")
--local str = io.read()

--package.cpath = "W:\\Debug\\?.dll"
require "Hook"

imageDir = "./GameX/"

--代码页     描述
--65001     UTF-8代码页
--950       繁体中文
--936       简体中文默认的GBK
--437       MS-DOS 美国英语
os.execute("CHCP 65001")


print("\n-------------------------------------------------------------------------------")
print("Test GameScene...")
local gs = GameScene(imageDir .. "Combat.png", false);
print("gs:SaveToFile")
gs:SaveToFile(imageDir .. "Combat_bak.png")

print("gs:IsValid: ", gs:IsValid())

function ScanNameRect(gs, x, y)
	local xStart = x - 50
	local xEnd = x + 50

	local yStart = y - 20
	local yEnd = y + 20

	local xMin = x + 100
	local xMax = x - 100

	local yMin = y + 100
	local yMax = y - 100
	
	for i = xStart, xEnd do
		for j = yStart, yEnd do
			local rgb = gs:GetPixel(SSize(i, j))
			if rgb.r > 128 and rgb.g < 20 and rgb.b < 10 then
				if i < xMin then
					xMin = i
				end
				if i > xMax then
					xMax = i
				end

				if j < yMin then
					yMin = j
				end
				if j > yMax then
					yMax = j
				end
			end
		end
	end
	
	return SRect(xMin, yMin, xMax, yMax)
end

local sz = gs:GetSize()
local gs2 = gs:Clone()

local theata = 0
local radius = 50
local lineSegementLen = 5
local prevX = sz.cx / 2 + 50
local prevY = sz.cy / 2 + 0
local stepCirle = 40

while radius < 200 do
	local delta = lineSegementLen / radius
	theata = theata + delta
	local x = sz.cx / 2 + radius * math.cos(theata)
	local y = sz.cy / 2 + radius * math.sin(theata)
	radius = radius + stepCirle * delta / (2 * math.pi)

	local rgb = gs:GetPixel(SSize(x, y))
	if rgb.r > 128 and rgb.g < 20 and rgb.b < 10 then
		gs2:Circle(SSize(x, y), 10, 0, 0, 255, 1, 4)
		gs2:Rectangle(ScanNameRect(gs, x, y), 0, 255, 0, 1, 4)
	end

	gs2:Line(SSize(prevX, prevY), SSize(x, y), 255, 0, 255, 1, 4)
	prevX = x
	prevY = y
end

gs2:ShowDebugWindow("gs Drawings")
GameScene.s_WaitKey(10000)
gs2:DestroyDebugWindow("gs Drawings")

--local rgb = gs:GetPixel(SSize(350, 250))
--print("GetPixel: ", rgb, rgb.r, rgb.g, rgb.b)

--gs2:Rectangle(SRect(100, 100, 300, 300), 255, 0, 255, 1, 8)
--gs2:Line(SSize(100, 100), SSize(300, 300), 255, 0, 255, 2, 4)

gs2:SaveToFile(imageDir .. "Combat_draw.png")




