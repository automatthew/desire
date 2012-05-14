require "rubygems"
require "mock_redis"

here = File.dirname(__FILE__)
DESIRE_ROOT = File.expand_path("#{here}/..")
$LOAD_PATH.unshift("#{DESIRE_ROOT}/lib")

require "desire"

