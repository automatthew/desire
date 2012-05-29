#require "redis"
#client = Redis.new
client = MockRedis.new

describe "StorageMeter" do

  describe "Instantiation" do

    specify "does not use redis or evaluate the block" do
      Desire::StorageMeter.new(mock("redis"), "base") do |subkey|
        raise "This should not run"
      end
    end

    specify "has methods for retrieving the redis keys it uses" do
      meter = Desire::StorageMeter.new(mock("redis"), "base") do |subkey|
        raise "This should not run"
      end
      meter.collector_key.should == "base.meters"
    end

  end

  describe "Usage" do
    before(:each) do
      client.flushall
      @meter_key = "account_key"
      @meter = Desire::StorageMeter.new(client, @meter_key)
    end

    specify "#[] retrieves a KeyMeter for the supplied key" do
      key_meter = @meter["resource_key"]
      key_meter.should be_a_kind_of Desire::KeyMeter
    end

    describe "KeyMeter" do

      before(:each) do
        @key_meter = @meter["resource_key"]
        @key_meter_key = "account_key.meters.resource_key"
      end

      specify "#update sets a score in the sorted set and increments the totals" do
        @key_meter.update("subkey1", 32)
        @key_meter.update("subkey2", 64)
        @meter.flush

        array = client.zrange(@key_meter_key, 0, -1, :withscores => true)
        Hash[*array].should == {"total" => "96", "subkey1" => "32", "subkey2" => "64"}
        client.hget("account_key", "total").should == "96"
      end

      specify "#update increments the subtotal appropriately over repeats" do
        @key_meter.update("subkey1", 32)
        # TODO: make StorageMeter smart about multiple updates of 
        # the same subkey before flushing
        @meter.flush

        @key_meter.update("subkey1", 64)
        @meter.flush

        @key_meter.update("subkey1", 12)
        @meter.flush

        @meter.total.should == 12
        @key_meter.total.should == 12
      end

      specify "#delete does something smart if the subkey does not exist"

      specify "#delete retrieves the score, zrems the item, and decrements meters" do
        @key_meter.update("subkey1", 32)
        @key_meter.update("subkey2", 64)
        @meter.flush

        @key_meter.delete("subkey2")
        @meter.flush

        array = client.zrange(@key_meter_key, 0, -1, :withscores => true)
        Hash[*array].should == {"total" => "32", "subkey1" => "32"}
        client.hget("account_key", "total").should == "32"
        client.zscore(@key_meter_key, "subkey2").should == nil
      end

      specify "#total retrieves the current total" do
        @key_meter.update("subkey1", 32)
        @key_meter.update("subkey2", 64)
        @meter.flush

        @key_meter.total.should == 96
      end

      specify "#clear decrs the storage_meter and dels the key_meter" do
        @meter["key1"].update("subkey", 32)
        @meter["key2"].update("subkey", 64)
        @meter.flush

        @meter["key1"].clear
        @meter.flush

        @meter.total.should == 64
        client.exists("account_key.meters.key1").should be_false
        client.exists("account_key.meters.key2").should be_true
      end

    end

    specify "#total is 0 if nothing has been metered" do
      @meter.total.should == 0
    end

    specify "#total works with more than one key_meter used" do
      @meter["resource1"].update("subkey1", 100)
      @meter["resource1"].update("subkey2", 100)
      @meter["resource1"].update("subkey3", 100)

      @meter["resource2"].update("subkey1", 100)
      @meter["resource2"].update("subkey2", 100)
      @meter["resource2"].update("subkey3", 100)
      @meter.flush
      @meter["resource2"].delete("subkey1")
      @meter.flush

      @meter.total.should == 500
    end

    specify "#subtotal returns the total for the key" do
      @meter["resource1"].update("subkey1", 100)
      @meter["resource1"].update("subkey2", 100)
      @meter["resource1"].update("subkey3", 100)

      @meter["resource2"].update("subkey1", 10)
      @meter["resource2"].update("subkey2", 10)
      @meter["resource2"].update("subkey3", 10)
      @meter.flush

      @meter.subtotal("resource2").should == 30
    end

  end

end


