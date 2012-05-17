
require "desire/helpers"

require "desire/native/key"
require "desire/native"
require "desire/native/list"
require "desire/native/hash"
require "desire/native/set"
require "desire/native/sorted_set"

require "desire/transaction"

require "desire/collector"
require "desire/time_slicer"
require "desire/sorted_hash"


class Desire
  include Transaction

  attr_reader :client

  # The client should be an instance of redis-rb's Redis class,
  # or it should act like one.
  def initialize(client)
    @client = client
  end

  # Define convenience methods for instantiating wrapper classes.
  {
    :hash => Desire::Hash,
    :list => Desire::List,
    :set => Desire::Set,
    :sorted_set => Desire::SortedSet,
    :sorted_hash => Desire::SortedHash
  }.each do |name, klass|
    class_eval <<-EVAL, __FILE__, __LINE__ + 1
      def #{name}(key)
        #{klass}.new(client, key)
      end
    EVAL
  end

end

