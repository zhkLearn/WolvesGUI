
-- StateScripts
require "TLBB.TypeDefine"

---------------------------------------------------------------------
State =
 {
	name = "StateIdle",
	OnEnter = function(self, robot)
		LogInfo("OnEnter: " .. self.name)
	end,

	OnUpdate = function(self, robot, dtTime)
	end,

	OnLeave = function(self, robot)
		LogInfo("OnLeave: " .. self.name)
	end,

	new = function(self, o)
		o = o or {}
		self.__index = self
		setmetatable(o, self)
		return o
	end
}

---------------------------------------------------------------------
stateUnknown = State:new{name = "stateUnknown"}
function stateUnknown:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
	--local gs = robot:GetCurGameScene()
	--if gs ~= nil then
		--gs:SaveToFile("E:/enter_unknown.png")
	--end
end

function stateUnknown:OnUpdate(robot, dtTime)

	local st = Wolves.SharedManager.FetchCurThreadMessage()
	if st ~= nil and st.type == "Start" then
		LogInfo("Received Start msg...")

		local needHook = false
		if not g_mainGameWnd:IsValid() then
			g_mainGameWnd:FromHandle(g_theSharedTable.gameWndHandle)
			needHook = true
		elseif g_mainGameWnd:GetHandle() ~= g_theSharedTable.gameWndHandle then	--游戏窗口变了
			robot:StopHookWindow();
			Wolves.Sleep(3000)
			g_mainGameWnd:FromHandle(g_theSharedTable.gameWndHandle)
			needHook = true
		end

		if g_mainGameWnd:IsValid() then
			
			if needHook then
				-- Params: window, simple(false: hook 3d), flipY
				if not robot:HookWindow(g_mainGameWnd, false, true) then
					LogError("robot:HookWindow failed!")
					return
				end
				LogInfo("robot:HookWindow() OK")
			end
			
			if g_theSharedTable.subModule == EnumSubModule.eCombat then
				StateManager:ChangeState(robot, StateManager.stateCombat)
			elseif g_theSharedTable.subModule == EnumSubModule.ePlant then
				StateManager:ChangeState(robot, StateManager.statePlant)
			end
		end

	end
	

--[[
	local rcOuts = robot:IsSubSceneMatched("coc_logo_desktop_ld")
	if (rcOuts:Size() ~= 0) then
		LogInfo("Found COC icon in desktop.");
		
		local pt = rcOuts:At(1):Center();
		--LogInfo(tostring(pt))
		robot:InputMouseClick(g_mainGameWnd, 0, pt.cx, pt.cy);
		
	else

		rcOuts = robot:IsSubSceneMatched("WorkerIcon_NewTown")
		if (rcOuts:Size() ~= 0) then

			LogInfo("In new town.");

			StateManager:ChangeState(robot, StateManager.stateNewTown)
		
		else
		
			rcOuts = robot:IsSubSceneMatched("start_match")
			if rcOuts:Size() == 0 then
				rcOuts = robot:IsSubSceneMatched("start_match_stars")
			end
			
			if (rcOuts:Size() ~= 0) then

				LogInfo("In game main.");

				StateManager:ChangeState(robot, StateManager.statePlant)
				
			end
		end
	
	end
--]]

end

function stateUnknown:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
stateCombat = State:new{name = "stateCombat"}
function stateCombat:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
	local gs = robot:GetCurGameScene()
	if gs ~= nil then
		gs:SaveToFile("E:/enter_combat1.png")
	end
	
	self.timerForegroundWindowCheck = SimpleTimer:new()
	self.timerForegroundWindowCheck:SetTimer(30000, true, true)

	self.timerTargetSkills = SimpleTimer:new()
	self.timerTargetSkills:SetTimer(1000, true, true)

	self.timerPlayerAndPet = SimpleTimer:new()
	self.timerPlayerAndPet:SetTimer(2000, true, true)

	self.reTargetCur = 0
	self.monsterBloodRatioOld = -1
	self.monsterBloodSameTimes = 0
end

