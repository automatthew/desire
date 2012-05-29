#$version = File.read("VERSION").chomp
$authors = []
$emails = []
File.open "AUTHORS","r" do |file|
  authors = file.read
  authors.split("\n").map do |author|
    name, email = author.split("\t")
    $authors << name ; $emails << email
  end
end

Gem::Specification.new do |s|
  s.name        = 'desire'
  s.version     = "0.5.5"
  s.summary     = "Ruby client for spire.io"
  s.description = <<-EOF
		Wrappers for Redis.
  EOF
  s.authors     = $authors
  s.email       = $emails
  s.require_path = "lib"
  s.files       = Dir["lib/desire/**/*.rb"] + %w[lib/desire.rb]
  s.homepage    =
    'https://github.com/spire-io/desire'
	s.add_runtime_dependency "redis", ["~> 2.2"]
	s.add_runtime_dependency "json", ["~> 1.6"]
	s.add_development_dependency "rspec", ["~> 2.7"]
  s.add_development_dependency "mock_redis", ["~> 0.4"]
  s.add_development_dependency "yard", ["~> 0.8"]
end
