client = MockRedis.new

describe "Desire::Native::Hash" do

  describe "Instantiation" do

    specify "does not use redis or the collection class" do
      Desire::Native::Hash.new(mock("redis"), "some_key")
    end

    specify "has methods for retrieving the redis keys it uses" do
      hash = Desire::Native::Hash.new(mock("redis"), "some_key")
      hash.key.should == "some_key"
    end

  end

  describe "Usage" do
    before(:each) do
      client.flushall
      @desire = Desire.new(client)
      @hash = @desire.hash("some_key")
    end

    specify "#each yields key and value" do
      @hash[:foo] = :bar
      @hash[:baz] = :bat
      h = {}
      @hash.each {|k,v| h[k] = v }
      h.should == {"foo" => "bar", "baz" => "bat"}
    end

    specify "#merge! HMSETs the given values" do
      @hash[:key1] = :foo
      @hash[:key2] = :bar
      @hash.merge!(:key2 => :smurf, :key3 => :baz, :key4 => :bat)
      @hash.hgetall.should == {
        "key1" => "foo",
        "key2" => "smurf",
        "key3" => "baz",
        "key4" => "bat"
      }
    end

  end

end
