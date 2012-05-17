
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

  attr_reader :client, :scope

  # Optional :scope will be used in generating the keys to be used
  # in the actual Redis storage.
  #
  # Has convenience methods for initializing Desire wrappers.
  #
  #   desire = Desire.new(redis_client, "myscope")
  #   hash = desire.hash("mykey")
  #   hash.key #=> "myscope.mykey"
  #
  # Includes Transaction, which provides #multi and #watch methods
  # so you can be sure you're using the right client at all times
  # in a transaction attempt.
  #
  #   hash = desire.hash("smurf")
  #   set = desire.set("seven_dwarfs")
  #   desire.multi do
  #     hash.hset("color", "blue")
  #     set.add("grumpy")
  #   end
  def initialize(client, options={})
    @client = client
    @scope = options[:scope]
  end

  def redis_key(key)
    @scope ? "#{scope}.#{key}" : key
  end

  {
    :hash => Desire::Hash,
    :list => Desire::List,
    :set => Desire::Set,
    :sorted_set => Desire::SortedSet
  }.each do |name, klass|
    class_eval <<-EVAL, __FILE__, __LINE__ + 1
      def #{name}(key)
        #{klass}.new(client, redis_key(key))
      end
    EVAL
  end

end

