# Rakefile for day.rb
# Author: Cameron Carroll; December 2013
# Purpose: Compiles a single-file version of the program for easy distribution and installation.
#          Also increments version numbers based on VERSION file.

puts "Day.rb Build Tool"
puts "-----------------"

task :default => [:update_version, :compile]

task :update_version do
  current_version = nil
  open('VERSION', 'r') do |file|
    current_version = file.gets
  end

  previous_version = (current_version.to_f - 0.1).round(2).to_s
  next_version = (current_version.to_f + 0.1).round(2).to_s

  puts "Current Version: #{current_version}"

  # Unlikely to happen, but if the source files get ahead of VERSION file we should warn and break.
  next_version_in_dayrb = `grep #{next_version} day.rb`.length > 0
  next_version_in_readme = `grep #{next_version} readme.md`.length > 0

  if next_version_in_dayrb || next_version_in_readme
    puts "VERSION file is behind source files! Breaking; Please fix manually."
    abort
  end

  # Check authoritative version source (VERSION FILE) against source files.
  # If source files have an older version, update it.
  old_version_in_dayrb = `grep #{previous_version} day.rb`.length > 0
  old_version_in_readme = `grep #{previous_version} readme.md`.length > 0

  if !old_version_in_readme && !old_version_in_dayrb
    puts "Didn't find any old versions. Skipping to compilation."
    Rake::Task['compile'].invoke
  end

  if old_version_in_dayrb
    puts "Replacing version #{previous_version} with #{current_version} in day.rb"
    `sed -i 's/#{previous_version}/#{current_version}/g' day.rb`
  end

  if old_version_in_readme
    today_date = Time.new.strftime("%m/%d/%y")
    puts "Replacing version #{previous_version} with #{current_version} in readme.md"
    puts "Replacing old date with #{today_date} in day.rb"
    `sed -i 's/#{previous_version}/#{current_version}/g' readme.md`
    `sed -i 's%[0-9][0-9]/[0-9][0-9]/[0-9][0-9])%#{today_date})%' readme.md`
  end
end

task :compile do
  `mkdir -p "build"`
  target = "build/day.rb"

  `cat /dev/null > #{target}`

  # First we need to get the first 36 lines of day.rb, which includes intro comments
  # and user configuration. 
  # But we want to strip off the require statements and the whitespace leftover.
  `awk 'NR >= 1 && NR <= 36' day.rb | sed 's/require_relative.*//g' | uniq >> #{target}`

  # Add all library files:
  FileList['lib/*.rb'].each do |source|
    `cat #{source} >> #{target}`
    `echo "\n" >> #{target}`
  end

  # Now finally we want to add the remaining body of day.rb
  lines_in_dayrb = `wc -l day.rb`.to_i
  `awk 'NR >= 37 && NR <= #{lines_in_dayrb+1}' day.rb >> #{target}`
end