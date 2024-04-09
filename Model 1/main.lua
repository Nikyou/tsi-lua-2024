math.randomseed(78436)
Stop_time = 500

-- 2, 0.3; 2.5, 0.5
-- Ratio-of-Uniforms
MAGICCONST = 4 * math.exp(-0.5) / math.sqrt(2)
function NormalR(mean, std)
    mean = mean or 0
    std = std or 1
    local u1, u2, z, zz
    repeat
        u1 = math.random()
        u2 = 1 - math.random()
        z = MAGICCONST * (u1 - 0.5) / u2
        zz = z * z / 4
    until zz <= -math.log(u2)
    return mean + z * std
end

--1.5; 4
--Exponential
function ExpoR(lambda)
    lambda = lambda or 1
    return -math.log(1 - math.random()) / lambda
end

--Rounding shortcut to 0.01
function Round(number)
    return math.floor((number+0.005)*100)/100
end

--random functions predefined for two processes
function I1random()
    return Round(ExpoR(1.5))
end
function I2random()
    return Round(ExpoR(4))
end
function P1random()
    return Round(NormalR(2, 0.3))
end
function P2random()
    return Round(NormalR(2.5, 0.5))
end

--Function to create csv file headers and initialize global variable
function Create_table()
    Table = "Event; Time; Job 1; Job 2; Stop time; Status; Queue length; Queue" .. "\n"
end

--Function to parse queue to string
function Parse_queue(queue)
    local limit = 10
    local result = ""
    if #queue == 0 then
        result = "nil"
    else
        for v,k in ipairs(queue) do
            if v > limit then
                result = result .. ", ..."
                break
            end
            if not v == 1 then result = result .. ", " end

            result = result .. k.event
        end
    end

    return result
end

--Function to add a row to the table in csv format
function Add_table_row(row)
    local queue = Parse_queue(Queue:getQueue())
    Table = Table .. row.event .. "; " .. row.time .. "; " .. row.j1 .. "; " .. row.j2 .. "; " .. row.st .. "; " .. Queue:length() .. "; " .. queue .. "\n"
end

--Initialize queue object (OOP approach)
Queue = {}
Queue.q = {}

function Queue:getQueue()
    return self.q
end
function Queue:length()
    return #self.q
end
--Realisation of Queue.add()
function Queue:add(event)
    table.insert(self.q, event)
end
--Realisation of Queue.get() FIFO
function Queue:get()
    return table.remove(self.q, 1)
end