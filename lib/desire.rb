require "desire/native/key"
require "desire/native/hash"
require "desire/native/set"
require "desire/native/sorted_set"

require "desire/composite"
require "desire/collector"
require "desire/time_slicer"
require "desire/sorted_hash"

class Desire

  attr_reader :client, :scope
  def initialize(client, options={})
    @client = client
    @scope = options[:scope]
  end

  def hash(key)
    Hash.new(client, "#{scope}.#{key}")
  end

end

