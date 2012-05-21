class Desire

  # Usage:
  #   meter = StorageMeter.new(client, "Ac-Gb7w2.storage")
  #   meter["Ac-Gb7w2"].update("name", 27)
  #   meter["Ac-Gb7w2"].update("email", 55)
  #   meter["Ac-Gb7w2"].update("origins", 233)
  #
  #   meter["Su-uv73t"].update("name", 22)
  #
  #   meter["Ch-asd8W"].update("name", 14)
  #   meter["Ch-asd8W"].update("Me-38bys", 135)
  #   meter["Ch-asd8W"].delete("Me-f4s5", 257)
  class StorageMeter


    attr_reader :collector_key, :collection

    # @param [Redis] client Duck typed to redis-rb 2.2.2
    # @param [#to_s] base_key Base key, to be used as a prefix for internally managed keys
    def initialize(client, base_key)
      @client = client
      @base_key = base_key
      @storage_meter = Native::Hash.new(client, @base_key)
      @total_key = "total"

      @collector_key = "#{@base_key}.meters"
      @collector = V0::Collector.new(client, @collector_key) do |subkey|
        zset = Native::SortedSet.new(client, subkey)
        meter = KeyMeter.new(self, zset)
      end
    end

    def incrby(bytes)
      @storage_meter.hincrby(@total_key, bytes)
    end

    def total
      @storage_meter.hget(@total_key).to_i
    end

    def subtotal(key)
      self[key].total
    end

    def [](key)
      @collector.get(key)
    end

    # expensive!
    def recompute!
      raise "unimplemented"
    end

  end

  class KeyMeter
    attr_reader :storage_meter, :key_meter

    def initialize(storage_meter, key_meter)
      @storage_meter = storage_meter
      @key_meter = key_meter
      @total_key = "total"
    end

    def update(subkey, bytes)
      key_meter.zadd(bytes, subkey)
      key_meter.zincrby(bytes, @total_key)
      storage_meter.incrby(bytes)
    end

    def delete(subkey)
      bytes = key_meter.zscore(subkey).to_i
      key_meter.zrem(subkey)
      key_meter.zincrby(-bytes, @total_key)
      storage_meter.incrby(-bytes)
    end

    def total
      key_meter.zscore(@total_key).to_i
    end

  end

end
