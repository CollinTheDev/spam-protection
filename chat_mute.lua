----------------------- Configuration -----------------------

Config = Config or {}

-- Time (in seconds) before a player is unmuted after being muted for spamming.
-- Default is 300 seconds (5 minutes).
Config.MuteDuration = 60

-- Minimum time interval (in seconds) between messages before muting the player.
-- Default is 2 seconds (if the player sends more than 1 message in 2 seconds, they will be muted).
Config.MessageInterval = 2

-- Message displayed to players when they are muted for spamming.
Config.MuteMessage = "You have been muted for spamming! Please wait 5 minutes."

-- Message displayed to players when they are unmuted after the mute duration.
Config.UnmuteMessage = "You have been unmuted."

-- Message displayed when a player tries to send a message while muted.
Config.BlockedMessage = "You are currently muted and cannot send messages."


----------------------- DO NOT EDIT BELOW THIS LINE! -----------------------

local messageTimestamps = {}
local mutedPlayers = {}

AddEventHandler('chatMessage', function(source, name, message)
    local currentTime = os.time()

    -- Check if the player has sent messages recently
    if messageTimestamps[source] then
        local lastMessageTime = messageTimestamps[source]

        -- If the player sent a message in the last Config.MessageInterval seconds, mute them for Config.MuteDuration
        if currentTime - lastMessageTime < Config.MessageInterval then
            -- Mute the player for Config.MuteDuration seconds
            TriggerClientEvent('chat:addMessage', source, {
                args = { 'Server', Config.MuteMessage }
            })

            -- Add the player to the muted list and prevent chat
            mutedPlayers[source] = true
            Citizen.SetTimeout(Config.MuteDuration * 1000, function()
                mutedPlayers[source] = nil
                TriggerClientEvent('chat:addMessage', source, {
                    args = { 'Server', Config.UnmuteMessage }
                })
            end)
        end
    end

    -- If the player is muted, block their message
    if mutedPlayers[source] then
        CancelEvent() -- This will prevent the message from being sent
        TriggerClientEvent('chat:addMessage', source, {
            args = { 'Server', Config.BlockedMessage }
        })
        return
    end

    -- Update the message timestamp for the player
    messageTimestamps[source] = currentTime
end)
