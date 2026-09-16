local missile_guidance = {}

-- Active guidance state
missile_guidance.active = false
missile_guidance.protocol = "missile_command_center"
missile_guidance.missile_connected = false
missile_guidance.last_missile_telemetry_time = 0
missile_guidance.timeout_seconds = 10

-- Latest telemetry cache
missile_guidance.telemetry = {
    gyro = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
        pitch = 0,
        roll = 0,
        yaw = 0,
        pitch_rate = 0,
        roll_rate = 0,
        yaw_rate = 0,
        timestamp = 0
    },
    missile = {
        x = 0,
        y = 0,
        z = 0
    }
}

-- Current flight configuration
missile_guidance.config = {
    target = nil,
    gyro_id = nil,
    pitch_id = nil,
    roll_id = nil,
    missile_id = nil,
    on_telemetry = nil,
    on_status = nil
}

---Ensures incoming telemetry is a table
---@param message any
---@return table?
local function parse_payload(message)
    if type(message) == "table" then
        return message
    elseif type(message) == "string" and textutils and textutils.unserialize then
        return textutils.unserialize(message)
    end
    return nil
end

---Processes incoming gyro telemetry ({ left = [0-15], right = [0-15], top = [0-15], bottom = [0-15] })
---@param data table|any
---@return boolean success
function missile_guidance.process_gyro_telemetry(data)
    local payload = parse_payload(data)
    if not payload then
        return false
    end

    local g = missile_guidance.telemetry.gyro

    -- Direct sensor readings [0-15]
    g.left = tonumber(payload.left) or 0
    g.right = tonumber(payload.right) or 0
    g.top = tonumber(payload.top) or 0
    g.bottom = tonumber(payload.bottom) or 0

    -- Derived deflections: top vs bottom (pitch), right vs left (roll)
    g.pitch = g.top - g.bottom
    g.roll = g.right - g.left
    g.timestamp = (os.epoch and os.epoch("utc")) or (os.clock and os.clock()) or 0

    return true
end

---Processes incoming missile telemetry ({ x = number, y = number, z = number })
---@param data table|any
---@return boolean success
function missile_guidance.process_missile_telemetry(data)
    local payload = parse_payload(data)
    if not payload then
        return false
    end

    local m = missile_guidance.telemetry.missile
    m.x = tonumber(payload.x) or m.x
    m.y = tonumber(payload.y) or m.y
    m.z = tonumber(payload.z) or m.z

    missile_guidance.last_missile_telemetry_time = (os.clock and os.clock()) or 0
    missile_guidance.missile_connected = true

    return true
end

---Dispatches a steering command to the Pitch computer
---@param pitch_id number Computer ID for the pitch actuator
---@param command table|number Pitch command value or command structure
---@return boolean sent
function missile_guidance.send_pitch_command(pitch_id, command)
    if not pitch_id or not rednet or not rednet.isOpen() then
        return false
    end

    local payload = type(command) == "table" and command or {
        type = "pitch_command",
        command = "pitch",
        value = tonumber(command) or 0,
        target = tonumber(command) or 0,
        timestamp = (os.epoch and os.epoch("utc")) or (os.clock and os.clock()) or 0
    }

    return rednet.send(pitch_id, payload, missile_guidance.protocol)
end

---Dispatches a steering command to the Roll computer
---@param roll_id number Computer ID for the roll actuator
---@param command table|number Roll command value or command structure
---@return boolean sent
function missile_guidance.send_roll_command(roll_id, command)
    if not roll_id or not rednet or not rednet.isOpen() then
        return false
    end

    local payload = type(command) == "table" and command or {
        type = "roll_command",
        command = "roll",
        value = tonumber(command) or 0,
        target = tonumber(command) or 0,
        timestamp = (os.epoch and os.epoch("utc")) or (os.clock and os.clock()) or 0
    }

    return rednet.send(roll_id, payload, missile_guidance.protocol)
end

