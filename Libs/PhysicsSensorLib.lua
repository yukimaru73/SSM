require("LifeBoatAPI.Utils.LBCopy")
--require("Libs.LBCopy")
require("Libs.Quaternion")
require("Libs.Vector3")

---@section PhysicsSensorLib 1 PhysicsSensorLib
---@class PhysicsSensorLib
---@field GPS Vector3[X, Y, Z] in m
---@field GPS_P Vector3[X, Y, Z] in m
---@field euler Vector3[X, Y, Z] in rad
---@field velocity Vector3[X, Y, Z] in m/tick
---@field velocityGlobal Vector3[X, Y, Z] in m/tick
---@field velocityGlobalP Vector3[X, Y, Z] in m/tick
---@field accelerationGlobal Vector3[X, Y, Z] in m/tick^2
---@field angularSpeed Vector3[X, Y, Z] in rad/tick
---@field angularSpeedP Vector3[X, Y, Z] in rad/tick
---@field angularAcceleration Vector3[X, Y, Z] in rad/tick^2
---@field absVelocity number in m/tick
---@field absAngularSpeed number in rad/tick
---@field q Quaternion
PhysicsSensorLib = {
	---@param cls PhysicsSensorLib
	---@overload fun(cls:PhysicsSensorLib):PhysicsSensorLib creates a new zero-initialized PhysicsSensorLib
	---@return PhysicsSensorLib
	new = function(cls)
		return LifeBoatAPI.lb_copy(cls, {
			GPS = Vector3:new(),
			GPS_P = Vector3:new(),
			velocityGlobal = Vector3:new(),
			euler = Vector3:new(),
			velocity = Vector3:new(),
			angularSpeed = Vector3:new(),
			absVelocity = 0,
			absAngularSpeed = 0,
			q = Quaternion:_new()
		})
	end,

	---@section update
	---@param self PhysicsSensorLib
	---@param startChannel number
	---@return nil
	update = function(self, startChannel)
		for i = 1, 3 do
			self.GPS[i] = input.getNumber(startChannel + i - 1)
			self.euler[i] = input.getNumber(startChannel + i + 2)
			self.velocity[i] = input.getNumber(startChannel + i + 5) / 60
			self.angularSpeed[i] = self.angularSpeed[i] / 2 +
				(input.getNumber(startChannel + i + 8) * math.pi / 60)
		end
		--self.absVelocity = input.getNumber(startChannel + 12) / 60
		--self.absAngularSpeed = input.getNumber(startChannel + 13) * math.pi / 30
		self.q = Quaternion:newFromEuler(self.euler[1], self.euler[2], self.euler[3])

		self.velocityGlobal = self.GPS:sub(self.GPS_P)

		self.GPS_P = Vector3:new(self.GPS)
	end,
	---@endsection

	---@section getGPS
	---@param self PhysicsSensorLib
	---@param ticks number
	---@overload fun(self:PhysicsSensorLib):Vector3
	---@return Vector3
	getGPS = function(self, ticks)
		ticks = ticks or 0
		return self.GPS:add(self.velocityGlobal:mul(ticks))
	end,
	---@endsection

	---@section rotateVecL2W
	---@param self PhysicsSensorLib
	---@param vector Vector3|table {X, Y, Z}
	---@param ticks number
	---@overload fun(self:PhysicsSensorLib, vector:Vector3):Vector3
	---@return Vector3
	rotateVecL2W = function(self, vector, ticks)
		ticks = ticks or 0

		local qOmega, fq, k1, k2, k3, k4 =
			Quaternion:newFromVector3(self.angularSpeed:mul(0.25)),
			Quaternion:_new(self.q.x, self.q.y, self.q.z, self.q.w)
		for i = 1, ticks * 2 do
			k1 = qOmega:product(fq)
			k2 = qOmega:product(fq:add(k1:mul(0.5)))
			k3 = qOmega:product(fq:add(k2:mul(0.5)))
			k4 = qOmega:product(fq:add(k3))
			fq = fq:add(k1:add(k2:mul(2):add(k3:mul(2):add(k4))):mul(1 / 6)):normalize()
		end
		return fq:rotateVector(vector)
	end,
	---@endsection

	---@section rotateVecW2L
	---@param self PhysicsSensorLib
	---@param vector Vector3|table {X, Y, Z}
	---@param ticks number
	---@overload fun(self:PhysicsSensorLib, vector:Vector3):Vector3
	---@return Vector3
	rotateVecW2L = function(self, vector, ticks)
		ticks = ticks or 0

		local qOmega, fq, k1, k2, k3, k4 =
			Quaternion:newFromVector3(self.angularSpeed:mul(0.25)),
			Quaternion:_new(self.q.x, self.q.y, self.q.z, self.q.w)
		for i = 1, ticks * 2 do
			k1 = qOmega:product(fq)
			k2 = qOmega:product(fq:add(k1:mul(0.5)))
			k3 = qOmega:product(fq:add(k2:mul(0.5)))
			k4 = qOmega:product(fq:add(k3))
			fq = fq:add(k1:add(k2:mul(2):add(k3:mul(2):add(k4))):mul(1 / 6)):normalize()
		end
		return fq:getConjugateQuaternion():rotateVector(vector)
	end;
	---@endsection

	---@section rotateVector
	---@param self PhysicsSensorLib
	---@param vector Vector3|table {X, Y, Z}
	---@param direction boolean true: L2W, false: W2L
	---@param ticks number
	---@overload fun(self:PhysicsSensorLib, vector:Vector3, direction:boolean):Vector3
	---@return Vector3
	rotateVector = function(self, vector, direction, ticks)
		ticks = ticks or 0

		local qOmega, fq, k1, k2, k3, k4 =
			Quaternion:newFromVector3(self.angularSpeed:mul(0.25)),
			Quaternion:_new(self.q.x, self.q.y, self.q.z, self.q.w)
		for i = 1, ticks * 2 do
			k1 = qOmega:product(fq)
			k2 = qOmega:product(fq:add(k1:mul(0.5)))
			k3 = qOmega:product(fq:add(k2:mul(0.5)))
			k4 = qOmega:product(fq:add(k3))
			fq = fq:add(k1:add(k2:mul(2):add(k3:mul(2):add(k4))):mul(1 / 6)):normalize()
		end
		return direction and fq:rotateVector(vector) or fq:getConjugateQuaternion():rotateVector(vector)
	end;
	---@endsection


	--[[
	---@section debugUdate
	---@param self PhysicsSensorLib
	---@param euler Vector3
	---@param angularSpeed Vector3
	,debugUpdate = function(self, euler, angularSpeed)
		self.euler = euler
		self.angularSpeed = angularSpeed
		self.q = Quaternion:newFromEuler(self.euler[1], self.euler[2], self.euler[3])
	end,
	---@endsection
	]]

}
---@endsection
