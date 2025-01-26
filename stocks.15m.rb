#!/usr/bin/env ruby
# <xbar.title>3-Stock Tracker</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Alejandro Juarez</xbar.author>
# <xbar.author.github>alejandroajuarez</xbar.author.github>
# <xbar.desc>Track 3 stocks that renew every 15 mins!</xbar.desc>
# <xbar.dependencies>Ruby</xbar.dependencies>
# <xbar.abouturl>https://github.com/alejandroajuarez/xbar-stocks-plugin</xbar.abouturl>
#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

api_key = ENV['STOCKDATA_API_KEY']
unless api_key && !api_key.empty?
  puts "⚠ API key not set"
  puts "---"
  puts "Set the STOCKDATA_API_KEY environment variable."
  exit
end

ticker = "NVDA"

base_url = "https://api.stockdata.org/v1/data/quote"
uri = URI(base_url)
params = {
  api_token: api_key,
  symbols: ticker
}
uri.query = URI.encode_www_form(params)

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
# Debug the raw API response
# puts "DEBUG: Raw API response:"
# puts data.inspect

# Extract stock quotes
stock_quotes = data["data"]

# Check if stock_quotes is valid
if stock_quotes.nil? || stock_quotes.empty?
  puts "No stock data available"
  exit 1
end

# Construct the menu output
menu_output = stock_quotes.map do |stock|
  ticker = stock.fetch("ticker", "Unknown")
  price  = stock.fetch("price", "N/A")
  "#{ticker}: $#{price}"
end.join(" | ")

# Print the menu output (top-level xbar menu)
puts menu_output

# Separator for the dropdown
puts "---"

# Detailed dropdown for each stock
stock_quotes.each do |stock|
  ticker      = stock.fetch("ticker", "Unknown")
  name        = stock.fetch("name", "")
  price       = stock.fetch("price", "N/A")
  day_change  = stock.fetch("day_change", "N/A")

  # Arrow and color based on day_change
  if day_change.to_f >= 0
    arrow = "▲"
    color = "green"
  else
    arrow = "▼"
    color = "red"
  end

  # Detailed output for each stock
  puts "#{ticker} (#{name}): $#{price} #{arrow} #{day_change} | color=#{color}"
end


# Provide a refresh option
puts "---"
puts "Refresh | refresh=true"