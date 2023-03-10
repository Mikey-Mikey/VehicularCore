E2Lib.RegisterExtension("vehicularcore", false, "E2 functions for controlling vehicles of multiple kinds")

local vehicular = {}

local function isSimfphys(e)
    return e and e:GetClass() == "gmod_sent_vehicle_fphysics_base"
end

local function isVehicle(e)
    return e and (e:IsVehicle() or isSimfphys(e))
end

__e2setcost(5)

e2function number entity:isSimfphys()
    return isSimfphys(this) and 1 or 0
end

e2function void entity:setEngineState(state)
    if !isVehicle(this) then
        self:throw("This entity isn't a vehicle!", "")
        return
    end
    if isSimfphys(this) then
        if state ~= 0 then
            this:SetActive(true)
            this:StartEngine()
        else
            this:SetActive(false)
            this:StopEngine()
        end
    else
        this:StartEngine(state == 1)
    end
end

e2function void entity:setThrottle(throttle)
    if !isVehicle(this) then
        self:throw("This entity isn't a vehicle!", "")
        return
    end
    if isSimfphys(this) then
        this.PressedKeys["joystick_throttle"] = math.Clamp(throttle,0,1)
        this.PressedKeys["joystick_brake"] = -math.Clamp(throttle,-1,0)
    else
        this:SetThrottle(throttle)
    end
end

e2function void entity:setSteering(steer)
    if !isVehicle(this) then
        self:throw("This entity isn't a vehicle!", "")
        return
    end
    if isSimfphys(this) then
        this:SteerVehicle(math.Clamp( steer, -1 , 1) * this.VehicleData["steerangle"])
    else
        this:SetSteering(math.Clamp(steer,-1,1), 0)
    end
end

e2function void entity:setHandbrake(value)
    if !isVehicle(this) then
        self:throw("This entity isn't a vehicle!", "")
        return
    end
    if isSimfphys(this) then
        this.PressedKeys["joystick_handbrake"] = value ~= 0 and 1 or 0
    else
        this:SetHandbrake(value == 1)
    end
end
e2function void entity:setClutch(value)
    if !isSimfphys(this) then
        self:throw("This entity isn't a simfphys vehicle!", "")
        return
    end
    this.PressedKeys["joystick_clutch"] = value ~= 0 and 1 or 0
end

e2function void entity:ejectDriver()
    if !isVehicle(this) then
        self:throw("This entity isn't a vehicle!", "")
        return
    end
    if isSimfphys(this) then
        this:GetDriver():ExitVehicle()
    else
        this:GetDriver():ExitVehicle()
    end
end

e2function void entity:ejectPassengers()
    if !isVehicle(this) then
        self:throw("This entity isn't a vehicle!", "")
        return
    end
    if isSimfphys(this) and istable(this.pSeat) then
        for i,seat in ipairs(this.pSeat) do
            if IsValid(seat) then
                local Driver = seat:GetDriver()

                if IsValid(Driver) then
                    Driver:ExitVehicle()
                end
            end
        end
    end
end

e2function void entity:setGear(gear)
    if !isSimfphys(this) then
        self:throw("This entity isn't a simfphys vehicle!", "")
        return
    end
    this:ForceGear(math.Round(gear,0))
end


e2function void entity:setLocked(value)
    if !isVehicle(this) then
        self:throw("This entity isn't a vehicle!", "")
        return
    end
    if isSimfphys(this) then
        if value ~= 0 then
            this:Lock()
        else
            this:UnLock()
        end
    else
        this.vehicular_core_locked = value ~= 0
    end
end

e2function void entity:setHeadlights(value)
    if !isSimfphys(this) then
        self:throw("This entity isn't a simfphys vehicle!", "")
        return
    end
    if isSimfphys(this) then
        this.LightsActivated = value ~= 0
		this.LampsActivated = value ~= 0
			
		this:SetLightsEnabled(value ~= 0)
		this:SetLampsEnabled(value ~= 0)
    end
end

hook.Add("CanPlayerEnterVehicle", "vehicular_core_vehicleenter", function(ply, vehicle, seatnum)
    if vehicle.vehicular_core_locked then
        return false
    end
end)