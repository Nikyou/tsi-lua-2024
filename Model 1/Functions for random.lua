math.randomseed(78436)
Precision = 2
--File name for output
File_name1 = "output.txt"
File_name2 = "outputE.txt"

--Rounding shortcut to 0.01
function Round(number)
    return math.floor((number+5/(math.pow(10,Precision + 1)))*math.pow(10,Precision))/math.pow(10,Precision)
end

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


local str
str = Round(NormalR(2, 0.3))
for i = 1, 1000-1 do
    str = str .. '\n' .. Round(NormalR(2, 0.3))
end

local file = io.open(File_name1, "w")
if file then
    file:write(str)
    file:close()
end


str = Round(ExpoR(1.5))
for i = 1, 1000-1 do
    str = str .. '\n' .. Round(ExpoR(1.5))
end

file = io.open(File_name2, "w")
if file then
    file:write(str)
    file:close()
end
