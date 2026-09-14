local missileLogic = {}

---Simulates connecting to the missile silo / missile hardware.
---@return boolean success
function missileLogic.Connect()
    return true
end

-- Also define global for backward compatibility
Connect = missileLogic.Connect

return missileLogic
