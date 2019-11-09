-- lua.exe script.lua

--io.write("Waiting for debug hook...")
--local str = io.read()

--package.cpath = "W:\\Debug\\?.dll"
require "Hook"

--代码页     描述
--65001     UTF-8代码页
--950       繁体中文
--936       简体中文默认的GBK
--437       MS-DOS 美国英语
os.execute("CHCP 65001")

print("\n-------------------------------------------------------------------------------")
print("Test SSize...")
local pt = SSize(1, 2)
print(pt)

pt.cx = 3
pt.cy = 4
print(pt)


print("\n-------------------------------------------------------------------------------")
print("Test SSizeFloat...")
local pt2 = SSizeFloat(1.5, 2.5)
print(pt2)

pt2.cx = 3.5
pt2.cy = 4.5
print(pt2)


print("\n-------------------------------------------------------------------------------")
print("Test SRect...")
local rect = SRect(1, 2, 3, 4)
print("rect ", rect)

print("rect:IsValid()", rect:IsValid())
print("rect:Contains(2, 3)", rect:Contains(2, 3))
print("rect:Width() " .. rect:Width())
print("rect:Height() " .. rect:Height())
print("rect:Center()", rect:Center())

local rect2 = SRect(5, 6, 7, 8)
print("rect2 ", rect2)
print("rect:Union(rect2)", rect:Union(rect2))
print("rect2:OffsetRect(2, 2)", rect2:OffsetRect(2, 2))

local rectOut = SRect(0, 0, 0, 0)
print("rect:Intersect(rect2, rect3)", rect:Intersect(rect2, rectOut))
print("rectOut ", rectOut)

print("rect:Less(rectOut)", rect:Less(rectOut))


print("\n-------------------------------------------------------------------------------")
print("Test SRectVector...")
local rcVector = SRectVector()
print(rcVector:Size())
rcVector:Push(SRect(1, 2, 3, 4))
print(rcVector:Size())
print(rcVector:At(1))


print("\n-------------------------------------------------------------------------------")
print("Test String...")
local str = String("This is a test string.汉字。")
print(str)
print(tostring(str))

print("\n-------------------------------------------------------------------------------")
print("Test StringVector...")
local strVect = StringVector()
print("strVect:Size(): ", strVect:Size())
strVect:Push("str1")
strVect:Push("str2")
strVect:Push("str3")
print("strVect:Size(): ", strVect:Size())
print(strVect:At(1))


print("\n-------------------------------------------------------------------------------")
print("Test RGB...")
local rgb0 = SRGB(255, 0, 128)
print(rgb0, rgb0.r, rgb0.g, rgb0.b)

print("\n-------------------------------------------------------------------------------")
print("Test GameScene...")
local gs = GameScene("E:/1.png", false);
print("gs:SaveToFile")
gs:SaveToFile("E:/1_bak.png")

print("gs:IsValid: ", gs:IsValid())
print("gs:GetSize: ", gs:GetSize())
local gs2 = gs:Clone()
print("gs2 = gs:Clone()")
print("gs2:GetSize: ", gs2:GetSize())

local rcSub = SRect(100, 100, 300, 300)
print("gs3 = gs2:SubScene(rcSub)")
local gs3 = gs2:SubScene(rcSub)
print("gs3:GetSize: ", gs3:GetSize())

print("gs4 = gs:SubChannel(0)")
local gs4 = gs:SubChannel(0)
gs4:SaveToFile("E:/1_sub.png")

local rgb = gs:GetPixel(SSize(350, 250))
print("GetPixel: ", rgb, rgb.r, rgb.g, rgb.b)

gs2:Rectangle(SRect(100, 100, 300, 300), 255, 0, 255, 1, 8)
gs2:Line(SSize(100, 100), SSize(300, 300), 255, 0, 255, 2, 4)
gs2:Circle(SSize(100, 100), 100, 0, 255, 0, 1, 4)
gs2:PutText("This a string. Does not support Chinese.", SSize(100, 100), 255, 0, 0, 1, 1)
gs2:PutText("This a another string.", SSize(100, 120), 0, 255, 0, 1, 2)

gs2:ShowDebugWindow("gs2 Drawings")
GameScene.s_WaitKey(2000)
gs2:DestroyDebugWindow("gs2 Drawings")

-- CV_BGR2GRAY    =6,
-- CV_RGB2GRAY    =7,
gs2:TransformColor(6)	--CV_BGR2GRAY
--gs2:ShowDebugWindow("gs2 Drawings")
--GameScene.s_WaitKey(2000)
	
-- > 1增强, < 1减小
gs2:ContrastAdjust(1.5)
--gs2:ShowDebugWindow("gs2 Drawings")
--GameScene.s_WaitKey(2000)

-- xScale
-- yScale
-- INTER_NEAREST = 0, INTER_LINEAR, INTER_CUBIC, INTER_AREA, INTER_LANCZOS4
gs2:Resize(2.0, 2.0, 1)
print("gs2:GetSize: ", gs2:GetSize())

-- ksize must be positive and odd
gs2:Blur(3, 3)
--gs2:ShowDebugWindow("gs2 Drawings")
--GameScene.s_WaitKey(2000)

-- CV_THRESH_BINARY      =0,  /* value = value > threshold ? max_value : 0       */
-- CV_THRESH_BINARY_INV  =1,  /* value = value > threshold ? 0 : max_value       */	
-- CV_THRESH_TRUNC       =2,  /* value = value > threshold ? threshold : value   */
-- CV_THRESH_TOZERO      =3,  /* value = value > threshold ? value : 0           */
-- CV_THRESH_TOZERO_INV  =4,  /* value = value > threshold ? 0 : value           */
-- CV_THRESH_MASK        =7,
-- CV_THRESH_OTSU        =8  /* use Otsu algorithm to choose the optimal threshold value; combine the flag with one of the above CV_THRESH_* valus */
gs2:Threshold(220, 255, 3)	--CV_THRESH_TOZERO
--gs2:ShowDebugWindow("gs2 Drawings")
--GameScene.s_WaitKey(2000)

-- MORPH_RECT=0, MORPH_CROSS=1, MORPH_ELLIPSE=2
-- is_erode = true
-- size must be odd
gs2:ErodeDilate(1, true, 3)
--gs2:ShowDebugWindow("gs2 Drawings")
--GameScene.s_WaitKey(2000)

gs2:SaveToFile("E:/1_draw.png")




