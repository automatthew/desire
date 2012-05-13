require "desire/native/key"
require "desire/native/hash"
require "desire/native/set"
require "desire/native/sorted_set"

require "desire/composite"
require "desire/sorted_hash"

class Desire

  def initialize(client, options={})
    @client = client
    @scope = options[:scope]
  end

end

