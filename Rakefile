require "pp"

desc "update with necessary dependencies"
task "update" do
  str = File.read("desire.gemspec")
  gemspec = eval(str)
  gemspec.dependencies.each do |dep|
    sh "gem install #{dep.name} -v '#{dep.requirement}'"
  end
end

desc "Run the tests in ./test/unit/"
task "test:unit" do
  files = FileList["test/unit/*.rb"]
  TaskHelpers.rspec(
    :require => "test/setup.rb",
    :files => files
  )
end


desc "run yardoc"
task "doc" do
	sh "yard --output doc/yard"
end

desc "Update GitHub pages"
task "doc:pages" => %w[ doc/yard/ doc/yard/.git doc ] do
  rev = `git rev-parse --short HEAD`.strip
  Dir.chdir 'doc/yard' do
    last_commit = `git log -n1 --pretty=oneline`.strip
    message = "rebuild pages from #{rev}"
    result = last_commit =~ /#{message}/
    # generating yardocs causes updates/modifications in all the docs
    # even when there are changes in the docs (it updates the date/time)
    # So we check if the last commit message if the hash is the same do NOT update the docs
    if result
      verbose { puts "nothing to commit" }
    else
      sh "git add ."
      sh "git commit -m 'rebuild pages from #{rev}'" do |ok,res|
        if ok
          verbose { puts "gh-pages updated" }
          sh "git push -q origin HEAD:gh-pages"
        end
      end
    end
  end
  puts "Docs pushed to:"
  puts "http://spire-io.github.com/desire/"
end

directory "doc/yard"

# Update the pages/ directory clone
file 'doc/yard/.git' => ['doc/yard/', '.git/refs/heads/gh-pages'] do |f|
    sh "cd doc/yard && git init -q && git remote add origin git@github.com:spire-io/desire.git" if !File.exist?(f.name)
    sh "cd doc/yard && git fetch -q origin && git reset -q --hard origin/gh-pages && touch ."
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