---Guidance calculation logic hook
---Calculates required pitch and roll control commands based on current telemetry and target coordinates.
---@param telemetry table Current state of gyro and missile telemetry
---@param target table Target coordinates {x, y, z}
---@return table|number|nil pitch_command, table|number|nil roll_command
function missile_guidance.calculate_guidance_commands(telemetry, target)
    if not target then
        return nil, nil
    end

    -- Stub for guidance logic:
    -- Currently maintains stable level heading or passes placeholder zero-correction
    -- until specific guidance algorithm (PN / pursuit / PID) is implemented.
    local gyro = telemetry.gyro
    local missile = telemetry.missile

    -- Placeholder calculation to demonstrate data flow
    local pitch_cmd = {
        type = "pitch_command",
        value = 0,
        top = gyro.top,
        bottom = gyro.bottom,
        target_pitch = 0,
        current_pitch = gyro.pitch, -- derived from (top - bottom)
        target_coords = target
    }

    local roll_cmd = {
        type = "roll_command",
        value = 0,
        left = gyro.left,
        right = gyro.right,
        target_roll = 0,
        current_roll = gyro.roll, -- derived from (right - left)
        target_coords = target
    }

    return pitch_cmd, roll_cmd
end

---Processes an incoming network message and executes telemetry update & guidance step
---@param sender_id number
---@param message any
---@param protocol? string
---@return boolean handled
function missile_guidance.process_message(sender_id, message, protocol)
    local cfg = missile_guidance.config
    local payload = parse_payload(message)
    if not payload then
        return false
    end

    local handled = false

    -- Detect if from Gyro computer or has gyro payload
    if (cfg.gyro_id and sender_id == cfg.gyro_id) or payload.left ~= nil or payload.top ~= nil or payload.type == "gyro" then
        missile_guidance.process_gyro_telemetry(payload)
        handled = true
    end

    -- Detect if from Missile computer or has position payload
    if (cfg.missile_id and sender_id == cfg.missile_id) or payload.x ~= nil or payload.type == "missile" then
        missile_guidance.process_missile_telemetry(payload)
        handled = true
    end

    -- If telemetry was updated, perform guidance calculation and dispatch steering commands
    if handled and missile_guidance.active then
        local pitch_cmd, roll_cmd = missile_guidance.calculate_guidance_commands(missile_guidance.telemetry, cfg.target)

        if pitch_cmd and cfg.pitch_id then
            missile_guidance.send_pitch_command(cfg.pitch_id, pitch_cmd)
        end

        if roll_cmd and cfg.roll_id then
            missile_guidance.send_roll_command(cfg.roll_id, roll_cmd)
        end

        if cfg.on_telemetry then
            cfg.on_telemetry(missile_guidance.telemetry)
        end
    end

    return handled
end

---Main guidance receiver and control loop
---Runs asynchronously inside Basalt's event loop or as a standalone coroutine
local function guidance_event_loop()
    print("[GUIDANCE] Guidance event loop started.")
    local cfg = missile_guidance.config

    if cfg.on_status then
        cfg.on_status("GUIDANCE ACTIVE")
    end

    -- Start periodic heartbeat timer
    local heartbeat_timer = os.startTimer(0.1)

    while missile_guidance.active do
        -- Check if missile has not sent position for > 10 seconds
        local now = (os.clock and os.clock()) or 0
        if now - missile_guidance.last_missile_telemetry_time > missile_guidance.timeout_seconds then
            print("[GUIDANCE ERROR] Missile position timeout (>10s). Assuming missile disconnected.")
            missile_guidance.missile_connected = false
            missile_guidance.active = false
            if cfg.on_status then
                cfg.on_status("MISSILE DISCONNECTED")
            end
            break
        end

        local event, p1, p2, p3 = os.pullEvent()

        if event == "rednet_message" then
            local sender_id, message, protocol = p1, p2, p3
            -- Accept messages matching our protocol, or from registered computers
            if not protocol or protocol == missile_guidance.protocol or sender_id == cfg.gyro_id or sender_id == cfg.missile_id then
                missile_guidance.process_message(sender_id, message, protocol)
            end
        elseif event == "timer" and p1 == heartbeat_timer then
            if missile_guidance.active then
                -- Periodic guidance dispatch / telemetry check
                heartbeat_timer = os.startTimer(0.1)
            end
        end
    end

    print("[GUIDANCE] Guidance event loop terminated.")
    if cfg.on_status and missile_guidance.missile_connected then
        cfg.on_status("GUIDANCE STOPPED")
    end
