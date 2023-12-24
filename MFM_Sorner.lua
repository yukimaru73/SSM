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
	31: Sonar Ping Time Base
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
	09: Sonar Ping Status
]]

--グローバル変数の宣言
---関数

---プロパティ
EXEPTION_RANGE = property.getNumber("Sonar Exeption Range")

---インスタンス
PHS = PhysicsSensorLib:new()

---その他
TIME_BASE = -1
TICKS2METER = 1480 / 60 / 2 -- 1480m/s / 60tick/s / 2
RAD2TURN = 1 / (2 * math.pi) -- 1 / (2π)
TURN2RAD = 2 * math.pi

TIME = TIME_BASE


--メインループ
function onTick()
	--更新
	PHS:update(17)
	local pingStatus = input.getBool(9)
	TIME_BASE = input.getNumber(31)
	TIME = pingStatus and (TIME + 1) or TIME_BASE

	if pingStatus and TIME > 0 then --アクティヴモード
		--ターゲットの取得
		---@type Vector3[]
		local targets = {}
		local targetsGlobal = {}
		for i = 1, 8 do
			local isFound = input.getBool(i)
			if not isFound then break end

			--距離、方位角、仰角の算出
			local distance, azimuth, elevation =
				TIME * TICKS2METER,
				input.getNumber(i * 2 - 1) * TURN2RAD,
				input.getNumber(i * 2) * TURN2RAD

			--指定距離以上の場合のみターゲットとして登録
			if distance > EXEPTION_RANGE then
				local target = Vector3:newFromPolar(distance, azimuth, elevation)
				targets[i] = PHS:rotateVector(target, true) --グローバル座標系(ソナー原点)のデータ
				targetsGlobal[i] = targets[i]:add(PHS:getGPS()) --GPSグローバル座標系のデータ
			end
		end

		--角度、距離、高度の算出
		local params = {}
		for i = 1, #targets do
			local azimuth, distance, altitude =
				-targets[i]:getAzimuth() * RAD2TURN, --コンパスと同じ規格の角度情報
				targets[i]:getMagnitude(), --相対距離
				targetsGlobal[i][2] --深度(Y座標)
				

			params[i] = {azimuth, distance, altitude}
		end

		--出力の設定
		for i = 1, 8 do
			local azimuth, distance, altitude = table.unpack(params[i] or {})

			output.setBool(i, azimuth ~= nil) --発見
			output.setNumber(i, not azimuth and 0 or azimuth) --コンパスと同じ規格の角度情報
			output.setNumber(i + 8, not distance and 0 or distance) --相対距離
			output.setNumber(i + 16, not altitude and 0 or altitude) --深度(Y座標)
		end

	else --パッシヴモード
		--ターゲットの取得
		---@type Vector3[]
		local targets={}
		for i = 1, 8 do
			local isFound = input.getBool(i)
			if not isFound then break end --見つからない場合は終了

			--方位角、仰角の算出
			local azimuth, elevation =
			input.getNumber(i * 2 - 1) * TURN2RAD,
			input.getNumber(i * 2) * TURN2RAD
			
			
			local target = Vector3:newFromPolar(1, azimuth, elevation) --ローカル座標の計算(仮で距離1mとして計算)
			targets[i] = PHS:rotateVector(target, true) --グローバル座標系(ソナー原点)のデータ
		end

		--角度の算出
		local targetAzimuths = {}
		for i, v in ipairs(targets) do
			local azimuth = -v:getAzimuth() * RAD2TURN --コンパスと同じ規格の角度情報

			targetAzimuths[i] = azimuth
		end

		--出力の設定
		for i = 1, 8 do
			local azimuth = targetAzimuths[i]

			output.setBool(i, azimuth ~= nil) --発見
			output.setNumber(i, not azimuth and 0 or azimuth) --コンパスと同じ規格の角度情報
		end
	end

	--定常処理
	output.setBool(9, pingStatus) --pingパススルー
end