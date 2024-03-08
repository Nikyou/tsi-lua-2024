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