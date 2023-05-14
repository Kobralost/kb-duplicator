AddCSLuaFile()
TOOL.Category = "Construction"
TOOL.Name = "KB Duplicator"
TOOL.Author = "Kobralost"
KBDuplicator = KBDuplicator or {}

if game.SinglePlayer() then
	for i=1, 5 do
		print("[KBDuplicator] - You are on singleplayer KBDuplicator is disable and cannot work please lunch a pear to pear server")
	end
end

local function checkIfOwner(ent, ply)
	if ply:IsSuperAdmin() then return true end
	
	if isfunction(ent.CPPIGetOwner) then
		if ent:CPPIGetOwner() == ply or (ent:GetOwner() == ply) then return true end
	else
		if ent:GetOwner() == ply then return true end
	end
end

local function getTrace(ply, posAdd2)
	local trace = util.TraceLine( {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * posAdd2,
		filter = function(ent) if ent:GetClass() == "prop_physics" then return true end end
	})

	return trace
end

local function getSentence(key)
	local lang = GetConVar("gmod_language"):GetString()

	KBDuplicator.Language = KBDuplicator.Language or {}
	KBDuplicator.Language[lang] = KBDuplicator.Language[lang] or {}

	local langToReturn = KBDuplicator.Language[lang][key] or (KBDuplicator.Language["en"][key] and KBDuplicator.Language["en"][key] or "Bad sentence")

	return langToReturn
end

KBDuplicator.BlackListClass = {
	["viewmodel"] = true,
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["keypad"] = true,
}

KBDuplicator.ClassToType = {
	["gmod_balloon"] = "balloons",
	["gmod_button"] = "buttons",
	["gmod_cameraprop"] = "cameras",
	["gmod_dynamite"] = "dynamite",
	["gmod_emitter"] = "emitters",
	["gmod_hoverball"] = "hoverballs",
	["gmod_lamp"] = "lamps",
	["gmod_light"] = "lights",
	["prop_physics"] = "props",
	["prop_ragdoll"] = "ragdolls",
	["gmod_thruster"] = "thrusters",
	["gmod_wheel"] = "wheels",
}

KBDuplicator.Constants = {
	["green"] = Color(46, 204, 113),
	["white"] = Color(240, 240, 240),
	["white2"] = Color(236, 240, 241),
	["white5"] = Color(248, 247, 252, 5),
	["black"] = Color(0, 0, 0, 255),
	["purple"] = Color(81, 56, 237),
	["grey"] = Color(150, 150, 150),
	["white100"] = Color(248, 247, 252, 100),
	["purple120"] = Color(81, 56, 237, 100),
	["purple255"] = Color(81, 56, 237, 255),
	["grey30"] = Color(150, 150, 150, 30),
	["red"] = Color(238, 82, 83),
	["toolgun"] = Material("kb_tools/duplicatorToolBackground.png", "$ignorez"),
	["background"] = Material("kb_tools/toolBackground.png", "smooth"),
	["checkedBox"] = Material("kb_tools/checkedBox.png", "smooth"),
	["uncheckedBox"] = Material("kb_tools/uncheckedBox.png", "smooth"),
	["angle0"] = Angle(0, 0, 0),
	["vector0"] = Vector(0, 0, 0),
}

KBDuplicator.TypeNet = KBDuplicator.TypeNet or {
    ["Player"] = "Entity",
    ["Vector"] = "Vector",
    ["Angle"] = "Angle",
    ["Entity"] = "Entity",
    ["number"] = "Float",
    ["string"] = "String",
    ["table"] = "Table",
    ["boolean"] = "Bool",
}

KBDuplicator.PropertiesEnt = {
	["gmod_balloon"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["ropelength"] = tbl.ropelength,
				["force"] = tbl.force,
				["r"] = tbl.r,
				["g"] = tbl.g,
				["b"] = tbl.b,
				["model"] = tbl.model,
			}

			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local balloonTable = tbl[1] or {}

			return MakeBalloon(ply, balloonTable.r, balloonTable.g, balloonTable.b, balloonTable.force)
		end,
	},
	["gmod_thruster"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			
			local tableToSend = {
				["model"] = ent:GetModel(),
				["key"] = tbl.key,
				["key_bck"] = tbl.key_bck,
				["force"] = tbl.force,
				["toggle"] = tbl.toggle,
				["effect"] = tbl.effect,
				["damageable"] = tbl.damageable,
				["soundname"] = tbl.soundname,
				["nocollide"] = tbl.nocollide,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local thrusterTable = tbl[1] or {}

			return MakeThruster(ply, thrusterTable.model, KBDuplicator.Constants["angle0"], KBDuplicator.Constants["vector0"], thrusterTable.key, thrusterTable.key_bck, thrusterTable.force, thrusterTable.toggle, thrusterTable.effect, thrusterTable.damageable, thrusterTable.soundname, thrusterTable.nocollide)
		end,
	},
	["gmod_button"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["model"] = ent:GetModel(),
				["key"] = tbl.key,
				["description"] = tbl.description,
				["toggle"] = tbl.toggle,
				["nocollide"] = tbl.nocollide,
			}

			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local buttonTable = tbl[1] or {}

			return MakeButton(ply, buttonTable.model, KBDuplicator.Constants["angle0"], KBDuplicator.Constants["vector0"], buttonTable.key, buttonTable.description, buttonTable.toggle, buttonTable.nocollide)
		end,
	},
	["gmod_wheel"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["model"] = ent:GetModel(),
				["key_f"] = tbl.key_f,
				["key_r"] = tbl.key_r,
				["axis"] = tbl.axis,
				["direction"] = tbl.direction,
				["toggle"] = tbl.toggle,
				["BaseTorque"] = tbl.BaseTorque,
			}

			
			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local wheelTable = tbl[1] or {}

			return MakeWheel(ply, KBDuplicator.Constants["vector0"], KBDuplicator.Constants["angle0"], wheelTable.model, wheelTable.key_f, wheelTable.key_r, wheelTable.axis, wheelTable.direction, wheelTable.toggle, wheelTable.BaseTorque)
		end,
	},
	["gmod_lamp"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["model"] = ent:GetModel(),
				["r"] = tbl.r,
				["g"] = tbl.g,
				["b"] = tbl.b,
				["KeyDown"] = tbl.KeyDown,
				["toggle"] = tbl.toggle,
				["Texture"] = tbl.Texture,
				["fov"] = tbl.fov,
				["distance"] = tbl.distance,
				["brightness"] = tbl.brightness,
				["on"] = tbl.on,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local lampTable = tbl[1] or {}

			return MakeLamp(ply, lampTable.r, lampTable.g, lampTable.b, lampTable.KeyDown, lampTable.toggle, lampTable.Texture, lampTable.model, lampTable.fov, lampTable.distance, lampTable.brightness, lampTable.on)
		end,
	},
	["gmod_light"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["model"] = ent:GetModel(),
				["lightr"] = tbl.lightr,
				["lightg"] = tbl.lightg,
				["lightb"] = tbl.lightb,
				["Brightness"] = tbl.Brightness,
				["Size"] = tbl.Size,
				["on"] = tbl.on,
				["KeyDown"] = tbl.KeyDown,
				["toggle"] = tbl.toggle,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local lightTable = tbl[1] or {}

			return MakeLight(ply, lightTable.lightr, lightTable.lightg, lightTable.lightb, lightTable.Brightness, lightTable.Size, lightTable.toggle, lightTable.on, lightTable.KeyDown)
		end,
	},
	["gmod_dynamite"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["model"] = ent:GetModel(),
				["key"] = tbl.key,
				["damage"] = tbl.Damage,
				["remove"] = tbl.remove,
				["delay"] = tbl.delay,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local dynamiteTable = tbl[1] or {}

			return MakeDynamite(ply, KBDuplicator.Constants["vector0"], KBDuplicator.Constants["angle0"], dynamiteTable.key, dynamiteTable.damage, dynamiteTable.model, dynamiteTable.remove, dynamiteTable.delay)
		end,
	},
	["gmod_emitter"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["model"] = ent:GetModel(),
				["key"] = tbl.key,
				["damage"] = tbl.Damage,
				["remove"] = tbl.remove,
				["delay"] = tbl.delay,
				["toggle"] = tbl.toggle,
				["nocollide"] = tbl.nocollide,
				["effect"] = tbl.effect,
				["scale"] = tbl.scale,
				["starton"] = tbl.starton,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local emitterTable = tbl[1] or {}

			return MakeEmitter(ply, emitterTable.key, emitterTable.delay, emitterTable.toggle, emitterTable.effect, emitterTable.starton, emitterTable.nocollide, emitterTable.scale)
		end,
	},
	["gmod_cameraprop"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local tableToSend = {
				["model"] = ent:GetModel(),
				["toggle"] = tbl.toggle,
				["key"] = tbl.controlkey,
				["locked"] = tbl.locked,
			}
				
			return tableToSend
		end,
		["load"] = function(tbl, ply)
			local cameraTable = tbl[1] or {}
			local ent = ents.Create("gmod_cameraprop")

			if cameraTable.key then
				for id, camera in pairs(ents.FindByClass("gmod_cameraprop")) do
					if not camera.controlkey && camera.controlkey != cameraTable.key then continue end
					if IsValid(ply) && IsValid(camera:GetPlayer()) && ply != camera:GetPlayer() then continue end

					camera:Remove()
				end
		
				ent:SetKey(cameraTable.key)
				ent.controlkey = cameraTable.key
			end
		
			ent:SetPlayer(ply)
		
			ent.toggle = cameraTable.toggle
			ent.locked = cameraTable.locked
		
			ent:Spawn()
		
			DoPropSpawnedEffect(ent)
		
			ent:SetTracking(NULL, Vector(0))
			ent:SetLocked(cameraTable.locked)
		
			if cameraTable.toggle == 1 then
				numpad.OnDown(ply, cameraTable.key, "Camera_Toggle", ent)
			else
				numpad.OnDown(ply, cameraTable.key, "Camera_On", ent)
				numpad.OnUp(ply, cameraTable.key, "Camera_Off", ent)
			end
			
			return ent
		end,
	},
}

