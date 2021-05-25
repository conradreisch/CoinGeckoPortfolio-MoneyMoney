-- Inofficial CoinGecko Extension for MoneyMoney
-- Fetches coin prices via CoinGecko website
-- Returns tickers as securities
--
-- Username: Comma seperated coin symbol with amount of coins in brackets (Example: "POLKADOT(10),CARDANO(100)")
-- Password: No password required.

-- MIT License

-- Original work Copyright 2021 Conrad Reisch

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 1.0,
  country = "de",
  description = "Include your crypto currency in MoneyMoney by providing the crypto symbols and the number of coins as username. Example: POLKADOT(10),CARDANO(100)",
  services= { "CoinGeckoPortfolio" }
}

local coinSymbols
local connection = Connection()
local currency = "EUR"

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "CoinGeckoPortfolio"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
        coinSymbols = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "CoinGeckoPortfolio",
    accountNumber = "CoinGeckoPortfolio",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end


function RefreshAccount (account, since)
        local s = {}

        -- Create substring with stock information from comma separated input
        for coin in string.gmatch(coinSymbols, '([^,]+)') do

                -- Extract Market, Ticker, Quantity and Currency from substring
                -- Pattern: POLKADOT(10),CARDANO(100)
                coinID=coin:match("([^(]+)")
                coinQuantity=coin:match("%((%S+)%)")

                -- Retrieve JSON from Coingecko as a basis for extracting price and name
                coinJSON = requestCurrentCoinPriceJSON(coinID)

                -- Create new stock item and put is to the list
                s[#s+1] = {
                        name = coinID,
                        securityNumber = coinID,
                        market = "CoinGecko",
                        currency = nil,
                        quantity = coinQuantity,
                        price = requestCurrentCoinPrice(coinID),
                        currencyOfPrice = currency,
                                                exchangeRate = 1.0
                                }

        end

        return {securities = s}
end


function EndSession ()
        connection:close()
end



-- Query Functions
function requestCurrentCoinPrice(coinId)
        return requestCurrentCoinPriceJSON(coinId):dictionary()[string.lower(coinID)][string.lower(currency)]
end

function requestCurrentCoinPriceJSON(coinId)
        return JSON(connection:request("GET", coinPriceRequestUrl(coinId)))
end


-- URL Helper Functions
function coinPriceRequestUrl(coinId)
        return "https://api.coingecko.com/api/v3/simple/price?ids=" .. coinId .. "&vs_currencies=" .. currency
end

-- SIGNATURE: MC0CFQCA7halubyyth8b74rg3F2p0y9uDwIUf/aQr6Xx+a0VapYoHSVUTeSE1gE=
