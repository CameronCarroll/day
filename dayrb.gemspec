Gem::Specification.new do |s|
  s.name        = 'dayrb'
  s.version     = '2.0.4'
  s.summary     = "To-do & Time-Tracking CLI App"
  s.description = "Create and track time on tasks via command-line."
  s.authors     = ["Cameron Carroll"]
  s.email       = 'ckcarroll4@gmail.com'
  s.files       = `git ls-files`.split($/)
  s.executables =  s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.homepage    =
    'http://github.com/sanarothe/day'
  s.license       = 'MIT'
end
