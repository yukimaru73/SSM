---@section PWM 1 PWM
---@class PWM
---@field maxValue number
---@field period number
---@field counter number
PWM = {
	---@param cls PWM
	---@param maxValue number
	---@param period number
	---@return PWM
	new = function (cls, maxValue, period)
		return LifeBoatAPI.lb_copy(cls, { maxValue = maxValue, period = period, counter = 0})
	end;

	---@section update
	---@param self PWM
	---@param inputValue number
	---@return boolean Positive, boolean Negative
	update = function (self, inputValue)
		self.counter = (self.counter + 1) % self.period

		local sign, abs = inputValue > 0, math.abs(inputValue / self.maxValue)
		
		return sign and self.counter <= self.period * abs, not sign and self.counter <= self.period * abs
	end;
	---@endsection
}
---@section PWM 1 PWM