local missileLogic = {}

local protocol_name = "missile_command_center"
local missile_host_name = "missile"

---Attempts to find and connect to the onboard missile computer over rednet.
---@return boolean success, any id_or_err
function missileLogic.Connect()
    if not rednet or not rednet.isOpen() then
        return false, "Rednet not open"
    end

    local id = rednet.lookup(protocol_name, missile_host_name)
    if id then
        MISSILE = id
        return true, id
    end

    MISSILE = nil
    return false, "Missile computer not detected"
end

-- Also define global for backward compatibility
Connect = missileLogic.Connect

return missileLogic
