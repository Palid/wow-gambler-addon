-- WoW pseudomocks

-- function CreateFrame()
--   local frame = {}
--   function frame:RegisterEvent()
--   end
--   function frame:UnregisterEvent()
--   end
--   function frame:SetScript()
--   end
--   function frame:AddMessage(message)
--     print(message)
--   end
--   return frame
-- end

-- local DEFAULT_CHAT_FRAME = CreateFrame()

-- local SLASH_Gambler1
-- local SLASH_Gambler2
-- local SlashCmdList = {}

-- END OF MOCK WOW

-- Very global globals, init that should be done ASAP.
local GAMBLER_FRAME = CreateFrame('FRAME', 'GamblerFrame');

-- GLOBALS
local ADDON_NAME = 'Gambler'
local SLASH_COMMAND_1 = '/gt'
local SLASH_COMMAND_2 = '/gambler'
local JOIN_GAME_CHARACTER = 'j'
local LEAVE_GAME_CHARACTER = 'l'
local DEFAULT_EVENT_TYPE = 'PARTY'
-- TODO: Implement DEFAULT_EVENT_TYPE
local EVENTS_NAMES = {
  -- GUILD = {
    -- 'CHAT_MSG_GUILD',
    -- 'CHAT_MSG_GUILD_LEADER',
  -- },
  -- PARTY = {
    'CHAT_MSG_PARTY',
    'CHAT_MSG_PARTY_LEADER',
    'CHAT_MSG_SYSTEM'
  -- },
  -- RAID = {
    -- 'CHAT_MSG_RAID',
    -- 'CHAT_MSG_RAID_LEADER',
  -- }
}
local ROLL_STATE_NIL = 0
local ROLL_STATE_JOINING = 1
local ROLL_STATE_START = 2
local ROLL_STATE_FINISHED = 3

-- GAME STATE
local GAME_STATE = {
  -- uses above ROLL_STATE variables
  rollState = 0,
  currentDice = 100,
  currentPlayers = {},
  currentRolls = {
    highest = 0,
    lowest = 0
  }
}

-- Utility functions

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
local function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep('  ', indent) .. k .. ': '
    if type(v) == 'table' then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

local function size(keyset)
  local n=0
  for k,v in pairs(keyset) do
    n=n+1
  end
  return n
end

local function capitalize(str)
    return (str:gsub('^%l', string.upper))
end

local function logMessage(message)
  DEFAULT_CHAT_FRAME:AddMessage(message)
end

local function red(text)
  return '|cFFFF0000' .. text
end

local function green(text)
  return '|cFF00FF00' .. text
end

local function blue(text)
  return '|cFF0000FF' .. text
end

local function yellow(text)
  return '|cFFFFFF00' .. text
end

local function hexrgb(hexred, hexgreen, hexblue, text)
  if hexred == nil then hexred = 'FF' end
  if hexgreen == nil then hexgreen = 'FF' end
  if hexblue == nil then hexblue = 'FF' end
  return '|c' .. hexred .. hexgreen .. hexblue .. text
end

local function sendToChat(message)
    SendChatMessage(message, 'RAID', nil)
end

local function normalizeCharacterName(nickname)
  local lower = strlower(nickname)
  local nickWithoutServer, server = strsplit('-', lower)
  return nickWithoutServer
end


-- INITIALIZATION --
-- Create global context managed by WoW.
if (not Gambler) then
  Gambler = {
    alts = {},
    bans = {},
    stats = {},
    config = {
      autoCloseIn = 60  -- seconds
    }
  }
end

local function parseRoll(message)
  local player, systemCommand, roll, range = strsplit(' ', message)
  local normalizedCharacterName = normalizeCharacterName(player)
  if (systemCommand == 'rolls' and GAME_STATE.currentPlayers[player]) then
    local minRoll, maxRoll = strsplit('-', range)
    local parsedRoll = tonumber(roll)
    -- TODO: WTF is minRoll - taken out of CrossGambling.
    minRoll = tonumber(strsub(minRoll, 2))
    maxRoll = tonumber(strsub(maxRoll, 1, -2))
    if (maxRoll == currentDice and minRoll == 1) then
      -- TODO - tiebreaking, actual counting, stats, whatever
  end
end

local function onChatMessage(...)
  if GAME_STATE.rollState == ROLL_STATE_JOINING then
    local arguments = {...}
    local eventName = arguments[2]
    local message = arguments[3]
    local characterName = normalizeCharacterName(arguments[4])
    -- TODO: implement DEFAULT_EVENT_TYPE
    if eventName == 'CHAT_MSG_RAID' or 'CHAT_MSG_RAID_LEADER' or 'CHAT_MSG_PARTY' or 'CHAT_MSG_PARTY_LEADER' then
      if message == JOIN_GAME_CHARACTER then
        -- TODO: implement alts
        if Gambler.bans[characterName] ~= nil then
          sendToChat(string.format('%s is banned from Gambler! No games for you!', characterName))
          return -- just do a clean exit if character is banned.
        end
        GAME_STATE.currentPlayers[characterName] = true
      elseif message == LEAVE_GAME_CHARACTER then
        if GAME_STATE.currentPlayers[characterName] == true then
          GAME_STATE.currentPlayers[characterName] = nil
        end
      end
    elseif eventName == 'CHAT_MSG_SYSTEM' then
      return parseRoll(message)
    end
  else
  end
end

