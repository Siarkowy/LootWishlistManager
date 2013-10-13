--------------------------------------------------------------------------------
-- Loot Wishlist Manager (c) 2013 by Siarkowy
-- Released under the terms of BSD 2.0 license.
--------------------------------------------------------------------------------

local LWM = LWM

function LWM:InitFu()
    self:SetFuBarOption("cannotDetachTooltip", true)
    self:SetFuBarOption("configType", "none")
    self:SetFuBarOption("defaultPosition", "RIGHT")
    self:SetFuBarOption("hasNoColor", true)
    self:SetFuBarOption("hideWithoutStandby", true)
    self:SetFuBarOption("iconPath", [[Interface\Icons\INV_Misc_Note_01]])
    self:SetFuBarOption("tooltipType", "GameTooltip")
end

do
    local data = {}

    function LWM:OnUpdateFuBarTooltip()
        local instance = select(2, IsInInstance()) == "raid" and GetRealZoneText() or nil

        GameTooltip:ClearLines()
        GameTooltip:AddLine(self.name)

        for char in self.PairsByKeys(self.db.profile.wishlists) do
            for k in pairs(data) do
                data[k] = nil
            end

            for _, entry in self:GetSortedItems(char) do
                if IsControlKeyDown()
                or not instance and entry:match(self.player)
                or instance and entry:match(instance) then
                    tinsert(data, entry)
                end
            end

            if #data > 0 then
                sort(data)
                GameTooltip:AddLine("\n" .. char)

                for _, entry in ipairs(data) do
                    local char, cat, item = strsplit("\t", entry)
                    local _, link = GetItemInfo(item)

                    GameTooltip:AddDoubleLine(link or item, cat:gsub("/", " / "))
                end
            end
        end

        if not IsControlKeyDown() then
            GameTooltip:AddLine("\nHint: Hold Control button to list all entires.", 0, 1, 0)
        end
    end
end
