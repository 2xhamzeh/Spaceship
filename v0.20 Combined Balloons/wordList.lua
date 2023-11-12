local wordList = {
    'das buch',
    'der stift',
    'der radiergummi',
    'der anspitzer',
    'die federtasche'
}

local function getRandomWord()
    return(wordList[math.random(#wordList)])
end

local function setWordToWrong(word)
    local b = word
    if string.sub(b, 1, 3) == "der" then
        local a = math.random(1,2)
        if a == 1 then
            b = "die"..string.sub(b, 4, -1)
        elseif a == 2 then
            b = "das"..string.sub(b, 4, -1)
        end
    elseif string.sub(b, 1, 3) == "die" then
        local a = math.random(1,2)
        if a == 1 then
            b = "der"..string.sub(b, 4, -1)
        elseif a == 2 then
            b = "das"..string.sub(b, 4, -1)
        end
    elseif string.sub(b, 1, 3) == "das" then
        local a = math.random(1,2)
        if a == 1 then
            b = "der"..string.sub(b, 4, -1)
        elseif a == 2 then
            b = "die"..string.sub(b, 4, -1)
        end
    end
    return b
end

function getPair()
    local i = getRandomWord()
    local j = setWordToWrong(i)
    local pair = {i, j}
    return pair
end


function printDetails()
    local pair = getPair()
    print(pair[1])
    print(pair[2])
end



