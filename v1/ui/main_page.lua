local basalt = require("basalt")
local launch_proc = require("launch_procedure")
local missileLogic = require("logic.missile_connector")
local missile_guidance = require("logic.missile_guidance")

local main_page = {}

---Launches the main interactive UI for the missile silo command center.
---@param monitor? table|MonitorPeripheral
---@param pitch_telemetry? any
---@param roll_telemetry? any
---@param gyro_telemetry? any
---@param missile_telemetry? any
function main_page.Launch_main_ui(monitor, pitch_telemetry, roll_telemetry, gyro_telemetry, missile_telemetry)
    local mainFrame = basalt.createFrame(monitor)
    mainFrame:setBackground(colors.black)
    mainFrame:setForeground(colors.white)

    local fWidth = mainFrame:getWidth()

    -- Title Header Banner
    mainFrame:addLabel({
        x = 1,
        y = 1,
        width = fWidth,
        height = 1,
        text = " [!] MISSILE SILO COMMAND CENTER ",
        background = colors.red,
        foreground = colors.white
    })

    -- Hardware & Connection status
    local missile = missileLogic.Connect()
    local isConnected = (missile == true)
    local missileStatusText = isConnected and "Connected" or "NOT CONNECTED"
    local missileStatusColor = isConnected and colors.lime or colors.red

    mainFrame:addLabel({
        x = 2,
        y = 3,
        text = "Missile Status: ",
        foreground = colors.white
    })
    local missileStatusVal = mainFrame:addLabel({
        x = 18,
        y = 3,
        text = missileStatusText,
        foreground = missileStatusColor
    })

    -- Procedure / Operation status
    mainFrame:addLabel({
        x = 2,
        y = 4,
        text = "System Status: ",
        foreground = colors.white
    })
    local systemStatusVal = mainFrame:addLabel({
        x = 18,
        y = 4,
        text = isConnected and "Standby" or "Offline",
        foreground = colors.yellow
    })

    -- Target coordinates display label
    local coordsLabel = mainFrame:addLabel({
        x = 2,
        y = 6,
        text = "Target Coords:  [ NOT CONFIGURED ]",
        foreground = colors.lightGray
    })

    -- Button references
    local btnStart = nil
    local btnLaunch = nil
    local btnReconf = nil
    local btnRefresh = nil

    -- Connection update handler
    local function onConnectionChanged(connected)
        if connected then
            missileStatusVal.text = "Connected"
            missileStatusVal.foreground = colors.lime
            if systemStatusVal.text == "Offline" then
                systemStatusVal.text = "Standby"
                systemStatusVal.foreground = colors.yellow
            end
            if btnRefresh then btnRefresh:setVisible(false) end
        else
            missileStatusVal.text = "NOT CONNECTED"
            missileStatusVal.foreground = colors.red
            if btnRefresh then btnRefresh:setVisible(true) end
        end
    end

    -- Callback when coordinates are locked
    local function onCoordinatesLocked(coords)
        systemStatusVal.text = "Coordinate locked"
        systemStatusVal.foreground = colors.lime
        coordsLabel.text = string.format("Target Coords:  X: %d  Y: %d  Z: %d", coords.x, coords.y, coords.z)
        coordsLabel.foreground = colors.yellow

        if btnStart then btnStart:setVisible(false) end
        if btnRefresh then btnRefresh:setVisible(false) end
        if btnLaunch then btnLaunch:setVisible(true) end
        if btnReconf then btnReconf:setVisible(true) end
    end

    -- Start Procedure Button (always available to initiate procedure)
    btnStart = mainFrame:addButton({
        x = 2,
        y = 8,
        width = 19,
        height = 1,
        text = " Start Procedure ",
        background = colors.blue,
        foreground = colors.white
    }):onClick(function()
        systemStatusVal.text = "Configuring..."
        systemStatusVal.foreground = colors.cyan
        launch_proc.Start_procedure(mainFrame, onCoordinatesLocked, onConnectionChanged)
    end)

    -- Refresh Connection button (visible when missile is not yet detected)
    btnRefresh = mainFrame:addButton({
        x = 22,
        y = 8,
        width = 16,
        height = 1,
        text = " Refresh Conn ",
        background = colors.gray,
        foreground = colors.yellow,
        visible = not isConnected
    }):onClick(function()
        local success = missileLogic.Connect()
        onConnectionChanged(success == true)
    end)

    -- LAUNCH Button (displayed after coordinates locked)
    btnLaunch = mainFrame:addButton({
        x = 2,
        y = 8,
        width = 14,
        height = 1,
        text = "  [ LAUNCH ]  ",
        background = colors.red,
        foreground = colors.white,
        visible = false
    }):onClick(function()
        if not TARGET_COORDINATES then
            print("[ERROR] Cannot launch: No target coordinates locked!")
            return
        end

        -- Console output for launch
        print("==================================================")
        print("[SILO CONTROLLER] >>> LAUNCH SEQUENCE ACTIVATED <<<")
        print(string.format("[SILO CONTROLLER] TARGET LOCKED AT X: %d, Y: %d, Z: %d", TARGET_COORDINATES.x, TARGET_COORDINATES.y, TARGET_COORDINATES.z))
        print("[SILO CONTROLLER] SILO DOORS OPENING...")
        print("[SILO CONTROLLER] IGNITION CONFIRMED. MISSILE LAUNCHED!")
        print("==================================================")

        systemStatusVal.text = "MISSILE LAUNCHED!"
        systemStatusVal.foreground = colors.red

        if btnLaunch then btnLaunch:setVisible(false) end
        if btnReconf then btnReconf:setVisible(false) end

        -- Start missile guidance and telemetry pulling
        missile_guidance.Launch_missile({
            target = TARGET_COORDINATES,
            gyro_id = gyro_telemetry or GYRO,
            pitch_id = pitch_telemetry or PITCH,
            roll_id = roll_telemetry or ROLL,
            missile_id = missile_telemetry or MISSILE,
            on_telemetry = function(telemetry)
                systemStatusVal.text = "GUIDING TO TARGET"
                systemStatusVal.foreground = colors.yellow
            end,
            on_status = function(status)
                systemStatusVal.text = status
                systemStatusVal.foreground = colors.yellow
            end
        })
    end)

    -- Re-Configure Button (displayed after coordinates locked)
    btnReconf = mainFrame:addButton({
        x = 18,
        y = 8,
        width = 16,
        height = 1,
        text = " Re-Configure ",
        background = colors.gray,
        foreground = colors.yellow,
        visible = false
    }):onClick(function()
        systemStatusVal.text = "Re-Configuring..."
        systemStatusVal.foreground = colors.cyan
        launch_proc.Start_procedure(mainFrame, onCoordinatesLocked, onConnectionChanged)
    end)

    basalt.run()
end

-- Export globally for backward compatibility
Launch_main_ui = main_page.Launch_main_ui

return main_page
