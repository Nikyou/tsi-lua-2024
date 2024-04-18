math.randomseed(78436)
Stop_time = 500
Precision = 2
--File name for output table
File_name = "tableOutput" .. "" .. ".csv"

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
    return math.floor((number+5/(math.pow(10,Precision + 1)))*math.pow(10,Precision))/math.pow(10,Precision)
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
    Table = "Event;Time;Job 1;Job 2;Stop time;Status;Queue length;Queue;MoE1;MoE2" .. "\n"
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
            if v > 1 then result = result .. ", " end

            result = result .. k.name
        end
    end

    return result
end

--Function to add a row to the table in csv format
function Add_table_row(sim)
    local queue = Parse_queue(sim.queue:getQueue())
    Table = Table .. sim.event .. ";" .. sim.time .. ";" .. sim.j1.time .. ";" .. sim.j2.time .. ";" .. sim.st .. ";" .. sim.status .. ";" .. sim.queue:length() .. ";" .. queue .. ";" .. MoE1:getValue(sim.time) .. ";" .. MoE2:getValue() .. "\n"
end

--Initialize queue object (OOP approach)
Queue = {
    q = {}
}

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

--Initialize global table
Simulation = {
    event = "Start",
    time = 0,
    j1 = {
        process = {
            name = "J1",
            p_time = P1random,
        },
        random = I1random,
        time = I1random(),
    },
    j2 = {
        process = {
            name = "J2",
            p_time = P2random,
        },
        random = I2random,
        time = I2random(),
    },
    st = Stop_time+1,
    status = 0,
    queue = Queue,
}

--Job 1 or Job 2 has arrived
function Job_arrival(job)
    Simulation.time = Simulation[job].time
    Simulation[job].time = Simulation.time + Simulation[job].random()

    if Simulation.status == 0 then
        Simulation.status = 1
        Simulation.event = Simulation[job].process.name
        Simulation.st = Simulation.time + Simulation[job].process.p_time()
    else
        Simulation.queue:add(Simulation[job].process)
    end
end

--Stop time has arrived
function St_arrival()
    Simulation.time = Simulation.st

    if Simulation.queue:length() == 0 then
        Simulation.st = Stop_time+1
        Simulation.event = "Waiting"
        Simulation.status = 0
    else
        Simulation.status = 1
        local process = Simulation.queue:get()
        Simulation.event = process.name
        Simulation.st = Simulation.time + process.p_time()
    end
end

--MoEs as object
MoE1 = {
    last_time = nil,
    time_sum = 0,
}
MoE2 = {
    value = 0
}
--Downtime factor
function MoE1:update(sim)
    if self.last_time ~= nil then
        self.time_sum = self.time_sum + (sim.time - self.last_time)
    end
    if sim.status == 1 then
        self.last_time = sim.time
    else
        self.last_time = nil
    end
end
function MoE1:getValue(time)
    time = time or Stop_time
    if time == 0 then time = 0.000001 end
    return 1 - Round(self.time_sum / time)
end
--Maximum of all jobs in queue
function MoE2:update(sim)
    if sim.queue:length() > self.value then
        self.value = sim.queue:length()
    end
end
function MoE2:getValue()
    return self.value
end

--Start of simulation
Create_table()
while Simulation.time < Stop_time do
    MoE1:update(Simulation)
    MoE2:update(Simulation)
    Add_table_row(Simulation)
    local closestEvent = math.min(Simulation.j1.time, Simulation.j2.time, Simulation.st)
    if closestEvent > Stop_time then break end --Safeguard to prevent an event slip-up
    if closestEvent == Simulation.j1.time then
        Job_arrival("j1")
    elseif closestEvent == Simulation.j2.time then
        Job_arrival("j2")
    elseif closestEvent == Simulation.st then
        St_arrival()
    end
end

--End of simulation
Simulation.time = Stop_time
Simulation.event = "Stop"
Add_table_row(Simulation)

local file = io.open(File_name, "w")
if file then
    file:write(Table)
    file:close()
end