local _, App = ...;

App.Bidder = App.Bidder or {};

local Utils = App.Utils;
local Bidder = App.Bidder;
local CommActions = App.Data.Constants.Comm.Actions;

Bidder.hasEnoughDkpToBid = false;

function Bidder:startBidding(...)
    Utils:debug("Bidder:startBidding");

    App.BidderUI:show(...);
end

function Bidder:stopBidding()
    Utils:debug("Bidder:stopBidding");

    self.hasEnoughDkpToBid = false;

    App.BidderUI:hide();
end

-- Send a bid to auctioneer
function Bidder:bid(bid)
    Utils:debug("Bidder:bid");
    local bidIsNumerical, bid = pcall(function () return tonumber(bid); end);

    if (not bidIsNumerical or not bid) then
        Utils:error("Invalid bid, use numbers and periods (.) only");
    elseif (not App.Auction.inProgress) then
        Utils:error("There is no auction currently in progress");
    elseif (App.Auction.CurrentAuction.minimumBid > bid) then
        Utils:error("Your bid is lower than the minimum bid (" .. App.Auction.CurrentAuction.minimumBid .. " DKP)");
    elseif (App.User.Dkp.amount < bid) then
        Utils:error("You can't bid that much, you currently have " .. App.User.Dkp.amount .. " DKP");
    else
        -- Send our bid to the auctioneer
        App.CommMessage.new(
            CommActions.bid,
            {bid = bid},
            "WHISPER",
            App.Auction.CurrentAuction.auctioneer
        ):send();

        return true;
    end

    return false;
end

-- Retract your bid
function Bidder:retractBid()
    Utils:debug("Bidder:retractBid");

    App.CommMessage.new(
        CommActions.retractBid,
        {},
        "WHISPER",
        App.Auction.CurrentAuction.auctioneer
    ):send();
end

Utils:debug("Bidder.lua");