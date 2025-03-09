#!/usr/bin/env ruby

require 'net/http'
require 'uri'

# The URL from the markdown file
BASE_URL = 'https://gugquettex.com/en/project/stinomxe/index.php'

def fetch_url(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)

  if response.is_a?(Net::HTTPSuccess)
    response.body
  else
    puts "Failed to fetch #{url}: #{response.code} #{response.message}"
    nil
  end
rescue StandardError => e
  puts "Error fetching #{url}: #{e.message}"
  nil
end

def extract_ruby_file_links(html_content)
  return [] unless html_content

  # Simple regex to find links containing "StinomXE" and either "peek" or "download"
  links = html_content.scan(/href="([^"]*StinomXE[^"]*(?:peek|download)[^"]*)"/)
  links.flatten.uniq
end

def save_ruby_file(content, filename)
  return unless content

  # Sanitize filename
  safe_filename = filename.gsub(/[^a-zA-Z0-9\-_.]/, '_')

  # Create a downloads directory if it doesn't exist
  Dir.mkdir('downloads') unless Dir.exist?('downloads')

  File.write(File.join('downloads', safe_filename), content)
  puts "Saved #{safe_filename}"
rescue StandardError => e
  puts "Error saving #{filename}: #{e.message}"
end

def analyze_ruby_file(content)
  return unless content

  puts "\nAnalysis:"
  puts '=' * 40
  puts "File size: #{content.bytesize} bytes"
  puts "Number of lines: #{content.lines.count}"

  # Count certain Ruby keywords
  keywords = %w[def class module if else end]
  keyword_counts = keywords.map do |keyword|
    count = content.scan(/\b#{keyword}\b/).count
    "#{keyword}: #{count}"
  end

  puts "\nKeyword counts:"
  puts keyword_counts.join(', ')

  puts "\nFirst few lines:"
  puts content.lines.first(5)
end

# Main execution
puts 'Fetching main page...'
main_page = fetch_url(BASE_URL)

if main_page
  puts 'Extracting Ruby file links...'
  links = extract_ruby_file_links(main_page)

  if links.empty?
    puts 'No Ruby file links found!'
  else
    puts "Found #{links.count} links to process"

    links.each do |link|
      puts "\nProcessing: #{link}"
      absolute_url = URI.join(BASE_URL, link).to_s
      content = fetch_url(absolute_url)

      next unless content

      filename = link.split('/').last || 'unknown_file.rb'
      save_ruby_file(content, filename)
      analyze_ruby_file(content)
    end
  end
else
  puts 'Failed to fetch main page. Exiting.'
end
