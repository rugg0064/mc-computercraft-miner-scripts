function newTreeNode()
    node = {}
    node.parent = nil
    node[0] = nil
    node[1] = nil
    node[2] = nil
    node[3] = nil
    node[4] = nil
    node[5] = nil
end

function newRegistryNode()
    nn = {}
    nn.block = nil
    return nn
end

function registryGetEntry(registry, x, y, z)
    xTable = registry[x]
    if xTable ~= nil then
        yTable = xTable[y]
        if yTable ~= nil then
            zValue = yTable[z]
            return zValue
        end
    end
    return nil
end

function registryGetOrMakeNew(registry, x, y, z)
    xTable = registry[x]
    if xTable == nil then
        registry[x] = {}
        xTable = registry[x]
    end

    yTable = xTable[y]
    if yTable == nil then
        registry[y] = {}
        yTable = registry[y]
    end

    zValue = yTable[z]
    if zValue == nil then
        zValue = newRegistryNode()
    end

    return zValue
end

--Bunch of helper functions to keep track of where turtle is
gpsMovement = {}
gpsMovement.jumps = {"x", "y"}
gpsMovement.inverseJumps = {"y","x"}
gpsMovement.signs = {1,-1}
gpsMovement.inverseSigns = {-1,1}
gpsMovement.forward = function(gps)
    if turtle.forward() then
        gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] = gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] + gpsMovement.signs[math.floor(gps.orientation / 2) + 1]
    end
end
gpsMovement.back = function(gps)
    if turtle.back() then
        gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] = gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] + gpsMovement.inverseSigns[(gps.orientation / 2) + 1]
    end
end
gpsMovement.turnRight = function(gps)
    if turtle.turnRight() then
        gps.orientation = gps.orientation + 1
        if gps.orientation == 4 then
            gps.orientation = 0
        end
    end
end
gpsMovement.turnLeft = function(gps)
    if turtle.turnRight() then
        gps.orientation = gps.orientation - 1
        if gps.orientation == -1 then
            gps.orientation = 3
        end
    end
end
gpsMovement.up = function(gps)
    if turtle.up() then
        gps.z = gps.z + 1
    end
end
gpsMovement.down = function(gps)
    if turtle.down() then
        gps.z = gps.z - 1
    end
end
gpsMovement.getForwardPos = function(gps)
    position = {}
    position.x = gps.x
    position.y = gps.y
    position.z = gps.z

    position[gpsMovement.jumps[(gps.orientation % 2) + 1]] = gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] + gpsMovement.signs[math.floor(gps.orientation / 2) + 1]
    return position
end
gpsMovement.getBackPos = function(gps)
    position = {}
    position.x = gps.x
    position.y = gps.y
    position.z = gps.z

    position[gpsMovement.jumps[(gps.orientation % 2) + 1]] = gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] + gpsMovement.inverseSigns[math.floor(gps.orientation / 2) + 1]
    return position
end
gpsMovement.getUpPos = function(gps)
    position = {}
    position.x = gps.x
    position.y = gps.y
    position.z = gps.z + 1
    return position
end
gpsMovement.getDownPos = function(gps)
    position = {}
    position.x = gps.x
    position.y = gps.y
    position.z = gps.z - 1
    return position
end
gpsMovement.getRightPos = function(gps)
    position = {}
    position.x = gps.x
    position.y = gps.y
    position.z = gps.z

    position[gpsMovement.inverseJumps[(gps.orientation % 2) + 1]] = gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] + gpsMovement.signs[math.floor(gps.orientation / 2) + 1]
    return position
end
gpsMovement.getLeftPos = function(gps)
    position = {}
    position.x = gps.x
    position.y = gps.y
    position.z = gps.z

    position[gpsMovement.inverseJumps[(gps.orientation % 2) + 1]] = gps[gpsMovement.jumps[(gps.orientation % 2) + 1]] + gpsMovement.inverseSigns[math.floor(gps.orientation / 2) + 1]
    return position
end

function getOres()
    inspections = {}
    --Contains a list of inspection results, Forward 
    inspections[0] = {}
    inspections[1] = {}
    inspections[2] = {}
    inspections[3] = {}
    inspections[4] = {}
    inspections[5] = {}
    inspections[0][0], inspections[0][1] = turtle.inspect()
    turtle.turnRight()
    inspections[1][0], inspections[1][1] = turtle.inspect()
    turtle.turnRight()
    inspections[2][0], inspections[2][1] = turtle.inspect()
    turtle.turnRight()
    inspections[3][0], inspections[3][1] = turtle.inspect()
    turtle.turnRight()
    inspections[4][0], inspections[4][1] = turtle.inspectUp()
    inspections[5][0], inspections[5][1] = turtle.inspectDown()
    return inspections
end

function digOresHelper(backtrack)
    print("entering recursive loop")
    inspections = getOres()
    firstOre = -1
    for k=0,5,1 do
        if(inspections[k][0]) then
            if(string.find(inspections[k][1].name, "ore")) then
                firstOre = k
                break
            end
        end
    end
    print("firstOre at " .. firstOre)
    if firstOre ~= -1 then
        if firstOre == 4 then
            turtle.digUp()
            turtle.up()
            backtrack[backtrack.n] = turtle.down
            backtrack.n = backtrack.n + 1
        elseif firstOre == 5 then
            turtle.digDown()
            turtle.down()
            backtrack[backtrack.n] = turtle.up
            backtrack.n = backtrack.n + 1
        else
            for k=0,firstOre - 1,1 do
                print("turnRight")
                turtle.turnRight()
                backtrack[backtrack.n] = turtle.turnLeft
                backtrack.n = backtrack.n + 1
            end
            turtle.dig()
            turtle.forward()
            backtrack[backtrack.n] = turtle.back
            backtrack.n = backtrack.n + 1
        end
        digOresHelper(backtrack)
    else 
        if backtrack.n == 0 then
            return
        else
            backtrack[backtrack.n-1]()
            backtrack.n = backtrack.n - 1
            digOresHelper(backtrack)
        end
    end

end

function digOres()
    blockRegistry = {}
    registryGetOrMakeNew(blockRegistry, 0, 0, 0)
    oreRoot = newTreeNode()

    gps = {}
    gps.orientation = 0
    gps.x = 0
    gps.y = 0
    gps.z = 0

    --blockData = getOres()
    --backtrack = {}
    --backtrack.n = 0
    --digOresHelper(backtrack)
end


--[while true do
--    digOres()
--    turtle.dig()
--    turtle.forward()
--end

digOres()