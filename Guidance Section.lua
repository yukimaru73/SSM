require("Libs.PhysicsSensorLib")

--I/O定義
--[[Inputs
	Ch.01~14: 	Physics Sensor入力
	Ch.15~17:	目標座標
	Ch.18~20:	目標速度
]]

--[[Outputs
	Ch.01   :	ヨー
	Ch.02   :	ピッチ
]]

--グローバル変数宣言
---変数
TORPEDO_VEL_PREV = Vector3:new(0, 0, 0)

---関数

--- PN: Proportional Navigation
---@param Pm Vector3 -- missile position
---@param Vm Vector3 -- missile velocity
---@param Pt Vector3 -- target position
---@param Vt Vector3 -- target velocity
---@param Ne number -- normal engagement factor
---@overload fun(Pm: Vector3, Vm: Vector3, Pt: Vector3, Vt: Vector3, Ne: number): Vector3
---@overload fun(Pm: Vector3, Vm: Vector3, Pt: Vector3, Vt: Vector3): Vector3
---@return Vector3, boolean -- acceleration command vector
function PN(Pm, Vm, Pt, Vt, Ne)
	-- calculate LOS vector(R) and relative velocity(Vr)
	local R, Vr = Pt:sub(Pm), Vm:sub(Vt)

	-- calculate norm of R and Vr
	local R_Norm, VR_Norm = R:getMagnitude(), Vr:getMagnitude()

	local LOS, LOSRate, N =
		Vm:cross(R):mul(1 / (R_Norm * R_Norm)),
		Vr:cross(R):mul(1 / (R_Norm * R_Norm)),
		Ne * VR_Norm / (R:dot(Vm) / R_Norm)

	-- calculate acceleration command vector(acc)[m/s^2]
	local accP, accPN = LOS:cross(Vm):mul(N), LOSRate:cross(Vm):mul(N)

	return R:dot(Vm) < 0 and accPN:mul(-0.5):sub(accP) or accPN, R:dot(Vm) < 0
end

---プロパティ
MAX_G = property.getNumber("MAX_G")
Kp = property.getNumber("Kp")
Ki = property.getNumber("Ki")
Kd = property.getNumber("Kd")
TL = property.getNumber("TL")

--インスタンス
PHS = PhysicsSensorLib:new()

---メインループ
function onTick()
	--入力
	PHS:update(1)
	local targetPos, targetVel =
		Vector3:new(input.getNumber(15), input.getNumber(16), input.getNumber(17)),
		Vector3:new(input.getNumber(18), input.getNumber(19), input.getNumber(20))


	--計算
	local accGlobal, isNegative = PN(PHS:getGPS(TL), PHS.velocityGlobal, targetPos, targetVel, 1)
	local accLocal = PHS:rotateVecL2W(accGlobal, TL)

	accLocal[3] = 0

	
	--保存
	TORPEDO_VEL_PREV = Vector3:new(PHS.velocity)
end