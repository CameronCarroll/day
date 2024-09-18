Gem::Specification.new do |s|
  s.name        = 'dayrb'
  s.version     = '2.0.6'
  s.required_ruby_version = '>= 3.0'
  s.summary     = "To-do & Time-Tracking CLI App"
  s.description = "Create and track time on tasks via command-line."
  s.authors     = ["Cam Carroll"]
  s.email       = 'ckcarroll4@gmail.com'
  s.files       = `git ls-files`.split($/)
  s.executables =  s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.homepage    =
    'http://github.com/CameronCarroll/day'
  s.license       = 'MIT'
end
