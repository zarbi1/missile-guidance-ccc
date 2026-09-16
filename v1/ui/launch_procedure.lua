local basalt = require("basalt")
local missileLogic = require("logic.missile_connector")

local launch_proc = {}

---Global variable holding the locked coordinates
TARGET_COORDINATES = TARGET_COORDINATES or nil

---Launches the interactive target coordinate input dialog.
---Checks missile connection first; if disconnected, prompts user to refresh connection before inputting coords.
---@param parentFrame? table The parent Basalt frame (defaults to basalt.getMainFrame())
---@param onLocked? fun(coords: table) Callback when coordinates are locked
---@param onConnectionChanged? fun(connected: boolean) Callback when missile connection state updates
function launch_proc.Start_procedure(parentFrame, onLocked, onConnectionChanged)
    parentFrame = parentFrame or basalt.getMainFrame()
    if not parentFrame then
        print("[ERROR] No Basalt frame available to display coordinate dialog.")
        return
    end

    local fWidth, fHeight = parentFrame:getSize()
    local dialogWidth = 34
    local dialogHeight = 12
    local dialogX = math.max(1, math.floor((fWidth - dialogWidth) / 2) + 1)
    local dialogY = math.max(1, math.floor((fHeight - dialogHeight) / 2) + 1)

    -- Pre-existing coordinates if re-configuring
    local initX = TARGET_COORDINATES and tostring(TARGET_COORDINATES.x) or ""
    local initY = TARGET_COORDINATES and tostring(TARGET_COORDINATES.y) or ""
    local initZ = TARGET_COORDINATES and tostring(TARGET_COORDINATES.z) or ""

    -- Modal overlay frame
    local dialog = parentFrame:addFrame({
        x = dialogX,
        y = dialogY,
        width = dialogWidth,
        height = dialogHeight,
        background = colors.gray,
        foreground = colors.white,
        z = 100
    })

    -- Dialog Header Bar
    local header = dialog:addLabel({
        x = 1,
        y = 1,
        width = dialogWidth,
        height = 1,
        text = "  TARGET COORDINATES  ",
        background = colors.red,
        foreground = colors.white
    })

    -- Content Subframes
    local connectionView = dialog:addFrame({
        x = 1,
        y = 2,
        width = dialogWidth,
        height = dialogHeight - 1,
        background = colors.gray,
        visible = false
    })

    local coordsView = dialog:addFrame({
        x = 1,
        y = 2,
        width = dialogWidth,
        height = dialogHeight - 1,
        background = colors.gray,
        visible = false
    })

    ---------------------------------------------------------
    -- View 1: Missile Connection Required View
    ---------------------------------------------------------
    connectionView:addLabel({
        x = 3,
        y = 2,
        text = "Missile computer not detected!",
        foreground = colors.yellow
    })
    connectionView:addLabel({
        x = 3,
        y = 4,
        text = "Please turn on missile computer",
        foreground = colors.white
    })
    connectionView:addLabel({
        x = 3,
        y = 5,
        text = "and refresh connection to proceed.",
        foreground = colors.lightGray
    })

    local connStatusLabel = connectionView:addLabel({
        x = 3,
        y = 7,
        text = "Status: Disconnected",
        foreground = colors.red
    })

    ---------------------------------------------------------
    -- View 2: Coordinate Inputs View
    ---------------------------------------------------------
    coordsView:addLabel({ x = 3, y = 2, text = "Target X:", foreground = colors.white })
    local inputX = coordsView:addInput({
        x = 13,
        y = 2,
        width = 18,
        text = initX,
        placeholder = "e.g. 100",
        background = colors.black,
        foreground = colors.lime
    })

    coordsView:addLabel({ x = 3, y = 4, text = "Target Y:", foreground = colors.white })
    local inputY = coordsView:addInput({
        x = 13,
        y = 4,
        width = 18,
        text = initY,
        placeholder = "e.g. 64",
        background = colors.black,
        foreground = colors.lime
    })

    coordsView:addLabel({ x = 3, y = 6, text = "Target Z:", foreground = colors.white })
    local inputZ = coordsView:addInput({
        x = 13,
        y = 6,
        width = 18,
        text = initZ,
        placeholder = "e.g. -250",
        background = colors.black,
        foreground = colors.lime
    })

    local coordsMsgLabel = coordsView:addLabel({
        x = 2,
        y = 8,
        width = dialogWidth - 2,
        text = "Enter X, Y, Z coordinates",
        foreground = colors.lightGray
    })

    local function switchToCoordsView()
        header.text = "  TARGET COORDINATES  "
        connectionView:setVisible(false)
        coordsView:setVisible(true)
        inputX:focus()
    end

    local function switchToConnectionView()
        header.text = "  MISSILE NOT CONNECTED  "
        connStatusLabel.text = "Status: Disconnected"
        connStatusLabel.foreground = colors.red
        coordsView:setVisible(false)
        connectionView:setVisible(true)
    end

    -- Connection view buttons
    connectionView:addButton({
        x = 3,
        y = 9,
        width = 20,
        height = 1,
        text = " Refresh Connection ",
        background = colors.blue,
        foreground = colors.white
    }):onClick(function()
        connStatusLabel.text = "Checking connection..."
        connStatusLabel.foreground = colors.cyan

        local success, id = missileLogic.Connect()
        if success then
            connStatusLabel.text = "Connected! Loading..."
            connStatusLabel.foreground = colors.lime
            if onConnectionChanged then
                onConnectionChanged(true)
            end
            switchToCoordsView()
        else
            connStatusLabel.text = "Missile not found. Retry?"
            connStatusLabel.foreground = colors.yellow
            if onConnectionChanged then
                onConnectionChanged(false)
            end
        end
    end)

    connectionView:addButton({
        x = 24,
        y = 9,
        width = 8,
        height = 1,
        text = " CANCEL ",
        background = colors.red,
        foreground = colors.white
    }):onClick(function()
        dialog:destroy()
    end)

    -- Coordinate submission
    local function submitCoordinates()
        local xVal = tonumber(inputX.text or "")
        local yVal = tonumber(inputY.text or "")
        local zVal = tonumber(inputZ.text or "")

        if not xVal or not yVal or not zVal then
            coordsMsgLabel.text = "Error: Invalid numbers!"
            coordsMsgLabel.foreground = colors.yellow
            return
        end

        TARGET_COORDINATES = {
            x = math.floor(xVal),
            y = math.floor(yVal),
            z = math.floor(zVal)
        }

        dialog:destroy()

        if onLocked then
            onLocked(TARGET_COORDINATES)
        end
    end

    -- Coords view buttons
    coordsView:addButton({
        x = 3,
        y = 10,
        width = 11,
        height = 1,
        text = "  SEND  ",
        background = colors.green,
        foreground = colors.white
    }):onClick(function()
        submitCoordinates()
    end)

    coordsView:addButton({
        x = 20,
        y = 10,
        width = 11,
        height = 1,
        text = " CANCEL ",
        background = colors.red,
        foreground = colors.white
    }):onClick(function()
        dialog:destroy()
    end)

    inputX:onEnter(function() inputY:focus() end)
    inputY:onEnter(function() inputZ:focus() end)
    inputZ:onEnter(function() submitCoordinates() end)

    -- Initial connection check
    local isConnected = missileLogic.Connect()
    if isConnected then
        if onConnectionChanged then
            onConnectionChanged(true)
        end
        switchToCoordsView()
    else
        if onConnectionChanged then
            onConnectionChanged(false)
        end
        switchToConnectionView()
    end

    return dialog
end

-- Export function globally for compatibility
Start_procedure = launch_proc.Start_procedure

return launch_proc
