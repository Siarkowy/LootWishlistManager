--------------------------------------------------------------------------------
-- Loot Wishlist Manager (c) 2013 by Siarkowy
-- Released under the terms of BSD 2.0 license.
--------------------------------------------------------------------------------

LWM = LibStub("AceAddon-3.0"):NewAddon(
    "Loot Wishlist Manager",

    -- embeds:
    "AceEvent-3.0",
    "AceConsole-3.0",
    "LibFuBarPlugin-Mod-3.0"
)

local LWM = LWM

-- Initialization --------------------------------------------------------------

function LWM:OnInitialize()
    self.player = UnitName("player")

    self.db = LibStub("AceDB-3.0"):New("LwmDB", {
        profile = {
            wishlists = {
                [self.player] = {
                    -- pairs: [<item id>] = <category string>
                }
            }
        }
    }, DEFAULT)

    self.wishlist = self.db.profile.wishlists[self.player]

    -- Slash config
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Loot Wishlist Manager", self.slash)
    self:RegisterChatCommand("lwm", "OnSlashCmd")

    -- Add GUI options
    self.options = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Loot Wishlist Manager", "LWM")
    self.options.default = function() self.db:ResetProfile() end

    -- FuBar config
    self:InitFu()
end

function LWM:OnEnable()
    self:RegisterEvent("CHAT_MSG_LOOT")
end

function LWM:OnSlashCmd(input)
    -- if not input or input:trim() == "" then
        -- InterfaceOptionsFrame_OpenToFrame(self.options)
    -- else
        LibStub("AceConfigCmd-3.0").HandleCommand(self, "lwm", "Loot Wishlist Manager", input)
    -- end
end

-- Utils -----------------------------------------------------------------------

function LWM:Printf(...) self:Print(format(...)) end
function LWM:Echo(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end

--- Performs multiple pattern matches on supplied value.
-- @param v (mixed) Test value.
-- @param patterns (string) Pattern string in form of "pat1|pat2|...|patN".
-- @return bool Whether anything matched.
function LWM.anymatch(v, patterns)
    for pat in patterns:gmatch("[^|]+") do
        if tostring(v):match(pat) then
            return true
        end
    end

    return false
end

function LWM.ExtractCharacter(input, default)
    local char

    input = input:gsub("@(%w+)", function(m) char = m return "" end):trim()

    return input, char or default
end

do
    local data = {}

    --- Replaces %vars with their current values.
    -- @param str (string) Input string.
    -- @return string
    function LWM.ExpandVars(str)
        data.b = format("%s/%s", GetRealZoneText(), UnitName("target") or "Other")
        data.f = UnitName("focus") or "<no focus>" -- focus name
        data.i = GetRealZoneText() -- instance name
        data.n = UnitName("player") -- player name
        data.t = UnitName("target") or "<no target>" -- target name
        data.z = GetZoneText() -- zone name

        return str:gsub("%%(.)", data)
    end
end

--- Returns an iterator to traverse hash indexed table in alphabetical order.
-- @param t Table.
-- @param f Sort function for table's keys.
-- @return function - Alphabetical iterator of hash table.
function LWM.PairsByKeys(t, f) -- from http://www.lua.org/pil/19.3.html
    local a = {}
    for n in pairs(t) do tinsert(a, n) end
    sort(a, f)
    local i = 0             -- iterator variable
    local iter = function() -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]] end
    end
    return iter
end

-- Core ------------------------------------------------------------------------

function LWM:CHAT_MSG_LOOT(e, msg)
    local id = tonumber(msg:match("You won:.*item:(%d+)")
        or msg:match("You receive loot:.*item:(%d+)"))

    if id and self:GetItem(id) then
        self:SetItem(id, nil) -- clear entry
    end
end

--- Returns wishlist flag for given item ID.
-- @param id (number) Item ID.
-- @return nil|number Result flag.
function LWM:GetItem(id, char)
    return (char and assert(self.db.profile.wishlists[char],
        "Character wishlist does not exist.") or self.wishlist)
        [assert(id, "Item ID is missing.")]
end

--- Returns wishlist table for given or current character.
-- @param char (optional) Character name.
-- @return table Wishlist table.
function LWM:GetItems(char)
    return pairs(char and self.db.profile.wishlists[char] or self.wishlist)
end

function LWM:GetSortedItems(char)
    char = char and self.db.profile.wishlists[char] and char or self.player

    local wishlist = {}

    for item, cat in self:GetItems(char) do
        tinsert(wishlist, strjoin("\t", char, cat, item))
    end

    sort(wishlist)

    return ipairs(wishlist)
end

--- Sets wishlist entry for given item ID and flag.
function LWM:SetItem(id, cat, char)
    (char and assert(self.db.profile.wishlists[char], "Character wishlist does not exist.")
        or self.wishlist)[assert(id, "Item ID missing.")] = cat
end
