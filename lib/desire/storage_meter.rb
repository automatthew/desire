class Desire

  class StorageMeter

    # Usage:
    # meter = StorageMeter.new(client, "Ac-Gb7w2.storage_meter")
    # meter["Ac-Gb7w2"].update("name", 27)
    # meter["Ac-Gb7w2"].update("email", 55)
    # meter["Ac-Gb7w2"].update("origins", 233)

    # meter["Su-uv73t"].update("name", 22)

    # meter["Ch-asd8W"].update("name", 14)
    # meter["Ch-asd8W"].update("Me-38bys", 135)
    # meter["Ch-asd8W"].delete("Me-f4s5", 257)

    def initialize(client, base_key, options={})
      @client = client
      @base_key = base_key
      @collector_key = "#{@base_key}.collector"
      @collector = Collector.new(client, Desire::SortedSet, @collector_key)
    end

    def total
      client.get(@base_key).to_i
    end

    def subtotal(key)
      self[key].zscore("total")
    end

    # expensive!
    def recompute!
      raise "unimplemented"
    end

    def [](key)
      @collector.get(key)
    end

    def update(subkey, bytes)
      zset = @collector.get(subkey)
      zset.zadd(subkey, bytes)
      zset.incrby("total", bytes)
      client.incrby(@base_key, bytes)
    end

    def delete(subkey, bytes)
      zset = @collector.get(subkey)
      bytes = zset.zscore(subkey).to_i
      zset.zrem(subkey)
      zset.incrby("total", -bytes)
      client.incrby(@base_key, -bytes)
    end

  end

end
