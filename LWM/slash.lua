--------------------------------------------------------------------------------
-- Loot Wishlist Manager (c) 2013 by Siarkowy
-- Released under the terms of BSD 2.0 license.
--------------------------------------------------------------------------------

--[[

/lwm
    add <category> <item link>
    delete <item link>
    list [<player>]

]]

local LWM = LWM

LWM.slash = {
    name = "Loot Wishlist Manager",
    handler = LWM,
    type = "group",
    args = {
        add = {
            name = "Add",
            desc = "Adds given item to wishlist.",
            type = "input",
            set = function(info, v)
                local cat, item = v:match("(.+)[%s/](|c.+|r)")

                if cat then
                    cat = cat:gsub("%s*/%s*", "/"):trim()
                end

                if cat and item then
                    LWM:SetItem(tonumber(item:match("item:(%d+)")), cat)
                    LWM:Printf("%2$s / %1$s added to wishlist.", item, cat:gsub("/", " / "))
                else
                    LWM:Print("Usage: /lwm add <category> <item link>")
                end
            end,
            order = 10
        },
        delete = {
            name = "Delete",
            desc = "Deletes given item from wishlist.",
            type = "input",
            set = function(info, v)
                local link, item = v:match("(|c.+item:(%d+).+|r)")
                item = tonumber(item)

                if item and LWM:GetItem(item) then
                    LWM:SetItem(item, nil)
                    LWM:Printf("%s deleted from wishlist.", link)
                else
                    LWM:Print("Usage: /lwm delete <item link>")
                end
            end,
            order = 15
        },
        list = {
            name = "List",
            desc = "Prints wishlist items to chat.",
            type = "input",
            func = function(info, v)
                LWM:Print("Entries:")

                local count = 0
                for item, cat in LWM:GetItems(v ~= "" and v) do
                    count = count + 1
                    local _, link = GetItemInfo(item)

                    LWM:Echo(format("   %s/%s", cat, link or item):gsub("/", " / "))
                end

                LWM:Echo("Total of %d |4entry:entries;.", count)
            end,
            order = 20
        },
    }
}