local function onSlashCallback(message)
  local splitted = strsplit(' ', message)
  local command = splitted[1]
  if (command == nil) then
    command = ''
  else
    command = strlower(command)
  end
  local commandFunction = AvailableCommands[command]
  if commandFunction ~= nil then
    print(select(1, unpack(splitted)))
    commandFunction.fnc(select(1, unpack(splitted)))
  else
    logMessage('Command ' .. command .. ' does not exist. Try ' .. SLASH_COMMAND_1 .. ' help for list of commands.')
  end
end

logMessage('|cffffff00<Gambler 0.01> loaded /gt to use')

GAMBLER_FRAME:SetScript('OnEvent', onChatMessage)
SLASH_Gambler1 = SLASH_COMMAND_1
SLASH_Gambler2 = SLASH_COMMAND_2
SlashCmdList[ADDON_NAME] = onSlashCallback


-- Commands

local AvailableCommands = {
  help = {
    helptext = 'lists all available commands.'
  },
  stats = {
    helptext = 'shows stats for each individual player.'
  },
  bans = {
    helptext = 'shows banned players list.'
  },
  ban = {
    helptext = 'add player to banlist. Requires arguments [player] [reason].'
  },
  unban = {
    helptext = 'remove player from banlist.'
  },
  roll = {
    helptext = 'starts the casino with [sided] dice.'
  },
  throw = {
    helptext = string.format('close the current casino and start throwing the dices. Will automatically close after [%s] seconds.', Gambler.config.autoCloseIn)
  },
  reset = {
    helptext = 'clean up current game and close the casino. That is all folks, no more games now.'
  }
}
function AvailableCommands.stats:fnc(player)
  return print_to_console(player)
end
function AvailableCommands.help:fnc()
  logMessage('List of all available commands:')
  for command, value in pairs(AvailableCommands) do
    logMessage(string.format('%s:%s.', capitalize(command), value.helptext))
  end
end
function AvailableCommands.bans:fnc()
  if (size(Gambler.bans) == 0) then
    logMessage('There are no banned users! :)')
  else
    logMessage('Banned players list with reasons :')
    for user, reason in pairs(Gambler.bans) do
      logMessage(string.format('%s: banned for %s', user, reason))
    end
  end
end
function AvailableCommands.ban:fnc(player, ...)
  local arguments = {...}
  local reason = table.concat(arguments, ' ')
  local capitalizedPlayer = capitalize(player);
  if capitalizedPlayer ~= nil then
    if reason ~= nil then
      local bannedPlayer = Gambler.bans[capitalizedPlayer];
      if bannedPlayer ~= nil then
        logMessage(string.format('%s was already banned for reason: %s', capitalizedPlayer, reason))
      else
        Gambler.bans[capitalizedPlayer] = reason
        logMessage(string.format('%s was banned for a reason: %s', capitalizedPlayer, reason))
      end
    else
      logMessage('Reason is required to ban a user.')
      logMessage('Valid ban example:')
      logMessage('/ban palid makes stupid addons')
    end
  else
    logMessage('Nick is required to ban a user.')
    logMessage('Valid ban example:')
    logMessage('/ban palid makes stupid addons')
  end
end
function AvailableCommands.unban:fnc(player)
  if player ~= nil then
      Gambler.bans[player] = nil
  else
    logMessage('Nick is required to unban a user.')
    logMessage('/unban palid')
  end
end
function AvailableCommands.roll:fnc(dicesSides)
  if GAME_STATE.rollState == ROLL_STATE_RESET then
    for index, eventName in pairs(EVENTS_NAMES) do
      GAMBLER_FRAME:RegisterEvent(eventName)
    end
    local dicesSidesNumber = tonumber(dicesSides);
    if dicesSides == nil then dicesSides = 100 end
    GAME_STATE.rollState = ROLL_STATE_JOINING
    GAME_STATE.currentPlayers = {}
    GAME_STATE.currentDice = dicesSides
    sendToChat(string.format('Gambler set up casino rolls with [%s] sided dice!', dicesSides))
    sendToChat(string.format('Type [%s] to join the game or [%s] to leave it.'), JOIN_GAME_CHARACTER, LEAVE_GAME_CHARACTER)
    C_Timer.After(Gambler.config.autoCloseIn, AvailableCommands.throw.fnc)
  else
    sendToChat(string.format("Gambler still has it's game with [%s] sided dice open!", GAME_STATE.currentDice))
  end
end
function AvailableCommands.throw:fnc()
  if GAME_STATE.rollState == ROLL_STATE_JOINING then
    if size(GAME_STATE.currentPlayers) > 2 then
      sendToChat('Gambler is finished waiting! Time to roll your [%s] sided dices!', GAME_STATE.currentDice)
      GAME_STATE.rollState = ROLL_STATE_START
    end
  end
end
function AvailableCommands.reset:fnc()
  GAME_STATE.rollState = ROLL_STATE_RESET
  GAME_STATE.currentPlayers = {}
  GAME_STATE.currentDice = 100
  GAME_STATE.currentRolls.highest = 0
  GAME_STATE.currentRolls.lowest = 0
  sendToChat('Gambler has hidden his casino for now.')
  for index, eventName in pairs(EVENTS_NAMES) do
    GAMBLER_FRAME.UnregisterEvent(eventName)
  end

  -- GAMBLER_FRAME.UnregisterEvent('OnEvent')
end
