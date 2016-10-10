

-- local theTime = GetTime()
--TODO: Turn resetDelay into a user option
local resetDelay = .3
-- local resetTime = theTime + resetDelay

-- local calculatedFrames = {}


-- function iconOverlayUpdateDelay(self, elapsed)
--     -- Delays the update of the icon overlay by resetDelay seconds.
--     theTime = GetTime()
--     if theTime > resetTime then
--         calculatedFrames = {}
--         resetTime = theTime + resetDelay
--     end
-- end
-- CanIMogIt.frame:HookScript("OnUpdate", iconOverlayUpdateDelay)



local function CheckOptionEnabled(frame)
    -- Checks if the item overlay option is enabled.
    if not CanIMogItOptions["showItemIconOverlay"] then
        return false
    end
    return true
end


local function SetIcon(frame, func, text, unmodifiedText)
    -- Sets the icon based on the text for the CanIMogItIcon on the given frame.
    if text == nil then
        -- nil means not all data was available to get the text. Try again later.
        frame.CanIMogItIcon:SetShown(false)
        frame:SetScript("OnUpdate", func);
    elseif text == "" then
        -- An empty string means that the text shouldn't be displayed.
        frame.CanIMogItIcon:SetShown(false)
        frame:SetScript("OnUpdate", nil);
    else
        -- Show an icon!
        frame.CanIMogItIcon:SetShown(true)
        local icon = CanIMogIt.tooltipIcons[unmodifiedText] or text
        frame.CanIMogItIcon:SetText(icon)
        frame:SetScript("OnUpdate", nil);
    end
end


local function AddToFrame(frame, func)
    -- Create the FontString and set OnUpdate
    if frame then
        frame.CanIMogItIcon = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
        frame.CanIMogItIcon:SetPoint("TOPRIGHT", 6, -2)
        frame.timeSinceCIMIIconCheck = 0
        frame:HookScript("OnUpdate", func)
    end
end


----------------------------
-- OnUpdate functions     --
----------------------------

function ContainerFrameItemButton_CIMIUpdateIcon(self)
    self.timeSinceCIMIIconCheck = 0
    if not CheckOptionEnabled(self) then
        self.CanIMogItIcon:SetShown(false)
        self:SetScript("OnUpdate", nil)
        return
    end
    local bag, slot = self:GetParent():GetID(), self:GetID()
    -- need to catch 0, 0 and 100, 0 here because the bank frame doesn't
    -- load everything immediately, so the OnUpdate needs to run until those frames are opened.
    if (bag == 0 and slot == 0) or (bag == 100 and slot == 0) then return end
    SetIcon(self, ContainerFrameItemButton_CIMIOnUpdate, CanIMogIt:GetTooltipText(nil, bag, slot))
end


function ContainerFrameItemButton_CIMIOnUpdate(self, elapsed)
    -- Attempts to update the icon again after the delay has elapsed.
    self.timeSinceCIMIIconCheck = self.timeSinceCIMIIconCheck + elapsed
    if self.timeSinceCIMIIconCheck >= resetDelay then
        ContainerFrameItemButton_CIMIUpdateIcon(self)
    end
end


-- local function LootFrame_OnUpdate(self, elapsed)
--     -- Sets the icon overlay for the loot frame.
--     if calculatedFrames[tostring(self)] then return end
--     calculatedFrames[tostring(self)] = true
--     if not CheckOptionEnabled(self) then return end
--     local lootID = self:GetParent().rollID
--     local itemLink = GetLootRollItemLink(lootID)
--     SetIcon(self, CanIMogIt:GetTooltipText(itemLink))
-- end


-- local function MerchantFrame_OnUpdate(self, elapsed)
--     -- Sets the icon overlay for the merchant frame.
--     if calculatedFrames[tostring(self)] then return end
--     calculatedFrames[tostring(self)] = true
--     if not CheckOptionEnabled(self) then return end
--     local itemLink = self.link
--     SetIcon(self, CanIMogIt:GetTooltipText(itemLink))
-- end


