print("Starting Detecting hardware")
local rednet_protocol_name = "missile_command_center"
local rednet_gyro_name = "gyro"
local rednet_pitch_name = "pitch"
local rednet_roll_name = "roll"

local modem = peripheral.find("modem", rednet.open)

if not rednet.isOpen() then
    print("Please attach a modem. Starting aborted")
    return
end

rednet.host("missile_command_center", "orchestrator")
print("Starting computer reco...")

-- We have a very simple principle, all computers should be online only if they are in a ready state.
print("Searching for Gyro telemetry computer...")
GYRO = rednet.lookup(rednet_protocol_name, rednet_gyro_name)
if not GYRO then
    print("Could not detect the gyro computer on the network, please activate it.")
    return
end

print("Gyro telemetry detected, proceding to detect Pitch telemetry computer...")

PITCH = rednet.lookup(rednet_protocol_name, rednet_pitch_name)
if not PITCH then
    print("Could not detect the pitch computer on the network, please activate it.")
    return
end

print("Pitch telemetry detected, proceding to detect Roll telemetry computer...")


ROLL = rednet.lookup(rednet_protocol_name, rednet_roll_name)
if not ROLL then
    print("Could not detect the roll computer on the network, please activate it.")
    return
end

print("Roll telemetry detected, now detecting monitor...")


MONITOR = peripheral.find("monitor")

if not MONITOR then
    print("Could not detect monitor, please connect one, the interface is designed to work on a 5x3 setup.")
    return
end

print("monitor detected. All systems online.")

print("Starting UI...")
