require("Libs.PhysicsSensorLib")

PHS = PhysicsSensorLib:new()
VEL_PRS = Vector3:new()

function onTick()
	PHS:update(1)

	local acc = PHS.velocity:sub(VEL_PRS):mul(60^2)


	debug.log("TST|| ,Acc: ," .. acc[1] .. " ," .. acc[2] .. " ," .. acc[3] .. ",")

	VEL_PRS = Vector3:new(PHS.velocity)
end