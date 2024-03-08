--[[
-- Box-Muller transform
function NormalR(mean, std)
    mean = mean or 0
    std = std or 1
    local u1 = math.random()
    local u2 = math.random()
    local z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return z * std + mean
end
-- Ziggurat Algorithm
function NormalRZ(mean, std)
    local x, y
    local r = 0
    repeat
        x = 2 * math.random() - 1
        y = 2 * math.random() - 1
        r = x * x + y * y
    until r < 1 and r ~= 0

    local z = math.sqrt(-2 * math.log(r) / r)
    return z * x * std + mean
end
-- Ratio-of-Uniforms
function NormalRR(mean, std)
    local u1, u2, v1, v2, s
    repeat
        u1 = math.random()
        u2 = math.random() * 2.5066282746310007 -- Maximum value of PDF of standard normal distribution
        v1 = 2 * u1 - 1
        v2 = 2 * u2 - 1
        s = v1 * v1 + v2 * v2
    until s < 1 and s > 0
    local z = math.sqrt(-2 * math.log(s) / s)
    return z * v1 * std + mean
end
function NormalRR2(mean, std)
    local u1 = 1.0 - math.random()
    local u2 = 1.0 - math.random()
    local r = math.sqrt(-2.0 * math.log(u1))
    local theta = 2.0 * math.pi * u2
    local z = r * math.sin(theta)
    return z * std + mean
end

--Marsaglia polar method
function NormalRM(mean, std)
    local u1, u2, w
    repeat
        u1 = 2 * math.random() - 1
        u2 = 2 * math.random() - 1
        w = u1 * u1 + u2 * u2
    until w < 1 and w > 0
    local mult = math.sqrt(-2 * math.log(w) / w)
    local z1 = u1 * mult
    return z1 * std + mean
end
]]
math.randomseed(78436)


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

--Exponential
function ExpoR(lambda)
    lambda = lambda or 1
    return -math.log(1 - math.random()) / lambda
end


local str = ""
local str = math.floor((NormalR(2, 0.3)+0.005)*100)/100
--local str = ExpoR(1.5)
for i = 1, 1000-1 do
    --str = str .. ' ' .. NormalRR3(2, 0.3)
    str = str .. '\n' .. math.floor((NormalR(2, 0.3)+0.005)*100)/100
    --str = str .. '\n' .. ExpoR(1.5)
end

local file = io.open("output.txt", "w")
if file then
    file:write(str)
    file:close()
end
