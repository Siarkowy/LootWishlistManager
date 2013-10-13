--------------------------------------------------------------------------------
-- Loot Wishlist Manager (c) 2013 by Siarkowy
-- Released under the terms of BSD 2.0 license.
--------------------------------------------------------------------------------

--[[

Usage: /lwm
    list [<search param>] [@<player>]
    all [<search param>]
    add <category> <item link> [@<player>]
    delete <item link>

All commands except delete can substitue %variables in argument string.
Possible variables are:

    %b --> equivalent to %i/%t but with "Other" if no target
    %f --> focus name or "<no focus>"
    %i --> instance (real zone) name
    %n --> player name
    %t --> target name or "<no target>"
    %z --> zone name

]]

local LWM = LWM

LWM.slash = {
    name = "Loot Wishlist Manager",
    handler = LWM,
    type = "group",
    args = {
        list = {
            name = "Character wishlist",
            desc = "Prints wishlist items to chat.",
            type = "input",
            set = "LookupCharacterWishlist",
            order = 10
        },
        all = {
            name = "All wichlists",
            desc = "Prints matching or all wishlist items of all characters.",
            type = "input",
            set = "LookupAllWishlists",
            order = 15
        },
        add = {
            name = "Add",
            desc = "Adds given item to wishlist.",
            type = "input",
            set = "AddWishlistEntry",
            order = 20
        },
        delete = {
            name = "Delete",
            desc = "Deletes given item from wishlist.",
            type = "input",
            set = "DeleteWishlistEntry",
            order = 25
        },
    }
}

function LWM:AddWishlistEntry(info, v)
    local v, char = self.ExtractCharacter(v, self.player)
    local cat, item = v:match("(.+)[%s/](|c.+|r)")

    if cat then
        cat = self.ExpandVars(cat):gsub("%s*/%s*", "/"):trim()
    end

    if cat and item then
        self:SetItem(tonumber(item:match("item:(%d+)")), cat, char)
        self:Printf("%2$s / %1$s added to wishlist%3$s.", item,
            cat:gsub("/", " / "), char and (" of " .. char) or "")
    else
        self:Print("Usage: /lwm add <category> <item link>")
        self:Echo("   <category> - String in form of slash separated tags like: Instance/Boss.")
        self:Echo("   <item link> - Item link to save under given category to wishlist.")
    end
end

function LWM:DeleteWishlistEntry(info, v)
    local v, char = self.ExtractCharacter(v, self.player)
    assert(self.db.profile.wishlists[char], "Character wishlist does not exist.")

    local link, item = v:match("(|c.+item:(%d+).+|r)")
    item = tonumber(item)

    if item and self:GetItem(item, char) then
        self:SetItem(item, nil, char)
        self:Printf("%s deleted from wishlist.", link)
    else
        self:Print("Usage: /lwm delete <item link>")
    end
end

function LWM:LookupCharacterWishlist(info, v)
    local v, char = self.ExtractCharacter(v, self.player)
    assert(self.db.profile.wishlists[char], "Character wishlist does not exist.")
    v = v ~= "" and self.ExpandVars(v) or nil

    self:Printf("Entries of %s%s:", char, v and " matching " .. v or "")

    local anymatch = self.anymatch
    local count = 0

    for _, entry in self:GetSortedItems(char) do
        local char, cat, item = strsplit("\t", entry)
        local _, link = GetItemInfo(item)

        if not v or (anymatch(cat, v) or anymatch(link or item, v)) then
            count = count + 1
            self:Echo(format("   %s/%s", cat, link or item):gsub("/", " / "))
        end
    end

    self:Echo("Total of %d |4entry:entries;.", count)
end

function LWM:LookupAllWishlists(info, v)
    v = v ~= "" and self.ExpandVars(v) or nil

    self:Printf("All entries %s:", v and " matching " .. v or "")

    local anymatch = self.anymatch
    local count = 0

    for char in pairs(self.db.profile.wishlists) do
        for _, entry in self:GetSortedItems(char) do
            local char, cat, item = strsplit("\t", entry)
            local _, link = GetItemInfo(item)

            if not v or (anymatch(char, v) or anymatch(cat, v) or anymatch(link or item, v)) then
                count = count + 1
                self:Echo(format("   %s/%s/%s", char, cat, link or item):gsub("/", " / "))
            end
        end
    end

    self:Echo("Total of %d |4entry:entries;.", count)
end
