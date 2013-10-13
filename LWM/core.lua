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

    -- FuBar config
    self:SetFuBarOption("cannotDetachTooltip", true)
    self:SetFuBarOption("configType", "none")
    self:SetFuBarOption("defaultPosition", "RIGHT")
    self:SetFuBarOption("hasNoColor", true)
    self:SetFuBarOption("hideWithoutStandby", true)
    self:SetFuBarOption("iconPath", [[Interface\Icons\INV_Misc_Note_01]])
    self:SetFuBarOption("tooltipType", "GameTooltip")
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

-- Core ------------------------------------------------------------------------

function LWM:Printf(...) self:Print(format(...)) end
function LWM:Echo(...) DEFAULT_CHAT_FRAME:AddMessage(format(...)) end

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
