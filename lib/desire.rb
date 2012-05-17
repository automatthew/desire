
require "desire/helpers"

require "desire/native/key"
require "desire/native"
require "desire/native/list"
require "desire/native/hash"
require "desire/native/set"
require "desire/native/sorted_set"

require "desire/composite"
require "desire/collector"
require "desire/time_slicer"
require "desire/sorted_hash"


class Desire

  attr_reader :client, :scope

  # Optional :scope will be used in generating the keys to be used
  # in the actual Redis storage.
  def initialize(client, options={})
    @client = client
    @scope = options[:scope]
  end

  def redis_key(key)
    @scope ? "#{scope}.#{key}" : key
  end

  def hash(key)
    Desire::Hash.new(client, redis_key(key))
  end

end

