-- StateScripts

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
StateUnknown = State:new{name = "StateUnknown"}
function StateUnknown:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
	local gs = robot:GetCurGameScene()
	if gs ~= nil then
		gs:SaveToFile("E:/enter_unknown.png")
	end
end

function StateUnknown:OnUpdate(robot, dtTime)

	local rcOuts = robot:IsSubSceneMatched("btn_to_play")
	if (rcOuts:Size() ~= 0) then
		LogInfo("In main menu");
		
		local pt = rcOuts:At(1):Center();
		LogInfo(tostring(pt))
		ForegroundClick(robot, pt.cx, pt.cy);
		SleepWithSnapshot(robot, 1000)

		--	A： 可以连续识别和进行按键，实现功能和B段一样
		-- 注释掉A: 打开B:
		local ret, rcOutsNewComer = IsSubSceneMatched_InTime(robot, "btn_play_newcomer", 2000)
		if (ret) then
			LogInfo("In Play menu");
			pt = rcOutsNewComer:At(1):Center();
			ForegroundClick(robot, pt.cx, pt.cy);
		end
		
		local ret, rcOutsMatchmaking = IsSubSceneMatched_InTime(robot, "cap_matchmaking", 3000)
		if (ret) then
			LogInfo("In matchmaking");
			StateManager:ChangeState(robot, StateManager.stateMatchmaking)
		end
		
		
	else
	
		--LogInfo("StateUnknown:OnUpdate()");
		
		-- B段: 也可以切换状
		-- rcOuts = robot:IsSubSceneMatched("btn_play_newcomer")
		-- if (rcOuts:Size() ~= 0) then
			-- LogInfo("In Play menu");
			-- StateManager:ChangeState(robot, StateManager.statePlay)
		-- end
		
	end

end

function StateUnknown:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
StatePlay = State:new{name = "StatePlay"}
function StatePlay:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
end

function StatePlay:OnUpdate(robot, dtTime)

	local rcOuts = robot:IsSubSceneMatched("btn_play_newcomer")
	if (rcOuts:Size() ~= 0) then

		LogInfo("In Play menu");

		local pt = rcOuts:At(1):Center();
		ForegroundClick(robot, pt.cx, pt.cy);

	else

		rcOuts = robot:IsSubSceneMatched("cap_matchmaking")
		if (rcOuts:Size() ~= 0) then
			LogInfo("In matchmaking");

			StateManager:ChangeState(robot, StateManager.stateMatchmaking)
		end

	end

end

function StatePlay:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
StateMatchmaking = State:new{name = "StateMatchmaking"}
function StateMatchmaking:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
	self.startTime = 0
end

function StateMatchmaking:OnUpdate(robot, dtTime)
	self.startTime = self.startTime + dtTime
	if self.startTime > 5000 then
		StateManager:ChangeState(robot, StateManager.stateUnknown)
	end
end

function StateMatchmaking:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
StateManager = {}
StateManager.stateIdle = State:new()
StateManager.stateUnknown = StateUnknown:new()
StateManager.statePlay = StatePlay:new()
StateManager.stateMatchmaking = StateMatchmaking:new()
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





