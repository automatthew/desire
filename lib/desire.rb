
require "desire/helpers"

require "desire/key"
require "desire/transaction"
require "desire/native"
require "desire/composite"

require "desire/native/list"
require "desire/native/hash"
require "desire/native/set"
require "desire/native/sorted_set"


require "desire/v0/composites"
require "desire/v1/composites"



# A convenience wrapper for instantiating the actual Desire wrapper classes
# used in an application.
#
# Usage:
# 
#   desire = Desire.new(redis)
#   hash = desire.hash("redis_key_for_hash")
#   zset = desire.sorted_set("some_other_key")
#
# The composite wrappers are versioned, but the classes considered stable
# can be accessed as constants in the Desire namespace:
#
#   Desire::SortedHash #=> Desire::V0::SortedHash
class Desire
  include Transaction

  # Look for missing classes under the current default convention version
  def self.const_missing(name)
    V0.const_get(name)
  end

  attr_reader :client

  # The client should be an instance of redis-rb's Redis class,
  # or it should act like one.
  def initialize(client, options={})
    @client = client
    @options = options
  end

  # Define convenience methods for instantiating wrapper classes.
  {
    # Native
    :hash => Desire::Native::Hash,
    :list => Desire::Native::List,
    :set => Desire::Native::Set,
    :sorted_set => Desire::Native::SortedSet,

    # Composites
    :sorted_hash => Desire::SortedHash,
    #:collector => Desire::Collector,
    :time_slicer => Desire::TimeSlicer,
  }.each do |name, klass|
    class_eval <<-EVAL, __FILE__, __LINE__ + 1
      def #{name}(key)
        #{klass}.new(client, key)
      end
    EVAL
  end

end

