require "pp"

desc "update with necessary dependencies"
task "update" do
  str = File.read("desire.gemspec")
  gemspec = eval(str)
  gemspec.dependencies.each do |dep|
    sh "gem install #{dep.name} -v '#{dep.requirement}'"
  end
end

task "test:unit" do
  files = FileList["test/unit/*.rb"]
  TaskHelpers.rspec(
    :require => "test/setup.rb",
    :files => files
  )
end



module TaskHelpers

  def self.rspec(options)
    flags = %w[
      --color
      --format documentation
    ]
    if file = options[:require]
      flags += [ "--require", file ]
    end
    flags += options[:files]
    if example = ENV["example"]
      flags += [ "--example", example ]
    end

    puts "rspec #{flags.join(' ')}"
    require "rspec"
    RSpec.configure do |config|
      config.mock_framework = :rspec
    end

    status = RSpec::Core::Runner.run(flags)
    if status != 0
      exit(status)
    end

  end

end
