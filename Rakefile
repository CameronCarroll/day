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

  puts "Current Version: #{current_version}"

  split_version = current_version.split('.')

  next_patch_version = update_patch(split_version, 1)
  previous_patch_version = update_patch(split_version, -1)

  next_minor_version = update_minor(split_version, 1)
  previous_minor_version = update_minor(split_version, -1)

  next_major_version = update_major(split_version, 1)
  previous_major_version = update_major(split_version, -1)

  previous_versions = [previous_patch_version, previous_minor_version, previous_major_version]
  next_versions = [next_patch_version, next_minor_version, next_major_version]

  # Unlikely to happen, but if the source files get ahead of VERSION file we should warn and break.
  next_versions.each do |version|
    next_version_in_dayrb = `grep #{version} day.rb`.length > 0
    next_version_in_readme = `grep #{version} readme.md`.length > 0

    if next_version_in_dayrb || next_version_in_readme
      puts "VERSION file is behind source files! Breaking; Please fix manually."
      abort
    end
  end

  
  old_version_in_readme, old_version_in_dayrb, old_version = nil, nil, nil

  # Check authoritative version source (VERSION file) against source files.
  # If source files have an older version, update it.
  previous_versions.each do |version|
    unless old_version_in_dayrb && old_version_in_readme
      old_version_in_dayrb = `grep #{version} day.rb`.length > 0
      old_version_in_readme = `grep #{version} readme.md`.length > 0
      old_version = version if old_version_in_readme || old_version_in_dayrb
      puts "Version in question: " + version if old_version
    end
  end
  

  if old_version_in_dayrb
    puts "Replacing version #{old_version} with #{current_version} in day.rb"
    `sed -i 's/#{old_version}/#{current_version}/g' day.rb`
  end

  if old_version_in_readme
    today_date = Time.new.strftime("%m/%d/%y")
    puts "Replacing version #{old_version} with #{current_version} in readme.md"
    puts "Replacing old date with #{today_date} in day.rb"
    `sed -i 's/#{old_version}/#{current_version}/g' readme.md`
    `sed -i 's%[0-9][0-9]/[0-9][0-9]/[0-9][0-9])%#{today_date})%' readme.md`
  end

  if !old_version_in_dayrb && !old_version_in_readme
    puts "Didn't find any version errors."
  end
end

task :compile do
  `mkdir -p "build"`
  target = "build/day.rb"

  `cat /dev/null > #{target}`

  # First we need to get the first 36 lines of day.rb, which includes intro comments
  # and user configuration. 
  # But we want to strip off the require statements and the whitespace leftover.
  `awk 'NR >= 1 && NR <= 41' day.rb | sed 's/require_relative.*//g' | uniq >> #{target}`

  # Add all library files:
  FileList['lib/*.rb'].each do |source|
    `cat #{source} >> #{target}`
    `echo "\n" >> #{target}`
  end

  # Now finally we want to add the remaining body of day.rb
  lines_in_dayrb = `wc -l day.rb`.to_i
  `awk 'NR >= 46 && NR <= #{lines_in_dayrb+1}' day.rb >> #{target}`
end

def update_patch(split_version, increment)
  different_patch = split_version[2].to_i + increment
  different_patch_version = split_version[0..1].push(different_patch)
  different_patch_version.join('.')
end

def update_minor(split_version, increment)
  different_minor = split_version[1].to_i + increment
  different_minor_version = [split_version[0],different_minor,split_version[2]]
  different_minor_version.join('.')
end

def update_major(split_version, increment)
  different_major = split_version[0].to_i + increment
  different_major_version = split_version[1,2].unshift(different_major)
  different_major_version.join('.')
end