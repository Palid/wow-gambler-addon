-- Utility functions

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
local function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
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
    return (str:gsub("^%l", string.upper))
end

local function split_string(str, separator)
  if separator == nil then
    return {str}
  end
  local list = {}
  local temporary_str = ''
  for i = 1, string.len(str) do
    local char = string.sub(str, i, i)
    if char == separator then
      table.insert(list, temporary_str)
      temporary_str = ''
    else
      temporary_str = temporary_str .. char
    end
  end
  table.insert(list, temporary_str)
  return list
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

-- Global variables
local addon_name = "Gambler"
local SLASH_COMMAND_1 = '/gt'
local SLASH_COMMAND_2 = '/gambler'
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
    helptext = 'add player to banlist. Requires arguments [player] [reason]'
  },
  unban = {
    helptext = 'remove player from banlist.'
  }
}
function AvailableCommands.stats:fnc(player)
  return print_to_console(player)
end
function AvailableCommands.help:fnc()
  logMessage('List of all available commands:')
  for k, v in pairs(AvailableCommands) do
    logMessage(capitalize(k) .. ': ' .. v.helptext .. '.')
  end
end
function AvailableCommands.bans:fnc()
  if (size(Gambler.bans) == 0) then
    logMessage('There are no banned users! :)')
  else
    logMessage('Banned players list with reasons :')
    for user, reason in pairs(Gambler.bans) do
      logMessage(user .. ': banned for ' .. reason)
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
        logMessage(capitalizedPlayer .. ' was already banned for reason: ' .. reason)
      else
        Gambler.bans[capitalizedPlayer] = reason
        logMessage(capitalizedPlayer .. ' was banned for a reason: ' .. reason)
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

-- INITIALIZATION --

-- Create global context managed by WoW.

if (not Gambler) then
  Gambler = {
    alts = {},
    bans = {},
    stats = {}
  }
end

local function onChatMessage(...)
  local arguments = {...}
  local EVENT_NAME = arguments[2]
  local MESSAGE = arguments[3]
  local SENDER_NAME = arguments[4]
end

-- LOAD FUNCTION --
local function init()
  local frame = CreateFrame("FRAME", "GamblerFrame");
  logMessage("|cffffff00<Gambler 0.01> loaded /gt to use")


  local message_event_sources = {'PARTY', 'RAID', 'GUILD'}

  for index, event_name in pairs(message_event_sources) do
    local event_name = "CHAT_MSG_" .. event_name
    frame:RegisterEvent(event_name)
    frame:RegisterEvent(event_name .. '_LEADER')
  end
  -- frame:RegisterEvent("CHAT_MSG_SYSTEM")
  -- frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:SetScript("OnEvent", onChatMessage)
end

local function onSlashCallback(message)
  local splitted = split_string(message, ' ')
  local command = splitted[1]
  if (command == nil) then
    command = ''
  else
    command = command:lower()
  end
  local commandFunction = AvailableCommands[command]
  if commandFunction ~= nil then
    print(select(1, unpack(splitted)))
    commandFunction.fnc(select(1, unpack(splitted)))
  else
    logMessage('Command ' .. command .. ' does not exist. Try ' .. SLASH_COMMAND_1 .. ' help for list of commands.')
  end
  -- logMessage(splitted[0])
  -- logMessage(message or 'nil')
end

SLASH_Gambler1 = SLASH_COMMAND_1
SLASH_Gambler2 = SLASH_COMMAND_2
SlashCmdList[addon_name] = onSlashCallback


init()