-- local function JournalFrame_SetLootButton(itemFrame)
--     -- Sets the icon overlay for the merchant frame.
--     if calculatedFrames[tostring(self)] then return end
--     calculatedFrames[tostring(self)] = true
--     if not CheckOptionEnabled(itemFrame) then return end
--     local itemLink = itemFrame.link
--     SetIcon(itemFrame, CanIMogIt:GetTooltipText(itemLink))
-- end


-- local function AuctionFrame_OnUpdate(self, elapsed)
--     -- Sets the icon overlay for the auction frame.
--     if calculatedFrames[tostring(self)] then return end
--     calculatedFrames[tostring(self)] = true
--     if not CheckOptionEnabled(self) then return end
--     local browseButtonID = self:GetParent():GetID()
--     local index = BrowseScrollFrame.offset + browseButtonID
--     local itemLink = GetAuctionItemLink("list", index)
--     SetIcon(self, CanIMogIt:GetTooltipText(itemLink))
-- end


-- local function MailFrame_OnUpdate(self, elapsed)
--     -- Sets the icon overlay for the mail attachement frame.
--     if calculatedFrames[tostring(self)] then return end
--     calculatedFrames[tostring(self)] = true
--     if not CheckOptionEnabled(self) then return end
--     local frameID = self:GetID()

--     local messageIndex;
--     -- 7 is the number of visible inbox buttons at a time.
--     for i=1,7 do
--         local mailFrame = _G["MailItem"..i.."Button"]
--         if mailFrame:IsShown() and mailFrame:GetChecked() then
--             messageIndex = mailFrame.index
--         end
--     end
--     if not messageIndex then
--         SetIcon(self, nil)
--         return
--     end

--     local itemLink = GetInboxItemLink(messageIndex, frameID)
--     SetIcon(self, CanIMogIt:GetTooltipText(itemLink))
-- end


-- local function GuildBankFrame_OnUpdate(self, elapsed)
--     -- Sets the icon overlay for the guild bank item frame.
--     if calculatedFrames[tostring(self)] then return end
--     calculatedFrames[tostring(self)] = true
--     if not CheckOptionEnabled(self) then return end
--     local tab = GetCurrentGuildBankTab()
--     local slot = self:GetID()
--     local itemLink = GetGuildBankItemLink(tab, slot)
--     SetIcon(self, CanIMogIt:GetTooltipText(itemLink))
-- end


-- local function VoidStorageFrame_OnUpdate(self, elapsed)
--     -- Sets the icon overlay for the guild bank item frame.
--     if calculatedFrames[tostring(self)] then return end
--     calculatedFrames[tostring(self)] = true
--     if not CheckOptionEnabled(self) then return end
--     local page = _G["VoidStorageFrame"].page
--     local buttonSlot = self.slot
--     local voidSlot = buttonSlot + (80 * (page - 1))
--     local itemLink = GetVoidItemHyperlinkString(voidSlot)
--     SetIcon(self, CanIMogIt:GetTooltipText(itemLink))
-- end


----------------------------
-- Begin adding to frames --
----------------------------


