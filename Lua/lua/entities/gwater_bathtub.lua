AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

list.Set("gwater_entities", "gwater_bathtub", {
	Category = "Emitters",
	Name = "Bathtub",
	Material = "entities/gwater_bathtub.png"
})

ENT.Category		= "GWater"
ENT.PrintName		= "Bathtub"
ENT.Author			= "Mee & AndrewEathan (with help from PotatoOS)"
ENT.Purpose			= "Functional GWater bathtub!"
ENT.Instructions	= ""
ENT.GWaterEntity 	= true
ENT.SpawnOffset		= Vector(0, 0, 10)

function ENT:Initialize()
	self.Running = false
	if CLIENT then return end
	
	if WireLib then
		WireLib.CreateInputs(self, {"On (While this is 1, the bathtub will run)", "Toggle (When this is changed to 1, the bathtub is toggled)"})
		WireLib.CreateOutputs(self, {"Active"})
	end
	
	self.FlowSound = CreateSound(self, "ambient/water/water_flow_loop1.wav")
	self:SetModel("models/props_interiors/BathTub01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
end

function ENT:TriggerInput(name, value)
	if name == "On" then
		if value == 1 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
	if name == "Toggle" and value == 1 then
		self:Use(self)
	end
end

function ENT:TurnOn()
	if self.Running then return end
	
	self.Running = true
	self:SetNWBool("Running", true)
	self:EmitSound("buttons/lever1.wav")
	self.FlowSound:Play()
	
	if WireLib then Wire_TriggerOutput(self, "Active", 1) end
end

function ENT:TurnOff()
	if not self.Running then return end
	
	self.Running = false
	self:SetNWBool("Running", false)
	self:EmitSound("buttons/lever1.wav")
	self.FlowSound:Stop()
	
	Wire_TriggerOutput(self, "Active", 0)
end

function ENT:Use()
	if self.Running then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

function ENT:OnRemove()
	if CLIENT then return end
	
	self.FlowSound:Stop()
	self.FlowSound = nil
end

function ENT:Think()
	if SERVER then return end
	if not gwater then return end
	
	if self:GetNWBool("Running") then
		local pos = self:LocalToWorld(Vector(-30, 0, 25))
		local pos1 = self:LocalToWorld(Vector(-30, 12, 25))
		local ang = self:LocalToWorldAngles(Angle(90, 0, 0))
		local vel = self:GetVelocity()

		local drawColor = self:GetColor():ToVector()
		if drawColor == Vector(1, 1, 1) then
			drawColor = Vector(0.75, 1, 2)
		end

		gwater.SpawnParticle(pos + VectorRand(-2, 2), ang:Forward() * 15 + VectorRand(-1, 1) / 4 + vel / 6, drawColor)
		gwater.SpawnParticle(pos1 + VectorRand(-2, 2), ang:Forward() * 15 + VectorRand(-1, 1) / 4 + vel / 6, drawColor)
	end
	
	self:SetNextClientThink(CurTime() + 0.05)
end