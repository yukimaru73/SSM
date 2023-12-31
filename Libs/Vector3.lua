require("LifeBoatAPI.Utils.LBCopy")
--require("Libs.LBCopy")

---@section Vector3 1 Vector3  {x,y,z}
---@class Vector3
Vector3 = {

	---@param cls Vector3
	---@overload fun(cls:Vector3):Vector3 creates a new zero-initialized Vector3
	---@overload fun(cls:Vector3, table):Vector3 creates Vector3 from table
	---@return Vector3
	new = function(cls, x, y, z)
		local obj = {}
		if type(x) == "table" then
			obj = { x[1] or 0, x[2] or 0, x[3] or 0 }
		else
			obj = { x or 0, y or 0, z or 0 }
		end
		return LifeBoatAPI.lb_copy(cls, obj)
	end,

	---@section newFromPolar
	---@param cls Vector3
	---@param l number distance
	---@param azimuth number azimuth
	---@param elevation number elevation
	---@return Vector3
	newFromPolar = function(cls, l, azimuth, elevation)
		return Vector3:new(l * math.cos(elevation) * math.sin(azimuth), l * math.sin(elevation),
			l * math.cos(elevation) * math.cos(azimuth))
	end,
	---@endsection

	---@section getMagnitude
	---@param self Vector3
	---@return number
	getMagnitude = function(self)
		return math.sqrt(self[1]^2 + self[2]^2 + self[3]^2)
	end,
	---@endsection

	---@section normalize
	---@param self Vector3
	---@param mag number
	---@overload fun(self:Vector3):Vector3
	---@return Vector3
	normalize = function(self, mag)
		mag = self:getMagnitude()
		return self:new(self[1] / mag, self[2] / mag, self[3] / mag)
	end,
	---@endsection

	---@section add
	---@param v1 Vector3
	---@param v2 Vector3
	---@return Vector3
	add = function(v1, v2)
		return Vector3:new(v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3])
	end,
	---@endsection

	---@section sub
	---@param v1 Vector3
	---@param v2 Vector3
	---@return Vector3
	sub = function(v1, v2)
		return Vector3:new(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3])
	end,
	---@endsection

	---@section mul
	---@param v1 Vector3
	---@param n number
	---@return Vector3
	mul = function(v1, n)
		return Vector3:new(v1[1] * n, v1[2] * n, v1[3] * n)
	end,
	---@endsection

	---@section dot calculate dot product of two vectors
	---@param v1 Vector3
	---@param v2 Vector3
	---@return number
	dot = function(v1, v2)
		return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
	end,
	---@endsection

	---@section cross calculate cross product of two vectors
	---@param v1 Vector3
	---@param v2 Vector3
	---@return Vector3
	cross = function(v1, v2)
		return Vector3:new(
			v1[2] * v2[3] - v1[3] * v2[2],
			v1[3] * v2[1] - v1[1] * v2[3],
			v1[1] * v2[2] - v1[2] * v2[1]
		)
	end,
	---@endsection

	---@section getDistanceBetween2Vectors
	---@param v1 Vector3
	---@param v2 Vector3
	---@return number
	getDistanceBetween2Vectors = function(v1, v2)
		return v1:sub(v2):getMagnitude()
	end,
	---@endsection

	---@section getAzimuth
	---@param self Vector3
	---@return number azimuth(rad)
	getAzimuth = function(self)
		return math.atan(self[1], self[3])
	end,
	---@endsection

	---@section getElevation
	---@param self Vector3
	---@return number elevation(rad)
	getElevation = function(self)
		return math.atan(self[2], math.sqrt(self[1]^2 + self[3]^2))
	end,
	---@endsection

	---@section getAngle
	---@param self Vector3
	---@return number azimuth, number elevation
	getAngle = function(self)
		return math.atan(self[1], self[3]), math.atan(self[2], math.sqrt(self[1]^2 + self[3]^2))
	end,
	---@endsection

	---@section getHorizontalDistance
	---@param self Vector3
	---@return number
	getHorizontalDistance = function(self)
		return math.sqrt(self[1] * self[1] + self[3] * self[3])
	end,
	---@endsection

	---@section unpack
	---@param self Vector3
	---@return number X, number Y, number Z
	unpack = function(self)
		return self[1], self[2], self[3]
	end,
	---@endsection

	---@section clip
	---@param self Vector3
	---@param min number
	---@param max number
	---@return Vector3
	clip = function(self, min, max)
		return Vector3:new(
			math.max(min, math.min(max, self[1])),
			math.max(min, math.min(max, self[2])),
			math.max(min, math.min(max, self[3]))
		)
	end,
	---@endsection

	---@section abs
	---@param self Vector3
	---@return Vector3
	abs = function(self)
		return Vector3:new(math.abs(self[1]), math.abs(self[2]), math.abs(self[3]))
	end,
	---@endsection
}
---@endsection
