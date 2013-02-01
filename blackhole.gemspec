Gem::Specification.new do |s|
  s.name        = 'blackhole'
  s.version     = '0.1.0'
  s.date        = '2013.02.01'
  s.summary     = "This will tug everything."
  s.description = "The blackhole is a UDP listening server. IT store udp packets into mongodb"
  s.authors     = ["Kim, SeongSik"]
  s.email       = 'kssminus@gmail.com'
  s.files       = ["lib/*.rb"]
  s.bindir      = 'bin'
  s.homepage    = 'http://github.com/kssminus/blackhole'
  
  s.add_runtime_dependency 'em-mongo', '~> 0.4.2'       # For the EM collector
  s.add_runtime_dependency 'mongo', '~> 1.6'
  s.add_runtime_dependency 'bson_ext', '~> 1.6'
  s.add_runtime_dependency 'eventmachine', '~> 0.12.10'

  s.executables << 'blackhole'

  s.required_ruby_version       = ">= 1.9.0"
end