end

---Starts missile launch and initiates telemetry pulling & guidance command loop.
---Can be called with a config table:
---  Launch_missile({ target = coords, gyro_id = id, pitch_id = id, roll_id = id, missile_id = id, on_telemetry = fn, on_status = fn })
---Or with positional arguments:
---  Launch_missile(target, gyro_id, pitch_id, roll_id, missile_id, on_telemetry, on_status)
---@param opt_or_target table|any Configuration table or Target coordinates {x, y, z}
---@param gyro_id? number Gyro computer Rednet ID
---@param pitch_id? number Pitch computer Rednet ID
---@param roll_id? number Roll computer Rednet ID
---@param missile_id? number Missile computer Rednet ID
---@param on_telemetry? fun(telemetry: table) Callback on telemetry update
---@param on_status? fun(status: string) Callback on status change
---@return boolean success
function missile_guidance.Launch_missile(opt_or_target, gyro_id, pitch_id, roll_id, missile_id, on_telemetry, on_status)
    local cfg = missile_guidance.config

    if type(opt_or_target) == "table" and (opt_or_target.target ~= nil or opt_or_target.gyro_id ~= nil) then
        -- Options table passed
        cfg.target = opt_or_target.target or TARGET_COORDINATES
        cfg.gyro_id = opt_or_target.gyro_id or GYRO
        cfg.pitch_id = opt_or_target.pitch_id or PITCH
        cfg.roll_id = opt_or_target.roll_id or ROLL
        cfg.missile_id = opt_or_target.missile_id or MISSILE
        cfg.on_telemetry = opt_or_target.on_telemetry
        cfg.on_status = opt_or_target.on_status
    else
        -- Positional arguments or fallback to globals
        cfg.target = opt_or_target or TARGET_COORDINATES
        cfg.gyro_id = gyro_id or GYRO
        cfg.pitch_id = pitch_id or PITCH
        cfg.roll_id = roll_id or ROLL
        cfg.missile_id = missile_id or MISSILE
        cfg.on_telemetry = on_telemetry
        cfg.on_status = on_status
    end

    if not cfg.target then
        print("[GUIDANCE ERROR] Launch aborted: Target coordinates not set.")
        return false
    end

    missile_guidance.active = true
    missile_guidance.missile_connected = true
    missile_guidance.last_missile_telemetry_time = (os.clock and os.clock()) or 0

    print(string.format("[GUIDANCE] Initiating launch to target (X: %d, Y: %d, Z: %d)", cfg.target.x, cfg.target.y, cfg.target.z))
    print(string.format("[GUIDANCE] Telemetry targets - Gyro ID: %s, Pitch ID: %s, Roll ID: %s, Missile ID: %s",
        tostring(cfg.gyro_id), tostring(cfg.pitch_id), tostring(cfg.roll_id), tostring(cfg.missile_id)))

    -- Schedule in Basalt event loop if Basalt is loaded
    local basalt_loaded, basalt = pcall(require, "basalt")
    if basalt_loaded and basalt and type(basalt.schedule) == "function" then
        basalt.schedule(guidance_event_loop)
    else
        -- If running outside Basalt (e.g. CLI or test), run in coroutine or directly
        local co = coroutine.create(guidance_event_loop)
        coroutine.resume(co)
    end

    return true
end

---Stops the guidance and telemetry loop
function missile_guidance.Stop_missile()
    missile_guidance.active = false
    print("[GUIDANCE] Stop command issued.")
end

-- Export function globally for compatibility
Launch_missile = missile_guidance.Launch_missile
Stop_missile = missile_guidance.Stop_missile

return missile_guidance