KBDuplicator.OtherProperties = {
	["PhysicMaterial"] = {
		["accepted"] = true,
		["save"] = function(entTable, ent)
			local phys = ""
			if IsValid(ent) then
				phys = ent:GetPhysicsObject()
			end
	
			local tableToSend = {
				["physMaterial"] = (IsValid(phys) and phys:GetMaterial() or nil),
			}
	
			return tableToSend
		end,
		["load"] = function(tbl, ent, ply)
			if not checkIfOwner(ent, ply) then return end

			if IsValid(ent) then
				local phys = ent:GetPhysicsObject()
	
				phys:SetMaterial(tbl["physMaterial"])
			end
		end,
	},
	["Parent"] = {
		["accepted"] = true,
		["save"] = function(entTable, ent)
			local parentedEntity = ent:GetParent()

			local tableToSend = {
				["parentEntity"] = (IsValid(parentedEntity) and ent:GetParent():EntIndex() or nil),
			}
	
			return tableToSend
		end,
		["load"] = function(tbl, ent, ply)
			if not checkIfOwner(ent, ply) then return end

			if IsValid(ent) then
				if IsValid(tbl["parentEntity"]) then
					ent:SetMaterial(tbl["parentEntity"])
				end
			end
		end,
	},
	["Trails"] = {
		["accepted"] = true,
		["save"] = function(tbl, ent)
			local entTable = tbl["EntityMods"] or {}
			local trailsTable = entTable["trail"] or {}

			local tableToSend = {
				["Length"] = trailsTable.Length,
				["EndSize"] = trailsTable.EndSize,
				["Material"] = trailsTable.Material,
				["Color"] = trailsTable.Color,
				["StartSize"] = trailsTable.StartSize,
			}
	
			return tableToSend
		end,
		["load"] = function(tbl, ent, ply)
			if not checkIfOwner(ent, ply) then return end

			if IsValid(ent.SToolTrail) then
				ent.SToolTrail:Remove()
				ent.SToolTrail = nil
			end
		
			if not tbl then
				duplicator.ClearEntityModifier(ent, "trail")
				return
			end
		
			if tbl.StartSize <= 0 && tbl.EndSize <= 0 then return end
			
			if not game.SinglePlayer() then				
				tbl.Length = math.Clamp(tbl.Length, 0.1, 10)
				tbl.EndSize = math.Clamp(tbl.EndSize, 0, 128)
				tbl.StartSize = math.Clamp(tbl.StartSize, 0, 128)
			end
		
			tbl.StartSize = math.max(0.0001, tbl.StartSize)
	
			local trail_entity = util.SpriteTrail(ent, 0, tbl.Color, false, tbl.StartSize, tbl.EndSize, tbl.Length, 1 / ((tbl.StartSize + tbl.EndSize) * 0.5), tbl.Material .. ".vmt")
			ent.SToolTrail = trail_entity
		
			if IsValid(ply) then
				ply:AddCleanup("trails", trail_entity)
			end
		
			duplicator.StoreEntityModifier(ent, "trail", tbl)
		end,
	},
}

KBDuplicator.Constraints = {
	["Weld"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["forcelimit"] = tbl.forcelimit,
				["nocollide"] = tbl.nocollide,
				["deleteent1onbreak"] = tbl.deleteent1onbreak,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Weld(ent1, ent2, tbl.bone1, tbl.bone2, tbl.forcelimit, tbl.nocollide, tbl.deleteent1onbreak)
		end,
	},
	["NoCollide"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.NoCollide(ent1, ent2, tbl.bone1, tbl.bone2)
		end,
	},
	["Rope"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["lpos1"] = tbl.LPos1,
				["lpos2"] = tbl.LPos2,
				["lenght"] = tbl.length,
				["addlength"] = tbl.addlength,
				["forcelimit"] = tbl.forcelimit,
				["width"] = tbl.width,
				["material"] = tbl.material,
				["rigid"] = tbl.rigid,
				["color"] = tbl.color,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Rope(ent1, ent2, tbl.bone1, tbl.bone2, tbl.lpos1, tbl.lpos2, tbl.lenght, tbl.addlength, tbl.forcelimit, tbl.width, tbl.material, tbl.rigid, tbl.color)
		end,
	},
	["Elastic"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["lpos1"] = tbl.LPos1,
				["lpos2"] = tbl.LPos2,
				["constant"] = tbl.constant,
				["damping"] = tbl.damping,
				["rdamping"] = tbl.rdamping,
				["material"] = tbl.material,
				["width"] = tbl.width,
				["stretchonly"] = tbl.stretchonly,
				["color"] = tbl.color,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Elastic(ent1, ent2, tbl.bone1, tbl.bone2, tbl.lpos1, tbl.lpos2, tbl.constant, tbl.damping, tbl.rdamping, tbl.material, tbl.width, tbl.stretchonly, tbl.color)
		end,
	},
	["Slider"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["lpos1"] = tbl.LPos1,
				["lpos2"] = tbl.LPos2,
				["width"] = tbl.width,
				["material"] = tbl.material,
				["color"] = tbl.color,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Slider(ent1, ent2, tbl.bone1, tbl.bone2, tbl.lpos1, tbl.lpos2, tbl.width, tbl.material, tbl.color)
		end,
	},
	["Axis"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["lpos1"] = tbl.LPos1,
				["lpos2"] = tbl.LPos2,
				["forcelimit"] = tbl.forcelimit,
				["torquelimit"] = tbl.torquelimit,
				["friction"] = tbl.friction,
				["nocollide"] = tbl.nocollide,
				["LocalAxis"] = tbl.LocalAxis,
				["DontAddTable"] = tbl.DontAddTable,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Axis(ent1, ent2, tbl.bone1, tbl.bone2, tbl.lpos1, tbl.lpos2, tbl.forcelimit, tbl.torquelimit, tbl.friction, tbl.nocollide, tbl.LocalAxis, tbl.DontAddTable)
		end,
	},
	["AdvBallsocket"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["lpos1"] = tbl.LPos1,
				["lpos2"] = tbl.LPos2,
				["forcelimit"] = tbl.forcelimit,
				["torquelimit"] = tbl.torquelimit,
				["xmin"] = tbl.xmin,
				["ymin"] = tbl.ymin,
				["zmin"] = tbl.zmin,
				["xmax"] = tbl.xmax,
				["ymax"] = tbl.ymax,
				["zmax"] = tbl.zmax,
				["xfric"] = tbl.xfric,
				["yfric"] = tbl.yfric,
				["zfric"] = tbl.zfric,
				["onlyrotation"] = tbl.onlyrotation,
				["nocollide"] = tbl.nocollide,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Axis(ent1, ent2, (tbl.bone1 or 0), (tbl.bone2 or 0), tbl.lpos1, tbl.lpos2, tbl.forcelimit, tbl.torquelimit, tbl.xmin, tbl.ymin, tbl.zmin, tbl.xmax, tbl.ymax, tbl.zmax, tbl.xfric, tbl.yfric, tbl.zfric, tbl.onlyrotation, tbl.nocollide)
		end,
	},
	["Motor"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["lpos1"] = tbl.LPos1,
				["lpos2"] = tbl.LPos2,
				["friction"] = tbl.friction,
				["torque"] = tbl.torque,
				["forcetime"] = tbl.forcetime,
				["nocollide"] = tbl.nocollide,
				["toggle"] = tbl.toggle,
				["ply"] = tbl.ply,
				["forcelimit"] = tbl.forcelimit,
				["numpadkey_fwd"] = tbl.numpadkey_fwd,
				["numpadkey_bwd"] = tbl.numpadkey_bwd,
				["direction"] = tbl.direction,
				["LocalAxis"] = tbl.LocalAxis,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Motor(ent1, ent2, tbl.bone1, tbl.bone2, tbl.lpos1, tbl.lpos2, tbl.friction, tbl.torque, tbl.forcetime, tbl.nocollide, tbl.toggle, tbl.ply, tbl.forcelimit, tbl.numpadkey_fwd, tbl.numpadkey_bwd, tbl.direction, tbl.LocalAxis)
		end,
	},
	["Pulley"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent4"] = (IsValid(tbl.Ent4) and tbl.Ent4:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone4"] = tbl.Bone4,
				["lpos1"] = tbl.LPos1,
				["lpos2"] = tbl.LPos4,
				["WPos2"] = tbl.WPos2,
				["WPos3"] = tbl.WPos3,
				["forcelimit"] = tbl.forcelimit,
				["rigid"] = tbl.rigid,
				["width"] = tbl.width,
				["material"] = tbl.material,
				["color"] = tbl.color,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent4 = tblOldEntIndex[tbl.ent4]

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent4, ply) then return end

			constraint.Pulley(ent1, ent4, tbl.bone1, tbl.bone4, tbl.lpos1, tbl.lpos2, tbl.WPos2, tbl.WPos3, tbl.forcelimit, tbl.rigid, tbl.width, tbl.material, tbl.color)
		end,
	},
	["Ballsocket"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["LocalPos"] = tbl.LPos,
				["forcelimit"] = tbl.forcelimit,
				["torquelimit"] = tbl.torquelimit,
				["nocollide"] = tbl.nocollide,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end

			constraint.Ballsocket(ent1, ent2, tbl.bone1, tbl.bone2, tbl.LocalPos, tbl.forcelimit, tbl.torquelimit, tbl.nocollide)
		end,
	},
	["Winch"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ply"] = tbl.ply,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["LPos1"] = tbl.LPos1,
				["LPos2"] = tbl.LPos2,
				["width"] = tbl.width,
				["fwd_bind"] = tbl.fwd_bind,
				["bwd_bind"] = tbl.bwd_bind,
				["fwd_speed"] = tbl.fwd_speed,
				["bwd_speed"] = tbl.bwd_speed,
				["material"] = tbl.material,
				["toggle"] = tbl.toggle,
				["color"] = tbl.color,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end
			
			constraint.Winch(tbl.ply, ent1, ent2, tbl.bone1, tbl.bone2, tbl.LPos1, tbl.LPos2, tbl.width, tbl.fwd_bind, tbl.bwd_bind, tbl.fwd_speed, tbl.bwd_speed, tbl.material, tbl.toggle, tbl.color)
		end,
	},
	["Hydraulic"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ply"] = tbl.ply,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["LPos1"] = tbl.LPos1,
				["LPos2"] = tbl.LPos2,
				["Length1"] = tbl.Length1,
				["Length2"] = tbl.Length2,
				["width"] = tbl.width,
				["key"] = tbl.key,
				["fixed"] = tbl.fixed,
				["speed"] = tbl.bwd_speed,
				["material"] = tbl.material,
				["color"] = tbl.color,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end
			if not isnumber(tbl.speed) then tbl.speed = 0 end
			
			constraint.Hydraulic(tbl.ply, ent1, ent2, tbl.bone1, tbl.bone2, tbl.LPos1, tbl.LPos2, tbl.Length1, tbl.Length2, tbl.width, tbl.key, tbl.fixed, tbl.speed, tbl.material, tbl.color)
		end,
	},
	["Muscle"] = {
		["accepted"] = true,
		["save"] = function(tbl)
			local tableToSend = {
				["type"] = tbl.Type,
				["ply"] = tbl.ply,
				["ent1"] = (IsValid(tbl.Ent1) and tbl.Ent1:EntIndex() or nil),
				["ent2"] = (IsValid(tbl.Ent2) and tbl.Ent2:EntIndex() or nil),
				["bone1"] = tbl.Bone1,
				["bone2"] = tbl.Bone2,
				["LPos1"] = tbl.LPos1,
				["LPos2"] = tbl.LPos2,
				["Length1"] = tbl.Length1,
				["Length2"] = tbl.Length2,
				["width"] = tbl.width,
				["key"] = tbl.key,
				["fixed"] = tbl.fixed,
				["period"] = tbl.period,
				["amplitude"] = tbl.amplitude,
				["starton"] = tbl.starton,
				["material"] = tbl.material,
				["color"] = tbl.color,
			}
			
			return tableToSend
		end,
		["load"] = function(tbl, tblOldEntIndex, ent, ply)
			local ent1 = tblOldEntIndex[tbl.ent1] or Entity(0)
			local ent2 = tblOldEntIndex[tbl.ent2] or Entity(0)

			if not checkIfOwner(ent1, ply) or not checkIfOwner(ent2, ply) then return end
			
			constraint.Muscle(tbl.ply, ent1, ent2, tbl.bone1, tbl.bone2, tbl.LPos1, tbl.LPos2, tbl.Length1, tbl.Length2, tbl.width, tbl.key, tbl.fixed, tbl.period, tbl.amplitude, tbl.starton, tbl.material, tbl.color)
		end,
	},
}

