--[[
  Flux © 2016-2017 TeslaCloud Studios
  Do not share or re-distribute before
  the framework is publicly released.
--]]

PLUGIN.name = 'TeslaCloud Blacklist'
PLUGIN.description = 'Automatically prevents access to any TeslaCloud-ran servers to certain players.'
PLUGIN.author = 'Mr. Meow'
PLUGIN.compatibility = '1.2'

--[[
  This code is here for indev and private versions only.
  This will be removed in release.
--]]

local defaultReason = 'You have been blacklisted from this server! Appeal at iron-wall.com'

local blacklist = {
  ['STEAM_0:1:26720819'] = 'Banned for being a dick.', -- banned me for being me
  ['STEAM_0:1:36296412'] = 'Banned for severe ToS violations.', -- ddosed me
  ['STEAM_0:1:8387555'] = 'No Flux for you mate :p', -- kuro
  ['STEAM_0:1:66844990'] = 'Banned for severe ToS violations.', -- ddos
  -- TNF community players and admins
  ['STEAM_0:0:53046893'] = 'You have been blacklisted due to bad affiliations!', -- [TNF]AnalCaptain
  ['STEAM_0:1:98463373'] = 'You have been blacklisted due to bad affiliations!', -- Дови
  ['STEAM_0:1:39162722'] = 'You have been blacklisted due to bad affiliations!', -- Aksinya Astakhova
  ['STEAM_0:0:78302726'] = 'You have been blacklisted due to bad affiliations!', -- step000nchik #1WW
  ['STEAM_0:1:49235892'] = 'You have been blacklisted due to bad affiliations!', -- Takumi
  ['STEAM_0:0:77222389'] = 'You have been blacklisted due to bad affiliations!', -- The Mask
  ['STEAM_0:1:39496371'] = 'You have been blacklisted due to bad affiliations!', -- [Hakers]cherep_
  ['STEAM_0:0:74317098'] = 'You have been blacklisted due to bad affiliations!', -- [RT]-=XOMAK=-
  ['STEAM_0:0:43712567'] = 'You have been blacklisted due to bad affiliations!', -- 🔰[TNF][CUPS]Cup of Tea🔰
  ['STEAM_0:1:158640316'] = 'You have been blacklisted due to bad affiliations!', -- AnonimusRedBlue
  ['STEAM_0:0:59648570'] = 'You have been blacklisted due to bad affiliations!', -- Blender 2.78
  ['STEAM_0:1:89076554'] = 'You have been blacklisted due to bad affiliations!', -- Frix
  ['STEAM_0:1:75772998'] = 'You have been blacklisted due to bad affiliations!', -- J'zargo
  ['STEAM_0:0:72273145'] = 'You have been blacklisted due to bad affiliations!', -- [SOW] Player
  ['STEAM_0:0:72161468'] = 'You have been blacklisted due to bad affiliations!', -- Raup "7-6-0" Raus
  ['STEAM_0:0:198023944'] = 'You have been blacklisted due to bad affiliations!', -- mirrad233
  ['STEAM_0:0:49512624'] = 'You have been blacklisted due to bad affiliations!', -- BlyeBerry
  ['STEAM_0:0:86748785'] = 'You have been blacklisted due to bad affiliations!', -- 🔰[THF][CUPS]Cup of Anime🔰
  ['STEAM_0:0:74707290'] = 'You have been blacklisted due to bad affiliations!', -- Моге-Ко♥♪
  ['STEAM_0:1:86275919'] = 'You have been blacklisted due to bad affiliations!', -- Кошак-пышак
  ['STEAM_0:0:101423388'] = 'You have been blacklisted due to bad affiliations!', -- Immortal
  ['STEAM_0:1:88616406'] = 'You have been blacklisted due to bad affiliations!', -- [TNF]you're fired
  ['STEAM_0:1:10947122'] = 'You have been blacklisted due to bad affiliations!', -- [TNF] Vesthamer
  ['STEAM_0:0:88416778'] = 'You have been blacklisted due to bad affiliations!', -- P U L S A R
  ['STEAM_0:1:18294986'] = 'You have been blacklisted due to bad affiliations!', -- Macleod962
  ['STEAM_0:1:117523547'] = 'You have been blacklisted due to bad affiliations!' -- Lurker_666
}

local badKeywords = {
  '[tnf]', '[ tnf ]', '[ tnf]', '[tnf ]',
  '[tnf', '(tnf', '(tnf)', 'tnf)', 'the new future', '( tnf', 'tnf )',
  'kurozael', 'conna wiles', 'connawiles', 'kuropixel', 'cloudsixteen',
  'cloud sixteen'
}

--- Called when the plugins have loaded; replaces the built-in blacklist with `data/flux_blacklist.txt`.
--
-- The file holds a pON-encoded map of Steam IDs to kick reasons.
function PLUGIN:FluxPluginsLoaded()
  local contents = File.read('data/flux_blacklist.txt')

  if isstring(contents) then
    blacklist = pon.decode(contents) or {}
  end
end

--- Called when a player tries to join; drops blacklisted players and those with banned keywords in their name.
--
-- A player whose name contains a banned keyword is added to the blacklist with the default reason, and
-- the blacklist is written to `data/flux_blacklist.txt`.
--
-- @param steamID64 [String The joining player's 64-bit Steam ID]
-- @param ip [String The player's IP address]
-- @param password [String The server password]
-- @param clPassword [String The password the player entered]
-- @param name [String The player's Steam name]
-- @return [Boolean False to refuse the connection, or nil to allow it, String The kick reason]
function PLUGIN:CheckPassword(steamID64, ip, password, clPassword, name)
  local steamid = util.SteamIDFrom64(steamID64)
  local entry = blacklist[steamid]

  if entry then
    print('Dropping '..name..' for being in the blacklist. Entry: '..steamid)

    return false, entry
  end

  if isstring(name) then
    local lowerName = string.utf8lower(name)

    for k, v in ipairs(badKeywords) do
      if string.find(name, v, 1, true) then
        blacklist[steamid] = defaultReason

        File.write('data/flux_blacklist.txt', pon.encode(blacklist))

        print('Dropping '..name.." for having bad keyword '"..v.."' in their name!")

        return false, defaultReason
      end
    end
  end
end