function stateCombat:OnUpdate(robot, dtTime)

	local playerBloodGaugeBar = GaugeBar:new{
		name = "playerBloodGaugeBar", 
		ptTopLeft = SSize(67, 36),
		ptBottomRight = SSize(206, 36),
		expectRGB = SRGB(217, 10, 0),
		toleranceRGB = SRGB(10, 5, 1),
	}

	local playerQiGaugeBar = GaugeBar:new{
		name = "playerQiGaugeBar", 
		ptTopLeft = SSize(67, 44),
		ptBottomRight = SSize(206, 44),
		expectRGB = SRGB(1, 24, 217),
		toleranceRGB = SRGB(3, 5, 5),
	}

	local petGaugeBar = GaugeBar:new{
		name = "petGaugeBar", 
		ptTopLeft = SSize(137, 84),
		ptBottomRight = SSize(231, 84),
		expectRGB = SRGB(217, 10, 0),
		toleranceRGB = SRGB(10, 5, 1),
	}

	local monsterGaugeBar = GaugeBar:new{
		name = "monsterGaugeBar", 
		ptTopLeft = SSize(320, 36),
		ptBottomRight = SSize(494, 36),
		expectRGB = SRGB(217, 10, 0),
		toleranceRGB = SRGB(10, 5, 1),
		mightThreeLines = true,
	}

	local gs = robot:GetCurGameScene()
	if gs == nil then
		LogError("gs == nil")
		return
	end
	
	-- TLBB窗口要在前台才能工作
	if self.timerForegroundWindowCheck:OnTimer(dtTime) then
		local foregroundWnd = Window.s_GetForegroundWindow()
		if foregroundWnd:GetHandle() ~= g_mainGameWnd:GetHandle() then
			g_mainGameWnd:SetForegroundWindow()
			LogInfo("将游戏窗口置前台")
		end
	end
	
	if self.timerPlayerAndPet:OnTimer(dtTime) then
		if g_theSharedTable.combat.lowHealthEnabled then
			local ratioPlayerBlood = playerBloodGaugeBar:GetRatio(robot)
			if ratioPlayerBlood < TableBloodRatio[g_theSharedTable.combat.lowHealth] then
				LogDebug("玩家血量少，按 " .. TableKeysCap[g_theSharedTable.combat.keyHealth])
				ForegroundPressKey(robot, TableKeysValue[g_theSharedTable.combat.keyHealth])
			end
		end
		
		if g_theSharedTable.combat.lowQiEnabled then
			local ratioPlayerQi = playerQiGaugeBar:GetRatio(robot)
			if ratioPlayerQi < TableBloodRatio[g_theSharedTable.combat.lowQi] then
				LogDebug("玩家蓝少，按 " .. TableKeysCap[g_theSharedTable.combat.keyQi])
				ForegroundPressKey(robot, TableKeysValue[g_theSharedTable.combat.keyQi])
			end
		end

		if g_theSharedTable.combat.lowBBEnabled then
			local ratioPet = petGaugeBar:GetRatio(robot)
			if ratioPet < TableBloodRatio[g_theSharedTable.combat.lowBB] then
				LogDebug("宠物血少，按 " .. TableKeysCap[g_theSharedTable.combat.keyBB])
				ForegroundPressKey(robot, TableKeysValue[g_theSharedTable.combat.keyBB])
			end
		end
	end

	
	if self.timerTargetSkills:OnTimer(dtTime) then
		if g_theSharedTable.combat.targetEnabled then
			local reTarget = false
			if g_theSharedTable.combat.modeTarget == EnumTargetMode.eFocusCurrent then
				local ratioMonster = monsterGaugeBar:GetRatio(robot)
				if self.monsterBloodRatioOld == -1 then
					self.monsterBloodRatioOld = ratioMonster
				elseif self.monsterBloodRatioOld == ratioMonster then
					self.monsterBloodSameTimes = self.monsterBloodSameTimes + 1
				end

				reTarget = (ratioMonster == 0 or self.monsterBloodSameTimes >= 5)
				--LogDebug("怪物血量: " .. tostring(ratioMonster))
			else
				self.reTargetCur = self.reTargetCur + 1
				if self.reTargetCur >= g_theSharedTable.combat.freqTarget then
					self.reTargetCur = 0
					reTarget = true
				end
			end
			
			if reTarget then
				self.monsterBloodRatioOld = -1
				self.monsterBloodSameTimes = 0
				
				--LogDebug("找怪，按 " .. TableKeysCap[g_theSharedTable.combat.keyTarget])
				--ForegroundPressKey(robot, TableKeysValue[g_theSharedTable.combat.keyTarget])

--[[
--TLBB必须前台按键，纯挂机可以打开，否则会严重干扰鼠标
				if g_theSharedTable.combat.modeTarget == EnumTargetMode.eFocusCurrent then
					local aroundMonsterRect = EvolventScan(gs)
					if aroundMonsterRect ~= nil then
						local pt = aroundMonsterRect:Center()
						--robot:InputMouseClick(g_mainGameWnd, 0, pt.cx, pt.cy + 45)
						ForegroundClick(robot, pt.cx, pt.cy + 45)
						LogDebug("红名找怪")
						reTarget = false
					end
				end
--]]
				
				if reTarget then
					LogDebug("按键找怪")
					-- Ctrl + Tab
					robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 162, false, true, false)
					Wolves.Sleep(15)
					robot:InputKeyEvent(g_mainGameWnd, 9, true)
					--Wolves.Sleep(2)
					robot:InputKeyEvent(g_mainGameWnd, 9, false)
					Wolves.Sleep(10)
					robot:InputForegroundKeyEvent(g_mainGameWnd, g_InputUseDriver, 162, false, false, false)
				end
			end
		end
		
		
		for k = 1, #g_theSharedTable.combat.keys do
			local item = g_theSharedTable.combat.keys[k]
			if item.checked then
				item.cur = item.cur + 1
				if item.cur >= item.freq then
					item.cur = 0
					LogDebug("按 " .. TableKeysCap[k])
					ForegroundPressKey(robot, TableKeysValue[k])
				end
			end
		end
	end
	
end

function stateCombat:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
statePlant = State:new{name = "statePlant"}
function statePlant:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
end

function statePlant:OnUpdate(robot, dtTime)

end

function statePlant:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
StateManager = {}
StateManager.stateIdle = State:new()
StateManager.stateUnknown = stateUnknown:new()
StateManager.stateCombat = stateCombat:new()
StateManager.statePlant = statePlant:new()
StateManager.curState = StateManager.stateIdle

function StateManager:ChangeState(robot, s)
	if s == nil then
		LogError("ChangeState, cannot change to nil state!")
		return
	end

	if s == self.curState then
		LogError("ChangeState, cannot change to same state!")
		return
	end

	if self.curState ~= nil then
		self.curState:OnLeave(robot)
	end
		
	self.curState = nil
	self.nextState = s
end
	
function StateManager:Update(robot, dtTime)

	if self.nextState ~= nil then
		self.curState = self.nextState
		self.nextState = nil
		self.curState:OnEnter(robot)	-- 避免第一次OnUpdate的dtTime过大
    elseif self.curState ~= nil then
		self.curState:OnUpdate(robot, dtTime)
	end
	
end





