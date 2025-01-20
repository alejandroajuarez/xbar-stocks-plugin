#!/usr/bin/env ruby

# <xbar.title>3-Stock Tracker</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Alejandro Juarez</xbar.author>
# <xbar.author.github>alejandroajuarez</xbar.author.github>
# <xbar.desc>Track 3 stocks that renew every 15 mins!</xbar.desc>
# <xbar.dependencies>Ruby</xbar.dependencies>
# <xbar.abouturl>https://github.com/matryer/xbar</xbar.abouturl>

require 'net/http'
require 'uri'
require 'json'

api_key = ENV['STOCKDATA_API_KEY'] || "EhAz6JC0cgsa1790WocIjxo5C1AA2ugr07YC7TtL"

tickers = "NVDA,AVGO,TSLA"

base_url = "https://api.stockdata.org/v1/data/quote"
uri = URI(base_url)
params = {
  api_token: api_key,
  symbols: tickers
}
uri.query = URI.encode_www_form(params)
puts "DEBUG: API key is: #{api_key}" if api_key.nil? || api_key.empty?

begin
  response = Net::HTTP.get_response(uri)
rescue StandardError => e
  puts "API Error: #{e.message}"
  exit
end

unless response.is_a?(Net::HTTPSuccess)
  puts "API Request failed (HTTP #{response.code})"
  exit
end

data = JSON.parse(response.body)
stock_quotes = data["data"]

unless stock_quotes && !stock_quotes.empty?
  puts "No stock data available"
  exit
end

# Build the menu bar output
menu_output = stock_quotes.map do |stock|
  symbol = stock["symbol"]
  price  = stock["price"]
  "#{symbol}: $#{price}"
end.join(" | ")

puts menu_output

# Separator indicating the dropdown section
puts "---"

# Detailed output for each stock
stock_quotes.each do |stock|
  symbol      = stock["symbol"]
  name        = stock["name"] || ""
  price       = stock["price"]
  day_change  = stock["day_change"]
  change_pct  = stock["day_change_pct"]

  # Use an arrow symbol based on price change
  if day_change.to_f >= 0 
    arrow      = "▲"
    line_color = "green"
  else
    arrow      = "▼"
    line_color = "red"
  end

  # Print the detailed line with xbar color formatting
  puts "#{symbol} (#{name}): $#{price} #{arrow} #{day_change} (#{change_pct}%) | color=#{line_color}"
end

# Provide a refresh option
puts "---"
puts "Refresh | refresh=true"

puts "DEBUG: API key is: #{api_key}" if api_key.nil? || api_key.empty?
