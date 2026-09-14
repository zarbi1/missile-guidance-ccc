local basalt = require("basalt")

local launch_proc = {}

---Global variable holding the locked coordinates
TARGET_COORDINATES = TARGET_COORDINATES or nil

---Launches the interactive target coordinate input dialog.
---@param parentFrame? table The parent Basalt frame (defaults to basalt.getMainFrame())
---@param onLocked? fun(coords: table) Callback when coordinates are locked
function launch_proc.Start_procedure(parentFrame, onLocked)
    parentFrame = parentFrame or basalt.getMainFrame()
    if not parentFrame then
        print("[ERROR] No Basalt frame available to display coordinate dialog.")
        return
    end

    local fWidth, fHeight = parentFrame:getSize()
    local dialogWidth = 32
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
    dialog:addLabel({
        x = 1,
        y = 1,
        width = dialogWidth,
        height = 1,
        text = "  TARGET COORDINATES  ",
        background = colors.red,
        foreground = colors.white
    })

    -- Coordinate Inputs
    dialog:addLabel({ x = 3, y = 3, text = "Target X:", foreground = colors.white })
    local inputX = dialog:addInput({
        x = 13,
        y = 3,
        width = 16,
        text = initX,
        placeholder = "e.g. 100",
        background = colors.black,
        foreground = colors.lime
    })

    dialog:addLabel({ x = 3, y = 5, text = "Target Y:", foreground = colors.white })
    local inputY = dialog:addInput({
        x = 13,
        y = 5,
        width = 16,
        text = initY,
        placeholder = "e.g. 64",
        background = colors.black,
        foreground = colors.lime
    })

    dialog:addLabel({ x = 3, y = 7, text = "Target Z:", foreground = colors.white })
    local inputZ = dialog:addInput({
        x = 13,
        y = 7,
        width = 16,
        text = initZ,
        placeholder = "e.g. -250",
        background = colors.black,
        foreground = colors.lime
    })

    -- Validation / Status message label
    local msgLabel = dialog:addLabel({
        x = 2,
        y = 9,
        width = dialogWidth - 2,
        text = "Enter X, Y, Z coordinates",
        foreground = colors.lightGray
    })

    local function submitCoordinates()
        local xVal = tonumber(inputX.text or "")
        local yVal = tonumber(inputY.text or "")
        local zVal = tonumber(inputZ.text or "")

        if not xVal or not yVal or not zVal then
            msgLabel.text = "Error: Invalid numbers!"
            msgLabel.foreground = colors.yellow
            return
        end

        -- Store coordinates in global variable
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

    -- SEND Button
    local sendBtn = dialog:addButton({
        x = 3,
        y = 11,
        width = 11,
        height = 1,
        text = "  SEND  ",
        background = colors.green,
        foreground = colors.white
    })
    sendBtn:onClick(function()
        submitCoordinates()
    end)

    -- CANCEL Button
    local cancelBtn = dialog:addButton({
        x = 18,
        y = 11,
        width = 11,
        height = 1,
        text = " CANCEL ",
        background = colors.red,
        foreground = colors.white
    })
    cancelBtn:onClick(function()
        dialog:destroy()
    end)

    -- Allow Enter key in inputs to jump or submit
    inputX:onEnter(function() inputY:focus() end)
    inputY:onEnter(function() inputZ:focus() end)
    inputZ:onEnter(function() submitCoordinates() end)

    inputX:focus()
    return dialog
end

-- Export function globally for compatibility
Start_procedure = launch_proc.Start_procedure

return launch_proc