function CanIMogIt.frame:HookItemOverlay(event, addonName)
    if event ~= "PLAYER_LOGIN" and addonName ~= "CanIMogIt" then return end

    -- Add hook for each bag item.
    for i=1,NUM_CONTAINER_FRAMES do
        for j=1,MAX_CONTAINER_ITEMS do
            local frame = _G["ContainerFrame"..i.."Item"..j]
            AddToFrame(frame, ContainerFrameItemButton_CIMIOnUpdate)
        end
    end

    -- Add hook for the main bank frame.
    for i=1,NUM_BANKGENERIC_SLOTS do
        local frame = _G["BankFrameItem"..i]
        AddToFrame(frame, ContainerFrameItemButton_CIMIOnUpdate)
    end

    -- -- Add hook for the loot frames.
    -- for i=1,NUM_GROUP_LOOT_FRAMES do
    --     local frame = _G["GroupLootFrame"..i].IconFrame
    --     AddToFrame(frame, LootFrame_OnUpdate)
    -- end

    -- -- Add hook for the Mail inbox frames.
    -- for i=1,ATTACHMENTS_MAX_SEND do
    --     local frame = _G["OpenMailAttachmentButton"..i]
    --     AddToFrame(frame, MailFrame_OnUpdate)
    -- end

    -- -- Add hook for the Merchant frames.
    -- -- 12 is the number of merchant items visible at once.
    -- for i=1,12 do
    --     local frame = _G["MerchantItem"..i.."ItemButton"]
    --     AddToFrame(frame, MerchantFrame_OnUpdate)
    -- end


    -- -- function CanIMogIt.frame:OnAuctionHouseShow(event, ...)
    -- --     -- The button frames don't exist until the auction house is open.
    -- --     if event ~= "AUCTION_HOUSE_SHOW" then return end
    -- --     -- Add hook for the Auction House frames.
    -- --     for i=1,8 do
    -- --         local frame = _G["BrowseButton"..i.."Item"]
    -- --         AddToFrame(frame, AuctionFrame_OnUpdate)
    -- --     end
    -- -- end

    -- -- function CanIMogIt.frame:OnEncounterJournalLoaded(event, addonName, ...)
    -- --     if event ~= "ADDON_LOADED" then return end
    -- --     if addonName ~= "Blizzard_EncounterJournal" then return end
    -- --     for i=1,10 do
    -- --         local frame = _G["EncounterJournalEncounterFrameInfoLootScrollFrameButton"..i]
    -- --         AddToFrame(frame)
    -- --     end
    -- --     hooksecurefunc("EncounterJournal_SetLootButton", JournalFrame_SetLootButton)
    -- -- end


    -- local guildBankLoaded = false

    -- function CanIMogIt.frame:OnGuildBankOpened(event, ...)
    --     if event ~= "GUILDBANKFRAME_OPENED" then return end
    --     if guildBankLoaded == true then return end
    --     guildBankLoaded = true
    --     for column=1,7 do
    --         for button=1,14 do
    --             local frame = _G["GuildBankColumn"..column.."Button"..button]
    --             AddToFrame(frame, GuildBankFrame_OnUpdate)
    --         end
    --     end
    -- end


    -- local voidStorageLoaded = false

    -- function CanIMogIt.frame:OnVoidStorageOpened(event, ...)
    --     if event ~= "VOID_STORAGE_OPEN" then return end
    --     if voidStorageLoaded == true then return end
    --     voidStorageLoaded = true
    --     for i=1,80 do
    --         local frame = _G["VoidStorageStorageButton"..i]
    --         AddToFrame(frame, VoidStorageFrame_OnUpdate)
    --     end
    -- end

end

------------------------
-- Event functions    --
------------------------

local events = {
    ["UNIT_INVENTORY_CHANGED"] = true,
    ["PLAYER_SPECIALIZATION_CHANGED"] = true,
    ["BAG_UPDATE"] = true,
    ["BAG_NEW_ITEMS_UPDATED"] = true,
    ["QUEST_ACCEPTED"] = true,
    ["BAG_SLOT_FLAGS_UPDATED"] = true,
    ["BANK_BAG_SLOT_FLAGS_UPDATED"] = true,
    ["PLAYERBANKSLOTS_CHANGED"] = true,
    ["BANKFRAME_OPENED"] = true,
}

function CanIMogIt.frame:ItemOverlayEvents(event, ...)
    if not events[event] then return end
    -- bags
    for i=1,NUM_CONTAINER_FRAMES do
        for j=1,MAX_CONTAINER_ITEMS do
            local frame = _G["ContainerFrame"..i.."Item"..j]
            ContainerFrameItemButton_CIMIUpdateIcon(frame)
        end
    end
    -- main bank frame
    for i=1,NUM_BANKGENERIC_SLOTS do
        local frame = _G["BankFrameItem"..i]
        ContainerFrameItemButton_CIMIUpdateIcon(frame)
    end
end
