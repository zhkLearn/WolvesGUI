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

	local rcOuts = robot:IsSubSceneMatched("coc_logo_desktop_ld")
	if (rcOuts:Size() ~= 0) then
		LogInfo("Found COC icon in desktop.");
		
		local pt = rcOuts:At(1):Center();
		LogInfo(pt)
		robot:InputClick(pt.cx, (pt.cy), true);
		
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

				StateManager:ChangeState(robot, StateManager.stateMain)
				
			end
		end
	
	end

end

function StateUnknown:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
StateMain = State:new{name = "StateMain"}
function StateMain:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
end

function StateMain:OnUpdate(robot, dtTime)

end

function StateMain:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
StateNewTown = State:new{name = "StateNewTown"}
function StateNewTown:OnEnter(robot)
	LogInfo("OnEnter: " .. self.name)
end

function StateNewTown:OnUpdate(robot, dtTime)

end

function StateNewTown:OnLeave(robot)
	LogInfo("OnLeave: " .. self.name)
end

---------------------------------------------------------------------
StateManager = {}
StateManager.stateIdle = State:new()
StateManager.stateUnknown = StateUnknown:new()
StateManager.stateMain = StateMain:new()
StateManager.stateNewTown = StateNewTown:new()
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