KBDuplicator.Language = {
	["en"] = {
		["toolName"] = "KB Duplicator",
		["toolDesc"] = "Save your duplications with style",
		["toolLeft"] = "Left-click to create selection or spawn your duplication",
		["toolRight"] = "Right-click to remove the current selection or your duplication",
		["toolReload"] = "Reload to rotate the current duplication",
		["takeYourTool"] = "Take your tool to spawn your duplication",
		["uniqueName"] = "You need to enter a unique name to save your duplication",
		["selectZone"] = "You need to select the zone to save your duplication",
		["successPast"] = "You successfully paste your duplication",
		["tooFar"] = "You are too far from the point to spawn your duplication",
		["noConstructions"] = "You don't have any duplications \n create the first one with the tool",
		["saveConstruction"] = "Save the duplication",
		["pasteAtOriginal"] = "Paste at the original position",
		["constructionText"] = "Duplication #%s",
		["constructionDesc"] = "Date : %s, Props : %s",
		["pos"] = "Pos %s",
		["noProps"] = "There is no props to save",
		["problemSpawn"] = "Problem with the spawn of the duplication (the error was copied to the clipboard)",
		["noSpam"] = "Please wait before use again the tool",
		["singlePlayer"] = "You are on singleplayer please lunch a pear to pear server to use the tool",
		["pos2Label"] = "Increase point 2 distance",
	},
	["fr"] = {
		["toolName"] = "KB Duplicator",
		["toolDesc"] = "Sauvegarder vos duplications avec style",
		["toolLeft"] = "Clique-Gauche pour créer une selection ou faire apparaitre votre duplication",
		["toolRight"] = "Clique-Droit pour supprimer la séléction actuelle ou votre duplication",
		["toolReload"] = "Reload pour changer la rotation de votre duplication",
		["takeYourTool"] = "Prennez votre pistolet a outil pour faire apparaitre votre duplication",
		["uniqueName"] = "Vous devez entrer un nom unique pour sauvegarder votre duplication",
		["selectZone"] = "Vous devez séléctionner la zone pour sauvegarder votre duplication",
		["successPast"] = "Vous venez de faire apparaitre votre duplication",
		["tooFar"] = "Vous êtes trop loin du point d'origine pour faire apparaitre votre duplication",
		["noConstructions"] = "Vous n'avez aucune duplications \n créer la première avec l'outil",
		["saveConstruction"] = "Sauvegarder la duplication",
		["pasteAtOriginal"] = "Placer au point d'origine",
		["constructionText"] = "Duplication #%s",
		["constructionDesc"] = "Date : %s, Props : %s",
		["pos"] = "Pos %s",
		["noProps"] = "Il n'y a aucun props à sauvegarder",
		["problemSpawn"] = "Problème lors de l'apparition de la duplication (l'erreur à été copié dans le presse papier)",
		["noSpam"] = "Veuillez attendre avant de réutiliser le tool",
		["singlePlayer"] = "Vous êtes en solo veuillez lancer en pear to pear pour utiliser l'outil",
		["pos2Label"] = "Augmenter la distance du point 2",
	},
}

