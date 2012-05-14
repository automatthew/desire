
def random_key
  (0...8).map{65.+(rand(25)).chr}.join
end

def get_timestamp
  (Time.now.to_f * 1000).floor * 1000
end

#require "redis"
#client = Redis.new
#client.select(3)
client = MockRedis.new

describe "Desire::SortedHash" do
  before(:each) do
    client.flushall
    @sorted_hash = Desire::SortedHash.new(client, "base_key")
  end

  describe "On instantiation" do

    before(:all) do
      @client = mock("unused Redis client")
    end

    specify "does not use redis" do
      Desire::SortedHash.new(@client, "namespace")
    end

    specify "has methods for retrieving the redis keys it uses" do
      sorted_hash = Desire::SortedHash.new(@client, "namespace")
      sorted_hash.index_key.should == "namespace.index"
      sorted_hash.hash_key.should == "namespace.store"
    end

  end

  describe "Usage" do
    before(:each) do
      client.flushall
      @sorted_hash = Desire::SortedHash.new(client, "base_key")
      @hash_key, @index_key = @sorted_hash.hash_key, @sorted_hash.index_key
    end

    describe "#set" do
      
      specify "adds the key, value, and score to the Redis Hash and ZSet" do
        @sorted_hash.set("key1", "value1", 128)

        client.hget(@hash_key, "key1").should == "value1"
        client.zscore(@index_key, "key1").should == "128"
      end

      specify "will overwrite an existing key's value and score" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.set("key1", "value2", 256)

        client.hget(@hash_key, "key1").should == "value2"
        client.zscore(@index_key, "key1").should == "256"
      end

      # this behavior is as opposed to that of #append
      specify "different keys may have the same score" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.set("key2", "value1", 128)
        client.zscore(@index_key, "key1").should == "128"
        client.zscore(@index_key, "key2").should == "128"
      end

    end

    describe "#update" do

      specify "modifies the value for the given key, but not the score" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.update("key1", "value2")
        client.hget(@hash_key, "key1").should == "value2"
        client.zscore(@index_key, "key1").should == "128"
      end

      specify "fails when the key has not already been set" do
        lambda {
          @sorted_hash.update("never_before", "never_again")
        }.should raise_error(ArgumentError)
      end

    end

    describe "#append" do

      specify "sets the score verbatim if the sorted_hash is empty" do
        @sorted_hash.append("key1", "value1", 128)
        client.hget(@hash_key, "key1").should == "value1"
        client.zscore(@index_key, "key1").should == "128"
      end

      specify "sets the score verbatim if all other scores are lower" do
        @sorted_hash.set("key1", "value1", 32)
        @sorted_hash.set("key2", "value2", 64)

        @sorted_hash.append("key3", "value3", 128)

        client.hget(@hash_key, "key3").should == "value3"
        client.zscore(@index_key, "key3").should == "128"
      end

      specify "adjusts the score to leapfrog any higher score" do
        @sorted_hash.set("key1", "value1", 32)
        @sorted_hash.set("key2", "value2", 64)
        @sorted_hash.set("key3", "value3", 256)

        @sorted_hash.append("key4", "value4", 128)

        client.hget(@hash_key, "key4").should == "value4"
        client.zscore(@index_key, "key4").to_i.should > 256
      end 

      specify "adjusts the score to leapfrog any equal score" do
        @sorted_hash.set("key1", "value1", 32)
        @sorted_hash.set("key2", "value2", 64)
        @sorted_hash.set("key3", "value3", 128)

        @sorted_hash.append("key4", "value4", 128)

        client.hget(@hash_key, "key4").should == "value4"
        client.zscore(@index_key, "key4").to_i.should > 128
      end 
    end

    describe "#get" do

      specify "returns the value set for the given key" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.get("key1").should == "value1"
      end

      specify "returns nil if the key does not exist" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.get("key2").should == nil
      end

    end

    describe "#keys" do

      specify "returns all existing keys" do
        ("a".."z").to_a.zip((1..26).to_a).each do |key, score|
          @sorted_hash.set(key, "value", score)
        end
        @sorted_hash.keys.sort.should == ("a".."z").to_a
      end

    end

    describe "#clear" do

      specify "deletes all underlying storage" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.clear
        client.exists(@hash_key).should == false
        client.exists(@index_key).should == false
      end

    end
    describe "#get_with_score" do

      specify "returns the value and score for the given key" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.get_with_score("key1").should == {:data => "value1", :score => "128"}
      end

      specify "returns nil if the key does not exist" do
        @sorted_hash.get_with_score("key2").should == nil
      end

    end


    describe "#delete" do

      specify "removes the key, value, and score from the underlying redis storage" do
        @sorted_hash.set("key1", "value1", 128)
        @sorted_hash.set("key2", "value2", 256)

        @sorted_hash.delete("key1", "key2")
        client.zscore(@index_key, "key1").should == nil
      end

      specify "does not fail when the key does not exist" do
        lambda {
          @sorted_hash.delete("bogus")
        }.should_not raise_error
      end

    end

    describe "#remove_by_range" do

      before(:each) do
        (1..16).each do |i|
          @sorted_hash.set("key#{i}", "value", i)
        end
      end

      specify "removes items with scores in the given range, start exclusive, stop inclusive" do
        @sorted_hash.remove_by_range(3, 5)

        client.hmget(@hash_key, *%w[key3 key4 key5 key6]).should == ["value", nil, nil, "value"]
        client.zcount(@index_key, 4, 5).should == 0
        client.zcard(@index_key).should == 14
      end

      specify "missing start param defaults to the lowest score" do
        @sorted_hash.remove_by_range(nil, 2)

        client.hmget(@hash_key, *%w[key1 key2 key3]).should == [nil, nil, "value"]
        client.zcount(@index_key, 0, 2).should == 0
        client.zcard(@index_key).should == 14
      end

      specify "missing stop param defaults to the highest score" do
        @sorted_hash.remove_by_range(14, nil)

        client.hmget(@hash_key, *%w[key14 key15 key16]).should == ["value", nil, nil]
        client.zcount(@index_key, 15, 16).should == 0
        client.zcard(@index_key).should == 14
      end

      specify "does not fail on an empty sorted hash"

    end

    describe "#truncate" do

      before(:each) do
        (1..16).each do |i|
          @sorted_hash.set("key#{i}", "value", i)
        end
      end

      specify "Truncates to threshold by removing lowest scoring elements" do
        @sorted_hash.truncate(12)
        client.hmget(@hash_key, *%w[key1 key2 key3 key4 key5]).should ==
          [nil, nil, nil, nil, "value"]
        client.zcount(@index_key, 0, 4).should == 0
        client.zcard(@index_key).should == 12
      end

      specify "Leaves things alone when the threshold has not been reached" do
        @sorted_hash.truncate(17)
        client.hlen(@hash_key).should == 16
        client.zcard(@index_key).should == 16
      end

      specify "does not fail on an empty sorted hash"

    end

  end

end

