-- Variables saved when the package loaded
local playerFound -- Player saved
local charFound -- Character saved

local cliCmdList = {"/me", "/getLocalPlayerName", "/clearChat"}
local chatCmdList = {
    {me = "/me", advert = "/advert"}, -- cmd who need text after the command
    {clearChat = "/clearChat"} -- command who just need the cmd to work

}

-- Define the command handlers in a table
local commandHandlers = {
    ["/me"] = function(cleanedMessage)
        -- Handle /me command
        Chat.AddMessage("<italic>" .. playerFound:GetName() .. cleanedMessage .. "</>")
    end,
    ["/advert"] = function(cleanedMessage)
        -- Handle /advert command
        Chat.AddMessage("Handling /advert command: " .. cleanedMessage)
    end,
        -- Handle /clearChat command
    ["/clearChat"] = function(cleanedMessage)
        -- Handle /clearChat command
        Chat.Clear()
    end,
}

-- Save in variable the player and character everyitme the package is reloaded
Package.Subscribe("Load", function()

    playerFound = Client.GetLocalPlayer() -- Get the player

    if (playerFound ~= nil) then

        local character = playerFound:GetControlledCharacter() -- Get the character of the player

        if (character) then

            charFound = character

        end
    end
end)


-- ==================== Chat commands ====================


-- /me in the chat command recognition
Chat.Subscribe("PlayerSubmit", function (message)

    -- Remove leading spaces before the first word
    local trimmedMessage = message:gsub("^%s*(.*)", "%1")
    -- Extract the first word from the message (to check if it is a command)
    local firstWord = trimmedMessage:match("(%S+)")

    -- Check if the first word of the sentence is a '/'
    if firstWord:match('%/') then

        -- Iterate over a sub table of precise command
        for _, chatCmdPair in ipairs(chatCmdList) do

            print("Parcours de la liste chatCmdList : " .. chatCmdPair)

            for _, cmd in pairs(chatCmdPair) do
                
            if firstWord == cmd then -- if message contain '/' and a 'cmdCommand'

                -- Returning false
                return RunCmd(message, firstWord)

            else

                -- If firstWord not equal to a command in the list
                Chat.AddMessage("<red>[ERROR : ".. firstWord .. "] Command not found !</>")
                error("Command ".. firstWord .. " not found", 1)

            end
        end
    end

    else
    -- If not a command in the list
    return true
    
    end
end)

-- Function that execute what the command should do
function RunCmd(message, cmdName)
    
    -- Removing the command typed before the actual text
    local cleanedMessage = string.gsub(message, cmdName, "")

    if cmdName == "/me" or cmdName == "/advert" and cleanedMessage == cmdName then

        Chat.AddMessage("<red>[ERROR : " .. cmdName .. " ] You need to enter a word / sentence</>")
        return false

    else if cmdName == 

    Chat.AddMessage("<italic>" .. playerFound:GetName() .. cleanedMessage .. "</>")

    -- False for not sending the original message to the chat
    return false

    end
end

-- ==================== Cli commands ====================


-- Register the /me command in the console
Console.RegisterCommand("/me", function(...)
    -- The "args" table is an array-like structure that holds all the arguments passed to the function (all the words).
    -- Takes each arguments separately like {"Hello","dude","how","are","you"}
    local args = {...}
    -- to concatenate all the elements in the "args" table into a single string
    -- first param : the table    /    And second param : separator added between elements (à space " " in this code)
    local text = table.concat(args, " ")
    if #text > 0 then
        Console.Log(text)
        -- Add the message only for the client
        Chat.AddMessage("<italic>" .. playerFound:GetName() .. " " .. text .. "</>")
    else
        -- Else show an error on the console and the chat
        Chat.AddMessage("<red>[CONSOLE ERROR : /me] You need to enter a word / sentence</>")
        error("You need to enter a string", 1)
    end
end, "Says the message after the /me in italic in the chat", { "text" })


-- Register the /printPlayerName command
Console.RegisterCommand("/getLocalPlayerName", function()

    print(playerFound:GetName())

end, "Print the name of the local player (Client side)", {})

-- Register the /clearChat command
Console.RegisterCommand("/clearChat", function()
    
    Chat.Clear()

    Console.Log("Chat cleared !")

end, "Clear the chat", {})