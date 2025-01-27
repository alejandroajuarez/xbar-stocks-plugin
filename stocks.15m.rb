#!/usr/bin/env /Users/alejandro/.rbenv/shims/ruby

require 'net/http'
require 'uri'
require 'json'

# Fetch the API key from the environment variable
api_key = ENV['STOCKDATA_API_KEY']

# Validate the API key
if api_key.nil? || api_key.empty?
  puts "⚠️  API key is not set. Please set the STOCKDATA_API_KEY environment variable."
  exit 1
end

# Method to fetch stock data
def fetch_stock_data(api_key, ticker)
  base_url = "https://api.stockdata.org/v1/data/quote"
  uri = URI(base_url)
  params = {
    api_token: api_key,
    symbols: ticker # Single ticker
  }
  uri.query = URI.encode_www_form(params)

  begin
    response = Net::HTTP.get_response(uri)
  rescue StandardError => e
    puts "API Error: #{e.message}"
    return nil
  end

  unless response.is_a?(Net::HTTPSuccess)
    puts "API Request failed (HTTP #{response.code})"
    return nil
  end

  JSON.parse(response.body)["data"]
end

# Method to display stock data
def display_stock_data(stock_data, ticker)
  if stock_data.nil? || stock_data.empty?
    puts "No data available for ticker: #{ticker}"
    return
  end

  stock = stock_data.first
  ticker       = stock.fetch("ticker", "Unknown")
  name         = stock.fetch("name", "")
  price        = stock.fetch("price", "N/A")
  day_high     = stock.fetch("day_high", "N/A")
  day_low      = stock.fetch("day_low", "N/A")
  week_52_high = stock.fetch("52_week_high", "N/A")
  week_52_low  = stock.fetch("52_week_low", "N/A")
  volume       = stock.fetch("volume", "N/A")
  day_change   = stock.fetch("day_change", "N/A")

  arrow = day_change.to_f >= 0 ? "▲" : "▼"
  color = day_change.to_f >= 0 ? "\e[32m" : "\e[31m" # Green for positive, red for negative

  puts "\nStock Information for #{ticker} (#{name}):"
  puts "=" * 40
  puts "  Price: $#{price} #{color}#{arrow} #{day_change}%\e[0m"
  puts "  Day High: $#{day_high}"
  puts "  Day Low: $#{day_low}"
  puts "  52-Week High: $#{week_52_high}"
  puts "  52-Week Low: $#{week_52_low}"
  puts "  Volume: #{volume}"
  puts "=" * 40
end

# Main app loop
loop do
  # Prompt user for a stock ticker
  puts "\nEnter a stock ticker (e.g., AAPL, TSLA, NVDA) or 'q' to quit:"
  input = gets.chomp.strip.upcase

  break if input == 'Q'

  # Fetch and display data for the entered ticker
  stock_data = fetch_stock_data(api_key, input)
  puts "DEBUG: Raw API response:"
  puts stock_data.inspect # Debugging line to inspect the response
  display_stock_data(stock_data, input)
end

puts "Goodbye! 👋"