if CLIENT then
	TOOL.Information = {
		{name = "left"},
		{name = "right"},
		{name = "reload"},
	}

	local function reloadToolInfo()
		language.Add("tool.kb_duplicator.name", getSentence("toolName"))
		language.Add("tool.kb_duplicator.desc", (game.SinglePlayer() and getSentence("singlePlayer") or getSentence("toolDesc")))
		
		language.Add("tool.kb_duplicator.left", (game.SinglePlayer() and getSentence("singlePlayer") or getSentence("toolLeft")))
		language.Add("tool.kb_duplicator.right", (game.SinglePlayer() and getSentence("singlePlayer") or getSentence("toolRight")))
		language.Add("tool.kb_duplicator.reload", (game.SinglePlayer() and getSentence("singlePlayer") or getSentence("toolReload")))
	end
	reloadToolInfo()

	cvars.AddChangeCallback("gmod_language", function(convar_name, value_old, value_new)
		reloadToolInfo()
	end)
	
	local function loadFonts()
		surface.CreateFont("KBDuplicator:Font:01", {
			font = "Georama Light",
			extended = false,
			size = KBDuplicator.ScrH*0.02,
			italic = false,
			weight = 0, 
			blursize = 0,
			scanlines = 0,
			antialias = true,
		})
		
		surface.CreateFont("KBDuplicator:Font:02", {
			font = "Georama",
			extended = false,
			size = KBDuplicator.ScrH*0.02,
			weight = 1000, 
			blursize = 0,
			scanlines = 0,
			antialias = true,
			italic = false
		})

		surface.CreateFont("KBDuplicator:Font:03", {
			font = "Georama Light",
			extended = false,
			size = KBDuplicator.ScrH*0.02,
			italic = false,
			weight = 0, 
			blursize = 0,
			scanlines = 0,
			antialias = true,
		})

		surface.CreateFont("KBDuplicator:Font:04", {
			font = "Georama",
			extended = false,
			size = KBDuplicator.ScrH*0.035,
			weight = 1000, 
			blursize = 0,
			scanlines = 0,
			antialias = true,
			italic = false
		})

		surface.CreateFont("KBDuplicator:Font:05", {
			font = "Georama",
			extended = false,
			size = KBDuplicator.ScrH*0.026,
			italic = false,
			weight = 0, 
			blursize = 0,
			scanlines = 0,
			antialias = true,
		})
	end

	hook.Add("HUDPaint", "KBDuplicator:HUDPaint:Initialize", function()
		KBDuplicator.LocalPlayer = LocalPlayer()
		KBDuplicator.ScrW, KBDuplicator.ScrH = ScrW(), ScrH()

		KBDuplicator["rotation"] = 180
		KBDuplicator["pos2"] = 200
	
		if not file.Exists("kb_duplicator", "DATA") then
			file.CreateDir("kb_duplicator")
		end
	
		loadFonts()
		print("[KBDuplicator] Initialize all variables, fonts and folders")
		
		hook.Remove("HUDPaint", "KBDuplicator:HUDPaint:Initialize")
	end)

	hook.Add("OnScreenSizeChanged", "KBDuplicator:OnScreenSizeChanged", function()
		KBDuplicator.ScrW, KBDuplicator.ScrH = ScrW(), ScrH()

		loadFonts()
	end)

	local countConstructions = 0
	local function removeDrawConstructions()
		if istable(KBDuplicator["drawingEnt"]) then
			for k,v in ipairs(KBDuplicator["drawingEnt"]) do
				if not IsValid(v) then continue end
				
				v:Remove()
			end
		end

		KBDuplicator["drawingEnt"] = {}
	end
	
	local function createDrawConstructions()
		removeDrawConstructions()

		local fileRead = file.Read("kb_duplicator/"..KBDuplicator["fileName"])
		local constructionTable = util.JSONToTable(fileRead)
		local entites = constructionTable["entities"] or {}
		
		for k,v in ipairs(entites) do
			local ent = ClientsideModel(v.model, RENDERGROUP_BOTH)
			ent:Spawn()
			ent.tableInfo = v

			KBDuplicator["drawingEnt"][#KBDuplicator["drawingEnt"] + 1] = ent
		end

		KBDuplicator["difPos"] = constructionTable["infos"]["difPos"]
		KBDuplicator["originalPos"] = constructionTable["infos"]["originalPos"]
	end

	local function sendDrawConstructions()
		if not isstring(KBDuplicator["fileName"]) then return end

		local fileRead = file.Read("kb_duplicator/"..KBDuplicator["fileName"])
		local constructionTable = util.JSONToTable(fileRead)
		local entites = constructionTable["entities"] or {}
		local infos = constructionTable["infos"] or {}

		local pos2 = infos["pos2"] or 200

		net.Start("KBDuplicator:MainNet")
			net.WriteUInt(1, 5)
			net.WriteUInt(#entites, 32)
			net.WriteBool(KBDuplicator["pastToOrigin"])
			net.WriteVector(KBDuplicator["originalPos"][1])
			net.WriteVector(KBDuplicator["originalPos"][2])
			net.WriteVector(KBDuplicator["difPos"])
			net.WriteUInt(KBDuplicator["rotation"], 10)
			net.WriteUInt(pos2, 16)
			for k,v in ipairs(entites) do
				local class = (isstring(v.class) and v.class or "prop_physics")
				local model = (isstring(v.model) and v.model or "models/props_c17/fence01b.mdl")
				local pos = (isvector(v.pos) and v.pos or KBDuplicator.Constants["vector0"])
				local ang = (isangle(v.ang) and v.ang or KBDuplicator.Constants["angle0"])

				v.color = v.color or KBDuplicator.Constants["white"]
				local color = Color((v.color.r or 255), (v.color.g or 255), (v.color.b or 255), (v.color.a or 255))
				local mat = (isstring(v.material) and v.material or "")
				local scale = (isnumber(v.scale) and v.scale or 1)
				local skinNumber = (isnumber(v.skin) and v.skin or 1)
				local renderFx = (isnumber(v.renderFx) and v.renderFx or 1)
				local renderGroup = (isnumber(v.renderGroup) and v.renderGroup or 1)
				local entIndex = (isnumber(v.entIndex) and v.entIndex or 0)
				local bodgyGroup = (v.bodygroups or {})

				net.WriteUInt(entIndex, 16)
				net.WriteString(class)
				net.WriteString(model)
				net.WriteVector(pos)
				net.WriteAngle(ang)
				net.WriteColor(color)
				net.WriteString(mat)
				net.WriteFloat(scale)
				net.WriteUInt(skinNumber, 6)
				net.WriteUInt(renderFx, 6)
				net.WriteUInt(renderGroup, 6)

				net.WriteUInt(#bodgyGroup, 6)
				for k, v in ipairs(bodgyGroup) do
					net.WriteUInt(k, 6)
					net.WriteUInt(v, 6)
				end

				--[[ Send all constraints ]]
				local tableToSend = v.constraints or {}
				net.WriteUInt(table.Count(tableToSend), 16)
				for propertyType, propertyTable in pairs(tableToSend) do
					net.WriteString(propertyType)

					local propertyTableCount = table.Count(propertyTable)
					net.WriteUInt(propertyTableCount, 16)
					
					for i=1, propertyTableCount do
						net.WriteUInt(table.Count(propertyTable[i]), 16)

						for k, v in pairs(propertyTable[i]) do
							local valueType = type(v)
							net.WriteString(valueType)
							net.WriteString(k)

							net["Write"..KBDuplicator.TypeNet[valueType]](v, ((KBDuplicator.TypeNet[valueType] == "Int") and 32))
						end
					end
				end
			end
		net.SendToServer()
	end

	local function resetToolVariables()
		KBDuplicator["drawingEnt"] = nil
		KBDuplicator["originalPos"] = nil
	end

	local function reloadConstructions()
		if not IsValid(scrollConstructions) then return end
		scrollConstructions:Clear()

		local files, directories = file.Find("kb_duplicator/*", "DATA")
		countConstructions = #files

		for k, v in ipairs(files) do
			local fileRead = file.Read("kb_duplicator/"..v)
			local constructionTable = util.JSONToTable(fileRead)
			local infos = constructionTable["infos"]
			local entities = constructionTable["entities"]
			if not istable(infos) or not istable(entities) then continue end

			local savedConstruction = vgui.Create("DPanel", scrollConstructions)
			savedConstruction:Dock(TOP)
			savedConstruction:SetSize(0, KBDuplicator.ScrH*0.05)
			savedConstruction:DockMargin(KBDuplicator.ScrH*0.005, KBDuplicator.ScrH*0.005, KBDuplicator.ScrH*0.005, KBDuplicator.ScrH*0.005)
			savedConstruction.deleteConfirmation = false
			savedConstruction.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, KBDuplicator.Constants["white5"])
			end

			local constructionName = vgui.Create("DLabel", savedConstruction)
			constructionName:SetPos(KBDuplicator.ScrW*0.005, KBDuplicator.ScrH*0.007)
			constructionName:SetSize(KBDuplicator.ScrW*0.09, KBDuplicator.ScrH*0.02)
			constructionName:SetText(v)
			constructionName:SetFont("KBDuplicator:Font:01")
			constructionName:SetTextColor(KBDuplicator.Constants["white"])

			local constructionInfo = vgui.Create("DLabel", savedConstruction)
			constructionInfo:SetPos(KBDuplicator.ScrW*0.005, KBDuplicator.ScrH*0.025)
			constructionInfo:SetSize(KBDuplicator.ScrW*0.15, KBDuplicator.ScrH*0.02)

			local timeString = os.date("%d/%m/%Y", infos["date"])
			constructionInfo:SetFont("KBDuplicator:Font:03")
			constructionInfo:SetTextColor(KBDuplicator.Constants["white"])
			constructionInfo.Think = function(self)
				self:SetText(getSentence("constructionDesc"):format(timeString, #entities))
			end

			local lerpColorName = 0
			local constructionName = vgui.Create("DImageButton", savedConstruction)
			constructionName:SetPos(KBDuplicator.ScrW*0.10, KBDuplicator.ScrH*0.01)
			constructionName:SetSize(KBDuplicator.ScrH*0.03, KBDuplicator.ScrH*0.03)
			constructionName:SetImage("kb_tools/placeCube.png")
			constructionName:SetColor(KBDuplicator.Constants["white"])
			constructionName.Paint = function(self, w, h)
				lerpColorName = Lerp(FrameTime()*5, lerpColorName, (self:IsHovered() and 255 or 100))
				self:SetColor(ColorAlpha(KBDuplicator.Constants["white"], lerpColorName))
			end
			constructionName.DoClick = function()
				KBDuplicator["fileName"] = v

				local wep = KBDuplicator.LocalPlayer:GetActiveWeapon()
				if not wep or wep:GetClass() != "gmod_tool" then
					net.Start("KBDuplicator:MainNet")
						net.WriteUInt(3, 5)
					net.SendToServer()
					return
				end

				createDrawConstructions()
			end

			local lerpColorTrash = 0
			local trash = vgui.Create("DImageButton", savedConstruction)
			trash:SetPos(KBDuplicator.ScrW*0.12, KBDuplicator.ScrH*0.01)
			trash:SetSize(KBDuplicator.ScrH*0.03, KBDuplicator.ScrH*0.03)
			trash:SetImage("kb_tools/trash.png")
			trash.buttonColor = KBDuplicator.Constants["white"]
			trash:SetColor(trash.buttonColor)
			trash.Paint = function(self, w, h)
				lerpColorTrash = Lerp(FrameTime()*5, lerpColorTrash, (self:IsHovered() and 255 or 100))
				self:SetColor(ColorAlpha(trash.buttonColor, lerpColorTrash))
			end
			trash.DoClick = function()
				if not savedConstruction.deleteConfirmation then
					trash.buttonColor = KBDuplicator.Constants["red"]
					savedConstruction.deleteConfirmation = true

					timer.Simple(1, function()
						if not IsValid(savedConstruction) then return end
						if IsValid(trash) then
							trash.buttonColor = KBDuplicator.Constants["white"]
						end
						savedConstruction.deleteConfirmation = false
					end)

					return
				else
					file.Delete("kb_duplicator/"..v)
					reloadConstructions()
				end
			end

		end
		entryName:SetText(getSentence("constructionText"):format(#files + 1))
	end

	local function sendSaveToServer()
		if not KBDuplicator["originalPos"] or not isvector(KBDuplicator["originalPos"][1]) or not isvector(KBDuplicator["originalPos"][2]) then
			notification.AddLegacy(getSentence("selectZone"), NOTIFY_ERROR, 5)
			return 
		end

		local entities = ents.FindInBox(KBDuplicator["originalPos"][1], KBDuplicator["originalPos"][2])
		
		net.Start("KBDuplicator:MainNet")
			net.WriteUInt(2, 5)
			net.WriteUInt(#entities, 32)
			for k, v in ipairs(entities) do
				net.WriteUInt(v:EntIndex(), 12)
			end
		net.SendToServer()

		print("qikjdhnq sdjkqs")
	end

	local function saveConstruction(constraintsTable)
		local name = entryName:GetText()

		if not isstring(name) or #name <= 0 or file.Exists("kb_duplicator/"..name..".txt", "DATA") then 
			notification.AddLegacy(getSentence("uniqueName"), NOTIFY_ERROR, 5)
			return 
		end

		local pos1, pos2 = KBDuplicator["originalPos"][1], KBDuplicator["originalPos"][2]

		if not isvector(pos1) or not isvector(pos2) then
			notification.AddLegacy(getSentence("selectZone"), NOTIFY_ERROR, 5)
			return 
		end

		local tableToSave = {}
		
		tableToSave["entities"] = tableToSave["entities"] or {}
		for k, v in ipairs(ents.FindInBox(pos1, pos2)) do
			if v:IsWeapon() or v:IsVehicle() or v:IsNPC() or v:IsPlayer() or KBDuplicator.BlackListClass[v:GetClass()] then continue end
			if not checkIfOwner(v, KBDuplicator.LocalPlayer) then continue end

			local dir = (pos2 - pos1):Angle()
			local pos, ang = WorldToLocal(v:GetPos(), v:GetAngles(), pos1, dir)

			local bodygroups = {}
			for _, body in pairs(v:GetBodyGroups()) do
				bodygroups[body.id] = v:GetBodygroup(body.id)
			end

			local entIndex = v:EntIndex()

			tableToSave["entities"][#tableToSave["entities"] + 1] = {
				["entIndex"] = entIndex,
				["model"] = v:GetModel(),
				["class"] = v:GetClass(),
				["pos"] = pos,
				["ang"] = ang,
				["color"] = v:GetColor(),
				["material"] = v:GetMaterial(),
				["scale"] = v:GetModelScale(),
				["skin"] = v:GetSkin(),
				["bodygroups"] = bodygroups,
				["constraints"] = (constraintsTable[entIndex] or {}),
				["renderFx"] = v:GetRenderFX(),
				["renderGroup"] = v:GetRenderGroup(),
			}
		end

		if #tableToSave["entities"] <= 0 then
			notification.AddLegacy(getSentence("noProps"), NOTIFY_ERROR, 5)
			return
		end

		tableToSave["infos"] = {
			["date"] = os.time(),
			["count"] = #tableToSave,
			["ownerSteamID"] = KBDuplicator.LocalPlayer:SteamID64(),
			["ownerName"] = KBDuplicator.LocalPlayer:Name(),
			["difPos"] = WorldToLocal(pos2, KBDuplicator.Constants["angle0"], pos1, KBDuplicator.Constants["angle0"]),
			["originalPos"] = {pos1, pos2},
			["pos2"] = KBDuplicator["pos2"],
		}

		file.Write("kb_duplicator/"..name..".txt", util.TableToJSON(tableToSave))

		KBDuplicator["originalPos"] = {}
		
		reloadConstructions()
		resetToolVariables()
	end

	local function paintCPanel(CPanel)
		CPanel.Paint = function(self,w,h)
			draw.RoundedBox(4, 0, 0, w, h, KBDuplicator.Constants["black"])
			
			surface.SetDrawColor(KBDuplicator.Constants["white"])
			surface.SetMaterial(KBDuplicator.Constants["background"])
			surface.DrawTexturedRect(0, 0, w, h)
		end
		
		local mainPanel = vgui.Create("DPanel")
		mainPanel:SetSize(KBDuplicator.ScrW*0.3, KBDuplicator.ScrH*0.43)
		mainPanel:SetPos(0,0)
		mainPanel.Paint = function(self,w,h) end

		entryName = vgui.Create("DTextEntry", mainPanel)
		entryName:SetSize(mainPanel:GetWide(), KBDuplicator.ScrH*0.04)
		entryName:SetFont("KBDuplicator:Font:01")
		entryName:SetDrawLanguageID(false)
		entryName:SetText(getSentence("constructionText"):format(countConstructions + 1))
		entryName.Paint = function(self, w, h)
			self:SetSize(mainPanel:GetWide(), KBDuplicator.ScrH*0.04)

			draw.RoundedBox(0, 0, 0, w, h, KBDuplicator.Constants["white5"])
			self:DrawTextEntryText(KBDuplicator.Constants["white100"], KBDuplicator.Constants["white100"], KBDuplicator.Constants["white100"])
		end

		local lerpColor = 0
		local buttonSave = vgui.Create("DButton", mainPanel)
		buttonSave:SetSize(mainPanel:GetWide(), KBDuplicator.ScrH*0.04)
		buttonSave:SetPos(0, KBDuplicator.ScrH*0.05)
		buttonSave:SetTextColor(KBDuplicator.Constants["white"])
		buttonSave:SetFont("KBDuplicator:Font:02")
		buttonSave.DoClick = function()
			if game.SinglePlayer() then return end
		
			sendSaveToServer()
		end
		buttonSave.Paint = function(self, w, h)
			self:SetText(getSentence("saveConstruction"))
			self:SetSize(mainPanel:GetWide(), KBDuplicator.ScrH*0.04)
			
			lerpColor = Lerp(FrameTime()*5, lerpColor, (self:IsHovered() and 180 or 240))
			draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(KBDuplicator.Constants["purple120"], lerpColor))
		end

		local pastToOriginal = vgui.Create("DButton", mainPanel)
		pastToOriginal:SetSize(KBDuplicator.ScrH*0.02, KBDuplicator.ScrH*0.02)
		pastToOriginal:SetPos(0, KBDuplicator.ScrH*0.34)
		pastToOriginal:SetColor(KBDuplicator.Constants["white"])
		pastToOriginal:SetText("")

		local pastLabel = vgui.Create("DLabel", mainPanel)
		pastLabel:SetPos(KBDuplicator.ScrW*0.015, KBDuplicator.ScrH*0.324)
		pastLabel:SetSize(KBDuplicator.ScrW*0.12, KBDuplicator.ScrH*0.05)
		pastLabel:SetFont("KBDuplicator:Font:01")
		pastLabel:SetTextColor(KBDuplicator.Constants["white"])
		
		pastToOriginal.Paint = function(self, w, h)
			pastLabel:SetText(getSentence("pasteAtOriginal"))

			surface.SetDrawColor(KBDuplicator.Constants["white"])
			surface.SetMaterial(KBDuplicator.Constants[(KBDuplicator["pastToOrigin"] and "checkedBox" or "uncheckedBox")])
			surface.DrawTexturedRect(0, 0, w, h)
		end
		pastToOriginal.DoClick = function()
			KBDuplicator["pastToOrigin"] = !KBDuplicator["pastToOrigin"]
		end

		local sliderPos2Label = vgui.Create("DLabel", mainPanel)
		sliderPos2Label:SetPos(KBDuplicator.ScrW*0.0, KBDuplicator.ScrH*0.355)
		sliderPos2Label:SetSize(KBDuplicator.ScrW*0.12, KBDuplicator.ScrH*0.05)
		sliderPos2Label:SetFont("KBDuplicator:Font:01")
		sliderPos2Label:SetTextColor(KBDuplicator.Constants["white"])
		sliderPos2Label.Think = function(self)
			self:SetText(getSentence("pos2Label"))
		end

		local sliderPos2 = vgui.Create("DNumSlider", mainPanel)
		sliderPos2:SetPos(KBDuplicator.ScrW*0.001, KBDuplicator.ScrH*0.375)
		sliderPos2:SetSize(KBDuplicator.ScrW*0.2, KBDuplicator.ScrH*0.05)
		sliderPos2:SetMinMax(200, 5000)
		sliderPos2:SetValue(200)
		sliderPos2.TextArea:SetVisible(false)
		sliderPos2.Label:SetVisible(false)
		sliderPos2.Paint = function(self, w, h)
			self:SetSize(mainPanel:GetWide(), KBDuplicator.ScrH*0.05)

			local coef = math.Remap(sliderPos2:GetValue(), sliderPos2:GetMin(), sliderPos2:GetMax(), 0, 1)
	
			draw.RoundedBox(0, 0, h*0.5-KBDuplicator.ScrH*0.005/2, w*0.99, KBDuplicator.ScrH*0.005, KBDuplicator.Constants["grey"])
			draw.RoundedBox(0, 0, h*0.5-KBDuplicator.ScrH*0.005/2, w*coef*0.99, KBDuplicator.ScrH*0.005, KBDuplicator.Constants["purple"])
		end
		sliderPos2.Slider.Paint = function() end
		sliderPos2.Slider.Knob.Paint = function(self, w, h)
			draw.NoTexture()
			draw.RoundedBox(4, 0, 0, w, h, KBDuplicator.Constants["grey"])
		end
		sliderPos2.OnValueChanged = function(self, value)
			KBDuplicator["pos2"] = value
		end
	
		scrollConstructions = vgui.Create("DScrollPanel", mainPanel)
		scrollConstructions:SetSize(mainPanel:GetWide(), KBDuplicator.ScrH*0.225)
		scrollConstructions:SetPos(0, KBDuplicator.ScrH*0.1)
		scrollConstructions.Paint = function(self, w, h)
			self:SetSize(mainPanel:GetWide(), KBDuplicator.ScrH*0.225)

			draw.RoundedBox(0, 0, 0, w, h, KBDuplicator.Constants["white5"])

			if countConstructions <= 0 then
				draw.DrawText(getSentence("noConstructions"), "KBDuplicator:Font:01", w*0.5, h*0.35, KBDuplicator.Constants["white"], TEXT_ALIGN_CENTER)
			end
		end
		
		local scrollBar = scrollConstructions:GetVBar()
		scrollBar:SetWide(KBDuplicator.ScrW*0.003)
		scrollBar.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, KBDuplicator.Constants["grey30"])
		end
		scrollBar.btnUp.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, KBDuplicator.Constants["grey30"])
		end
		scrollBar.btnDown.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, KBDuplicator.Constants["grey30"])
		end
		scrollBar.btnGrip.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, KBDuplicator.Constants["grey30"])
		end

		reloadConstructions()
		CPanel:AddPanel(mainPanel)
	end

	function TOOL.BuildCPanel(CPanel)
		if CLIENT then
			CPanel:AddControl("Header", {
				Text = "#tool.kb_duplicator.name",
				Description = ""
			})

			paintCPanel(CPanel)
		end
	end

	function TOOL:Deploy()
		KBDuplicator["rotation"] = 180
		KBDuplicator["pos2"] = 200
	end
	
	function TOOL:LeftClick()
		local curTime = CurTime()

		KBDuplicator["spamClick"] = KBDuplicator["spamClick"] or 0
		if KBDuplicator["spamClick"] > curTime then return end
		KBDuplicator["spamClick"] = curTime + 0.5

		if CLIENT then
			if KBDuplicator["drawingEnt"] then
				sendDrawConstructions(fileName)
			else
				
				KBDuplicator["originalPos"] = KBDuplicator["originalPos"] or {}
				if not isvector(KBDuplicator["originalPos"][1]) then
					local trace = getTrace(KBDuplicator.LocalPlayer, 200)
					
					KBDuplicator["originalPos"][1] = trace.HitPos
				else
					local trace = getTrace(KBDuplicator.LocalPlayer, KBDuplicator["pos2"])
					
					KBDuplicator["originalPos"][2] = trace.HitPos
				end
			end
		end
	end

	function TOOL:RightClick()
		local curTime = CurTime()

		KBDuplicator["spamClick"] = KBDuplicator["spamClick"] or 0
		if KBDuplicator["spamClick"] > curTime then return end
		KBDuplicator["spamClick"] = curTime + 0.5

		removeDrawConstructions()
		resetToolVariables()
	end

	function TOOL:Reload()
		local curTime = CurTime()

		KBDuplicator["spamClick"] = KBDuplicator["spamClick"] or 0
		if KBDuplicator["spamClick"] > curTime then return end
		KBDuplicator["spamClick"] = curTime + 0.5

		KBDuplicator["rotation"] = KBDuplicator["rotation"] or 180

		if KBDuplicator["rotation"] < 360 then
			KBDuplicator["rotation"] = KBDuplicator["rotation"] + 90
		else
			KBDuplicator["rotation"] = 0
		end
	end

	function TOOL:Holster()
		removeDrawConstructions()
		resetToolVariables()
	end

	function TOOL:DrawToolScreen(w, h)
		surface.SetDrawColor(KBDuplicator.Constants["white"])
		surface.SetMaterial(KBDuplicator.Constants["toolgun"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	hook.Add("PostDrawTranslucentRenderables", "KBDuplicator:PostDrawTranslucentRenderables:Box", function()
		if not istable(KBDuplicator["originalPos"]) then return end

		KBDuplicator["rotation"] = KBDuplicator["rotation"] or 180

		if istable(KBDuplicator["drawingEnt"]) then
			local trace = getTrace(KBDuplicator.LocalPlayer, 200)
			
			local pos1 = (KBDuplicator["pastToOrigin"] and KBDuplicator["originalPos"][1] or trace.HitPos)
			local pos2 = LocalToWorld(KBDuplicator["difPos"], KBDuplicator.Constants["angle0"], pos1, KBDuplicator.Constants["angle0"])
	
			local dir = (KBDuplicator["pastToOrigin"] and KBDuplicator.Constants["angle0"] or Angle(0, KBDuplicator.LocalPlayer:EyeAngles().y + KBDuplicator["rotation"], 0))
			render.DrawWireframeBox(pos1, dir, KBDuplicator.Constants["vector0"], KBDuplicator["difPos"], KBDuplicator.Constants["green"], true)
		else	
			local pos1 = KBDuplicator["originalPos"][1]
			if not isvector(pos1) then return end
	
			local trace = getTrace(KBDuplicator.LocalPlayer, KBDuplicator["pos2"])
			local pos2 = (KBDuplicator["originalPos"][2] or trace.HitPos)
			if not isvector(pos2) then return end
	
			render.DrawWireframeBox(KBDuplicator.Constants["vector0"], KBDuplicator.Constants["angle0"], pos1, pos2, KBDuplicator.Constants["green"], true)
		end
	end)

	hook.Add("HUDPaint", "KBDuplicator:HUDPaint:PosScreen", function()
		if not IsValid(KBDuplicator.LocalPlayer) then return end
		if not istable(KBDuplicator["originalPos"]) then return end

		KBDuplicator["rotation"] = KBDuplicator["rotation"] or 180

		local trace = getTrace(KBDuplicator.LocalPlayer, 200)
		
		local posToScreen1, posToScreen2
		local pos1 = (not KBDuplicator["drawingEnt"] and KBDuplicator["originalPos"][1] or KBDuplicator["pastToOrigin"] and KBDuplicator["originalPos"][1] or trace.HitPos)
		if not isvector(pos1) then return end
		posToScreen1 = pos1:ToScreen()

		local trace = getTrace(KBDuplicator.LocalPlayer, KBDuplicator["pos2"])

		local pos2 = (not KBDuplicator["drawingEnt"] and (KBDuplicator["originalPos"][2] and KBDuplicator["originalPos"][2] or trace.HitPos) or LocalToWorld(KBDuplicator["difPos"], KBDuplicator.Constants["angle0"], pos1, (KBDuplicator["pastToOrigin"] and KBDuplicator.Constants["angle0"] or Angle(0, KBDuplicator.LocalPlayer:EyeAngles().y + KBDuplicator["rotation"], 0))))
		if not isvector(pos2) then return end
		posToScreen2 = pos2:ToScreen()

		if not posToScreen1 or not posToScreen2 then return end

		draw.DrawText(getSentence("pos"):format("1"), "KBDuplicator:Font:05", posToScreen1.x, posToScreen1.y - 25, KBDuplicator.Constants["white2"], TEXT_ALIGN_CENTER)
		draw.DrawText("●", "KBDuplicator:Font:04", posToScreen1.x, posToScreen1.y - 20, KBDuplicator.Constants["white2"], TEXT_ALIGN_CENTER)

		draw.DrawText(getSentence("pos"):format("2"), "KBDuplicator:Font:05", posToScreen2.x, posToScreen2.y - 25, KBDuplicator.Constants["white2"], TEXT_ALIGN_CENTER)
		draw.DrawText("●", "KBDuplicator:Font:04", posToScreen2.x, posToScreen2.y - 20, KBDuplicator.Constants["white2"], TEXT_ALIGN_CENTER)

		for k, v in pairs(ents.FindInBox(pos1, pos2)) do
			if v:IsWeapon() or v:IsVehicle() or v:IsNPC() or v:IsPlayer() or KBDuplicator.BlackListClass[v:GetClass()] then continue end

			if KBDuplicator.Halo && KBDuplicator.Halo.Add then
				KBDuplicator.Halo.Add(v, (checkIfOwner(v, KBDuplicator.LocalPlayer) and KBDuplicator.Constants["green"] or KBDuplicator.Constants["red"]), OUTLINE_MODE_BOTH)
			end
		end
	end)

	hook.Add("Think", "KBDuplicator:Think:UpdateEnt", function()
		if not IsValid(KBDuplicator.LocalPlayer) then return end
		if not istable(KBDuplicator["originalPos"]) then return end

		if not KBDuplicator or not KBDuplicator["drawingEnt"] then return end
		
		local trace = getTrace(KBDuplicator.LocalPlayer, 200)
		local pos1 = (KBDuplicator["pastToOrigin"] and KBDuplicator["originalPos"][1] or trace.HitPos)
		local pos2 = LocalToWorld(KBDuplicator["difPos"], KBDuplicator.Constants["angle0"], pos1, KBDuplicator.Constants["angle0"])

		local dir = (pos2 - pos1):Angle() + (KBDuplicator["pastToOrigin"] and KBDuplicator.Constants["angle0"] or Angle(0, KBDuplicator.LocalPlayer:EyeAngles().y + KBDuplicator["rotation"], 0))

		for k,v in ipairs(KBDuplicator["drawingEnt"]) do
			if not IsValid(v) then continue end

			local entTable = v.tableInfo
			local pos, ang = LocalToWorld(entTable.pos, entTable.ang, pos1, dir)

			if isvector(pos) then
				v:SetPos(pos)
			end
			if isangle(ang) then
				v:SetAngles(ang)
			end
			if istable(entTable.color) or IsColor(entTable.color) then
				v:SetColor(entTable.color)
			end
			if isstring(entTable.material) then
				v:SetMaterial(entTable.material)
			end
			if isnumber(entTable.scale) then
				v:SetModelScale(entTable.scale)
			end
			if isnumber(entTable.skin) then
				v:SetSkin(entTable.skin)
			end
			if isnumber(entTable.renderGroup) then
				v:SetRenderMode(entTable.renderGroup)
			end
			if isnumber(entTable.renderFx) then
				v:SetRenderFX(entTable.renderFx)
			end

			for bk, bv in pairs(entTable.bodygroups) do
				v:SetBodygroup(bk, bv)
			end
		end
	end)

	net.Receive("KBDuplicator:MainNet", function()
		local uInt = net.ReadUInt(5)
		
		if uInt == 1 then
			removeDrawConstructions()
			resetToolVariables()
		elseif uInt == 2 then
			local text = net.ReadString()
			local legacyType = net.ReadUInt(5)
			local time = net.ReadUInt(5)

			notification.AddLegacy(text, legacyType, time)
		elseif uInt == 3 then
			local constraintsByEntIndex = {}
			
			local tableCount = net.ReadUInt(16)
			for i=1, tableCount do
				local entTableCount = net.ReadUInt(16)
				local entIndex = net.ReadUInt(16)
				
				local tableIndexCount = net.ReadUInt(16)
				for j=1, tableIndexCount do
					local propertyType = net.ReadString()

					local propertiesTableCount = net.ReadUInt(16)
					for h=1, propertiesTableCount do
						local propertiesCount = net.ReadUInt(16)

						for k=1, propertiesCount do
							local valueType = net.ReadString()
							local key = net.ReadString()								
							local value = net["Read"..KBDuplicator.TypeNet[valueType]](((KBDuplicator.TypeNet[valueType] == "Int") and 32))
						
							constraintsByEntIndex[entIndex] = constraintsByEntIndex[entIndex] or {}
							constraintsByEntIndex[entIndex][propertyType] = constraintsByEntIndex[entIndex][propertyType] or {}
							constraintsByEntIndex[entIndex][propertyType][h] = constraintsByEntIndex[entIndex][propertyType][h] or {}
	
							constraintsByEntIndex[entIndex][propertyType][h][key] = value
						end
					end
				end
			end

			saveConstruction(constraintsByEntIndex)
		elseif uInt == 4 then
			createDrawConstructions()
		elseif uInt == 5  then
			local err = net.ReadString()

			SetClipboardText(err)
			print("[KBDuplicator] "..err)
		end
	end)
else
	util.AddNetworkString("KBDuplicator:MainNet")

	local function createNotify(ply, text, legacyType, time)
		net.Start("KBDuplicator:MainNet")
			net.WriteUInt(2, 5)
			net.WriteString(text)
			net.WriteUInt(legacyType, 5)
			net.WriteUInt(time, 5)
		net.Send(ply)
	end

	net.Receive("KBDuplicator:MainNet", function(len, ply)
		ply.KBDuplicator = ply.KBDuplicator or {}

		local curtime = CurTime()
		
		ply.KBDuplicator["antiSpam"] = ply.KBDuplicator["antiSpam"] or 0
		if ply.KBDuplicator["antiSpam"] > curtime then
			createNotify(ply, getSentence("noSpam"), 1, 5)
			return 
		end
		ply.KBDuplicator["antiSpam"] = curtime + 3

		local uInt = net.ReadUInt(5)

		local tools = ply:GetActiveWeapon()
		if not IsValid(tools) then return end

		if tools:GetClass() != "gmod_tool" then return end

		--[[ Spawn protection ]]
		if uInt == 1 then
			local steamId = ply:SteamID64()
			local timerName = "kb_duplicator_spawnconstruct:"..steamId
			if timer.Exists(timerName) then
				return
			end
			
			local propsCount = net.ReadUInt(32)
			local pastToOrigin = net.ReadBool()
			local originalPos1 = net.ReadVector()
			local originalPos2 = net.ReadVector()
			local difPos = net.ReadVector()
			local rotation = net.ReadUInt(10)
			local pos2Add = net.ReadUInt(16)

			local trace = getTrace(ply, 200)

			local pos1 = (pastToOrigin and originalPos1 or trace.HitPos)
			local pos2 = LocalToWorld(difPos, KBDuplicator.Constants["angle0"], pos1, KBDuplicator.Constants["angle0"])

			local dir = (pos2 - pos1):Angle() + (pastToOrigin and KBDuplicator.Constants["angle0"] or Angle(0, ply:EyeAngles().y + rotation, 0))
			
			if pos1:DistToSqr(ply:GetPos()) > 5000000 then
				createNotify(ply, getSentence("tooFar"), 1, 5)
				return 
			end
			
			local entitiesToSpawn = {}
			local toolsTable = tools:GetTable()

			for i=1, propsCount do
				local entIndex = net.ReadUInt(16)
				local class = net.ReadString()
				local model = net.ReadString()
				local pos = net.ReadVector()
				local ang = net.ReadAngle()
				local color = net.ReadColor()
				local material = net.ReadString()
				local scale = net.ReadFloat()
				local skinModel = net.ReadUInt(6)
				local renderFx = net.ReadUInt(6)
				local renderGroup = net.ReadUInt(6)

				local countBodyGroups = net.ReadUInt(6)

				local bodygroups = {}
				for i=1, countBodyGroups do
					local bodygroup = net.ReadUInt(6)
					local value = net.ReadUInt(6)

					bodygroups[bodygroup] = value
				end
				
				local constraintsByEntIndex = {}
			
				local tableIndexCount = net.ReadUInt(16)
				for j=1, tableIndexCount do
					local propertyType = net.ReadString()

					local propertiesTableCount = net.ReadUInt(16)
					for h=1, propertiesTableCount do
						local propertiesCount = net.ReadUInt(16)

						for k=1, propertiesCount do
							local valueType = net.ReadString()
							local key = net.ReadString()								
							local value = net["Read"..KBDuplicator.TypeNet[valueType]](((KBDuplicator.TypeNet[valueType] == "Int") and 32))
						
							constraintsByEntIndex = constraintsByEntIndex or {}
							constraintsByEntIndex[propertyType] = constraintsByEntIndex[propertyType] or {}
							constraintsByEntIndex[propertyType][h] = constraintsByEntIndex[propertyType][h] or {}
	
							constraintsByEntIndex[propertyType][h][key] = value
							constraintsByEntIndex[propertyType][h]["ply"] = ply
						end
					end
				end
			
				local posToSet, angToSet = LocalToWorld(pos, ang, pos1, dir)
				
				entitiesToSpawn[#entitiesToSpawn + 1] = {
					["entIndex"] = entIndex,
					["class"] = class,
					["model"] = model,
					["pos"] = posToSet,
					["ang"] = angToSet,
					["color"] = color,
					["material"] = material,
					["scale"] = scale,
					["skin"] = skinModel,
					["bodygroups"] = bodygroups,
					["constraints"] = constraintsByEntIndex,
					["renderFx"] = renderFx,
					["renderGroup"] = renderGroup,
				}
			end

			if #entitiesToSpawn <= 0 then return end
			
			local entitiesOldIndex = {}
			local incrementId = 0
			timer.Create(timerName, 0.1, #entitiesToSpawn, function()
				incrementId = incrementId + 1

				local entityTable = entitiesToSpawn[incrementId]
				if not istable(entityTable) then return end

				local entClass = entityTable.class
				if entClass == "prop_physics" then
					if hook.Run("PlayerSpawnProp", ply, entityTable.model) == false then return end
				else
					if hook.Run("PlayerSpawnSENT", ply, entClass) == false then return end
				end
				
				local prop 
				if istable(KBDuplicator.PropertiesEnt[entClass]) && isfunction(KBDuplicator.PropertiesEnt[entClass]["load"]) && KBDuplicator.PropertiesEnt[entClass]["accepted"] then
					local constraints = entityTable["constraints"] or {}
					local entityTable = constraints[entClass] or {}

					local succ, err = pcall(function() prop = KBDuplicator.PropertiesEnt[entClass]["load"](entityTable, ply) end)
					if not succ then
						createNotify(ply, getSentence("problemSpawn"), 1, 5)

						net.Start("KBDuplicator:MainNet")
							net.WriteUInt(5, 5)
							net.WriteString(err)
						net.Send(ply)
					end
				else
					prop = ents.Create(entClass)
				end
				if not IsValid(prop) then return end

				if isstring(entityTable.model) then
					prop:SetModel(entityTable.model)
				end
				if isvector(entityTable.pos) then
					prop:SetPos(entityTable.pos)
				end
				if isangle(entityTable.ang) then
					prop:SetAngles(entityTable.ang)
				end
				if isnumber(entityTable.renderFx) then
					prop:SetRenderFX(entityTable.renderFx)
				end
				if isnumber(entityTable.renderGroup) then
					prop:SetRenderMode(entityTable.renderGroup)
				end					
				if isfunction(prop.CPPISetOwner) then
					prop:CPPISetOwner(ply)
				end

				prop:Spawn()

				if isstring(KBDuplicator.ClassToType[entClass]) then
					ply:AddCount(KBDuplicator.ClassToType[entClass], prop)
				end

				if isnumber(entityTable.entIndex) then
					entitiesOldIndex[entityTable.entIndex] = prop
				end

				if isstring(entityTable.material) then
					if hook.Run("CanTool", ply, {["Entity"] = prop}, "material", toolsTable["material"], 1) then
						prop:SetMaterial(entityTable.material)
					end
				end

				if IsColor(entityTable.color) or istable(entityTable.color) then
					if hook.Run("CanTool", ply, {["Entity"] = prop}, "color", toolsTable["color"], 1) then
						prop:SetColor(entityTable.color)
					end
				end
				
				if isnumber(entityTable.scale) then
					if hook.Run("CanTool", ply, {["Entity"] = prop}, "scale", toolsTable["scale"], 1) then
						prop:SetModelScale(entityTable.scale)
					end
				end

				if isnumber(entityTable.skin) then
					if hook.Run("CanTool", ply, {["Entity"] = prop}, "skin", toolsTable["skin"], 1) then
						prop:SetSkin(entityTable.skin)
					end
				end

				if hook.Run("CanProperty", ply, "bodygroups", prop) then
					local bodygroups = entityTable["bodygroups"] or {}

					for k, v in pairs(bodygroups) do
						prop:SetBodygroup(k, v)
					end
				end
				
				local phys = prop:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
					phys:SetMaterial((entityTable.physMaterial or ""))
				end

				prop:Activate()

				ply.KBDuplicator["undoConstruction"] = ply.KBDuplicator["undoConstruction"] or {}
				ply.KBDuplicator["undoConstruction"][#ply.KBDuplicator["undoConstruction"] + 1] = prop

				if timer.RepsLeft(timerName) <= 0 then

					local incrementIdConstrains = 0
					timer.Create("kb_duplicator_constrains:"..steamId, 0.05, #entitiesToSpawn, function()
						incrementIdConstrains = incrementIdConstrains + 1

						local entIndex = entityTable["entIndex"]
						local entityTable = entitiesToSpawn[incrementIdConstrains] or {}

						local propertiesTable = entityTable["constraints"] or {}
						local ent = entitiesOldIndex[entIndex]
						if not IsValid(ent) then return end
						
						for propertyType, propertyTable in pairs(propertiesTable) do
							if not KBDuplicator.Constraints[propertyType] then continue end
							if not KBDuplicator.Constraints[propertyType]["accepted"] then continue end
							if not isfunction(KBDuplicator.Constraints[propertyType]["load"]) then continue end
							
							for k, v in pairs(propertyTable) do
								if hook.Run("CanTool", ply, {["Entity"] = prop}, propertyType, {}, 1) then
									local succ, err = pcall(function() KBDuplicator.Constraints[propertyType]["load"](v, entitiesOldIndex, ent, ply) end)
									if not succ then
										createNotify(ply, getSentence("problemSpawn"), 1, 5)
	
										net.Start("KBDuplicator:MainNet")
											net.WriteUInt(5, 5)
											net.WriteString(err)
										net.Send(ply)
									end
								end
							end
						end

						for k, v in pairs(KBDuplicator.OtherProperties) do
							if not KBDuplicator.OtherProperties[k] then continue end
							if not KBDuplicator.OtherProperties[k]["accepted"] then continue end
							if not isfunction(KBDuplicator.OtherProperties[k]["load"]) then continue end
							if not propertiesTable[k] then continue end

							local succ, err = pcall(function() KBDuplicator.OtherProperties[k]["load"](propertiesTable[k][1], ent, ply) end)
							if not succ then
								createNotify(ply, getSentence("problemSpawn"), 1, 5)

								net.Start("KBDuplicator:MainNet")
									net.WriteUInt(5, 5)
									net.WriteString(err)
								net.Send(ply)
							end
						end
					end)

					ply.KBDuplicator["undoConstruction"] = ply.KBDuplicator["undoConstruction"] or {}

					undo.Create("KBDuplicator")
					for k, v in pairs(ply.KBDuplicator["undoConstruction"]) do 
						if not IsValid(v) then continue end

						undo.AddEntity(v)
						undo.SetPlayer(ply)
					end
					undo.Finish()

					ply.KBDuplicator["undoConstruction"] = {}

					createNotify(ply, getSentence("successPast"), 0, 5)
				end
			end)
	
			net.Start("KBDuplicator:MainNet")
				net.WriteUInt(1, 5)
			net.Send(ply)
		elseif uInt == 2 then
			local tableToSend = {}
			local countEntity = net.ReadUInt(32)

			for i=1, countEntity do
				local entIndex = net.ReadUInt(12)
				tableToSend[entIndex] = tableToSend[entIndex] or {}

				local ent = Entity(entIndex)
				if not IsValid(ent) then continue end

				local contraints = constraint.GetTable(ent)
				local entTable = ent:GetTable()
				local entClass = ent:GetClass()

				if istable(KBDuplicator.PropertiesEnt[entClass]) then
					if isfunction(KBDuplicator.PropertiesEnt[entClass]["save"]) && KBDuplicator.PropertiesEnt[entClass]["accepted"] then

						tableToSend[entIndex][entClass] = tableToSend[entIndex][entClass] or {}
						tableToSend[entIndex][entClass][#tableToSend[entIndex][entClass] + 1] = KBDuplicator.PropertiesEnt[entClass]["save"](entTable, ent)
					end
				end
	
				for k, v in pairs(contraints) do
					if not istable(KBDuplicator.Constraints[v.Type]) then continue end
					if not isfunction(KBDuplicator.Constraints[v.Type]["save"]) then continue end
					if not KBDuplicator.Constraints[v.Type]["accepted"] then continue end
						
					tableToSend[entIndex][v.Type] = tableToSend[entIndex][v.Type] or {}
					tableToSend[entIndex][v.Type][#tableToSend[entIndex][v.Type] + 1] = KBDuplicator.Constraints[v.Type]["save"](v, ent)
				end
				
				for k, v in pairs(KBDuplicator.OtherProperties) do
					if not istable(KBDuplicator.OtherProperties[k]) then continue end
					if not isfunction(KBDuplicator.OtherProperties[k]["save"]) then continue end
					if not KBDuplicator.OtherProperties[k]["accepted"] then continue end
					
					tableToSend[entIndex][k] = tableToSend[entIndex][k] or {}
					tableToSend[entIndex][k][#tableToSend[entIndex][k] + 1] = KBDuplicator.OtherProperties[k]["save"](entTable, ent)
				end
			end

			net.Start("KBDuplicator:MainNet")
				net.WriteUInt(3, 5)

				net.WriteUInt(table.Count(tableToSend), 16)
				for entIndex, entTable in pairs(tableToSend) do
					net.WriteUInt(table.Count(entTable), 16)
					net.WriteUInt(entIndex, 16)

					net.WriteUInt(table.Count(tableToSend[entIndex]), 16)
					for propertyType, propertyTable in pairs(tableToSend[entIndex]) do
						net.WriteString(propertyType)

						local propertyTableCount = table.Count(propertyTable)
						net.WriteUInt(propertyTableCount, 16)
						
						for i=1, propertyTableCount do
							net.WriteUInt(table.Count(propertyTable[i]), 16)

							for k, v in pairs(propertyTable[i]) do
								local valueType = type(v)
								net.WriteString(valueType)
								net.WriteString(k)

								net["Write"..KBDuplicator.TypeNet[valueType]](v, ((KBDuplicator.TypeNet[valueType] == "Int") and 32))
							end
						end
					end
				end
			net.Send(ply)
		elseif uInt == 3 then
			if ply:HasWeapon("gmod_tool") then
				ply:SelectWeapon("gmod_tool")
				
				net.Start("KBDuplicator:MainNet")
					net.WriteUInt(4, 5)
				net.Send(ply)
			end
		end
	end)
end