
g_theSharedTableName = "theSharedTable"


function CreatEnumTable(tbl, index) 
    assert(type(tbl) == "table") 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i - 1 
    end 
    return enumtbl 
end 

function IsInTable(tbl, value)
	for k,v in ipairs(tbl) do
		if v == value then
			return true;
		end
	end
	return false;
end

----------------------------------------------------------
TableLogLevel = 
{ 
    "eDebug", 
    "eInfo", 
    "eWarn", 
    "eError", 
    "eFatal", 
}

TableLogLevelCap = 
{ 
    "Debug", 
    "Info", 
    "Warn", 
    "Error", 
    "Fatal", 
}

EnumLogLevel = CreatEnumTable(TableLogLevel, 1) 

----------------------------------------------------------
-- 模块
TableSubModule = 
{ 
    "eCombat", 
    "ePlant", 
}

TableSubModuleCap = 
{ 
    "打怪", 
    "种植", 
}

EnumSubModule = CreatEnumTable(TableSubModule, 1) 
--print(EnumSubModule.eCombat) 
--print(EnumSubModule.ePlant) 
--print(EnumSubModule.eLast) 

----------------------------------------------------------
-- 支持的按键
TableKeys = 
{ 
    "F1", 
    "F2", 
    "F3", 
    "F4", 
    "F5", 
    "F6", 
    "F7", 
    "F8", 
    "F9", 
    "F10", 
}

TableKeysCap = 
{ 
    "F1 ", 
    "F2 ", 
    "F3 ", 
    "F4 ", 
    "F5 ", 
    "F6 ", 
    "F7 ", 
    "F8 ", 
    "F9 ", 
    "F10", 
}

TableKeysValue = 
{ 
    112, 	--F1
    113, 
    114, 
    115, 
    116, 
    117, 
    118, 
    119, 
    120, 
    121, 	--F10
}

EnumKeys = CreatEnumTable(TableKeys, 1) 

----------------------------------------------------------
--百分比
TableBloodRatio = 
{ 
    0.9,
    0.8,
    0.7, 
    0.6, 
    0.5, 
    0.4, 
    0.3, 
    0.2, 
    0.1, 
}

TableBloodRatioCap = 
{ 
    "90%",
    "80%",
    "70%", 
    "60%", 
    "50%", 
    "40%", 
    "30%", 
    "20%", 
    "10%", 
}

----------------------------------------------------------
--选怪
TableTargetMode = 
{
	"eFreq",
	"eFocusCurrent"
}

TableTargetModeCap = 
{
	"定时切换",
	"打死换怪"
}

EnumTargetMode = CreatEnumTable(TableTargetMode, 1) 

----------------------------------------------------------
GaugeBar = {
	name = "GaugeBar",
	ptTopLeft = SSize(0, 0),
	ptBottomRight = SSize(0, 0),
	expectRGB = SRGB(0, 0, 0),
	toleranceRGB = SRGB(0, 0, 0),
	mightThreeLines = false,
	IsPointFull = function(self, gs, pt)
		local rgb = gs:GetPixel(pt)
		return math.abs(rgb.r - self.expectRGB.r) <= self.toleranceRGB.r 
			and math.abs(rgb.g - self.expectRGB.g) <= self.toleranceRGB.g
			and math.abs(rgb.b - self.expectRGB.b) <= self.toleranceRGB.b;
	end,
	
	IsFull = function(self, robot)
		local gs = robot:GetCurGameScene()
		if gs == nil then
			return false
		end

		return self:IsPointFull(gs, self.ptBottomRight)
	end,

	IsEmpty = function(self, robot)
		local gs = robot:GetCurGameScene()
		if gs == nil then
			return false
		end

		return not self:IsPointFull(gs, self.ptBottomRight)
	end,

	GetRatio = function(self, robot)
		local len = self.ptBottomRight.cx - self.ptTopLeft.cx
		if len <= 0 then
			return 0
		end
		
		local gs = robot:GetCurGameScene()
		if gs == nil then
			return 0
		end

		local start = self.ptTopLeft
		local lines = 1
		if self.mightThreeLines then
			local ptLines = start
			ptLines.cy = ptLines.cy + 8
			if self:IsPointFull(gs, ptLines) then
				lines = 3
			end
		end
		
		local count = 0
		for j = 1, lines do
			local ptLines = start
			ptLines.cy = ptLines.cy + (j - 1) * 8
			for i = 1, len do
				if self:IsPointFull(gs, ptLines) then
					count = count + 1
				else
					break
				end

				ptLines.cx = ptLines.cx + 1
			end
		end
		
		return 1.0 * count / (len * lines)
	end,

	new = function(self, o)
		o = o or {}
		self.__index = self
		setmetatable(o, self)
		return o
	end
}

----------------------------------------------------------
SimpleTimer =
{
	iTimeLength = 1000,
	iTimeCur = 0,
	bEnabled = true,
	bRepeat = true,

	--时间单位毫秒
	SetTimer = function(self, len, rep, triggerAtOnce)
		self.bEnabled		= true;
		self.bRepeat		= rep;
		self.iTimeLength	= len;
		if triggerAtOnce then
			self.iTimeCur = self.iTimeLength;
		else
			self.iTimeCur = 0;
		end
	end,
	
	--重置当前时间, 时间周期不变
	ResetTimer = function(self)
		self.iTimeCur = 0;
	end,

	--传入间隔时间，毫秒. 返回Timer是否触发.
	OnTimer = function(self, iDelta)
		if not self.bEnabled then	
			return false;
		end

		self.iTimeCur = self.iTimeCur + iDelta;
		if self.iTimeCur >= self.iTimeLength then
			if (self.bRepeat) then
				self.iTimeCur = 0;
			else
				self.bEnabled = false;
			end

			return true;
		end
		
		return false;
	end,

	--Timer是否在工作.
	IsTimerSet = function(slef)
		return self.bEnabled;
	end,

	--禁止该Timer.
	CancelTimer = function(self)
		self.bEnabled = false;
		self.iTimeCur = 0;
	end,

	--把周期延长一定时间, 毫秒.
	Postpond = function(self, dt)
		self.iTimeLength = self.iTimeLength + dt;
	end,

	--前进一定时间, 毫秒.
	Advance = function(self, dt)
		self.iTimeCur = self.iTimeCur + dt;
	end,

	--获取剩余时间, 毫秒.
	GetLeftTime = function(self)
		if not self.bEnabled then
			return 0;
		else
			return (self.iTimeLength - self.iTimeCur);
		end
	end,

	--获取时间周期, 毫秒.
	GetCycleTime = function(self)
		return self.iTimeLength;
	end,

	new = function(self, o)
		o = o or {}
		self.__index = self
		setmetatable(o, self)
		return o
	end
}

----------------------------------------------------------
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

function EvolventScan(gs)
	local sz = gs:GetSize()
	local theata = 0
	local radius = 50
	local lineSegementLen = 5
	local prevX = sz.cx / 2 + 50
	local prevY = sz.cy / 2 + 0
	local stepCirle = 40

	while radius < 180 do
		local delta = lineSegementLen / radius
		theata = theata + delta
		local x = sz.cx / 2 + radius * math.cos(theata)
		local y = sz.cy / 2 + radius * math.sin(theata)
		radius = radius + stepCirle * delta / (2 * math.pi)

		local rgb = gs:GetPixel(SSize(x, y))
		if rgb.r > 128 and rgb.g < 20 and rgb.b < 10 then
			return ScanNameRect(gs, x, y)
		end

		prevX = x
		prevY = y
	end
	
	return nil
end