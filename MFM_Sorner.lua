--ライブラリの読み込み
require("Libs.PhysicsSensorLib")

--I/O定義
---Input(Number)
--[[
	----------------------------------Sonar
	01: Sonar Target 1 Azimuth
	02: Sonar Target 1 Elevation
		︙
	15: Sonar Target 8 Azimuth
	16: Sonar Target 8 Elevation
	----------------------------------Physics Sensor
	17: Position X
	18: Position Y
	19: Position Z
	20: Euler X
	21: Euler Y
	22: Euler Z
	23: Linear Velocity X(Local)
	24: Linear Velocity Y(Local)
	25: Linear Velocity Z(Local)
	26: Angular Velocity X(Global)
	27: Angular Velocity Y(Global)
	28: Angular Velocity Z(Global)
	29: Linear Velocity Abs
	30: Angular Velocity Abs
	----------------------------------Misc
	31: Sonar Ping Time
]]

---Input(Bool)
--[[
	----------------------------------Sonar
	01: Sonar Target 1 Found
		︙
	08: Sonar Target 8 Found
	----------------------------------Misc
	09: Sonar Ping Status
]]

---Output(Number)
--[[
	01: Sonar Target 1 Azimuth
		︙
	08: Sonar Target 8 Azimuth
	09: Sonar Target 1 Distance
		︙
	16: Sonar Target 8 Distance
	17: Sonar Target 1 Altitude
		︙
	24: Sonar Target 8 Altitude
]]

---Output(Bool)
--[[
	01: Sonar Target 1 Found
		︙
	08: Sonar Target 8 Found
]]

--グローバル変数の宣言
---関数

---プロパティ
EXEPTION_RANGE = property.getNumber("Sonar Exeption Range")

---インスタンス
PHS = PhysicsSensorLib:new()

---その他
TICKS_TO_METER = 1480 / 60 / 2 -- 1480m/s / 60tick/s / 2
TURN2RAD = 2 * math.pi


--メインループ
function onTick()
	--更新
	PHS:update(17)
	local pingStatus = input.getBool(9)
	local pingTime = input.getNumber(31)

	if pingStatus then
		--アクティヴモード

	else
		--パッシヴモード
		local targets={}
		for i = 1, 8 do
			local azimuth, elevation =
				input.getNumber(i * 2 - 1),
				input.getNumber(i * 2)
			
			local isFound = input.getBool(i)
		end
	end

end