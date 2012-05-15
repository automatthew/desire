client = MockRedis.new

class TestClass
  def initialize(client, key)
  end
end

describe "Desire::Collector" do
  before(:each) do
    #client.flushall
  end

  describe "Instantiation" do

    specify "does not use redis or the collection class" do
      Desire::Collector.new(mock("redis"), mock("desire class"), "namespace")
    end

    specify "has methods for retrieving the redis keys it uses" do
      collector = Desire::Collector.new(mock("redis"), mock("desire class"), "namespace")
      collector.index_key.should == "namespace.index"
    end

  end

  describe "Usage" do
    before(:each) do
      client.flushall
      @collector = Desire::Collector.new(client, TestClass, "base")
      @index_key = @collector.index_key
    end

      
    specify "#add generates a scoped key and registers it" do
      @collector.add("item1")
      @collector.add("item2")
      client.smembers(@index_key).sort.should == %w[ base.item1 base.item2 ]
    end

    specify "#key_for returns the scoped key for the given name" do
      @collector.key_for("smurf").should == "base.smurf"
    end

    specify "#keys returns all keys that have been registered" do
      ("a".."f").each { |name| @collector.add(name) }
      # this is probably too clever a use of Range
      @collector.keys.sort.should == ("base.a".."base.f").to_a
    end

    specify "#get returns an instance of the collection class" do
      TestClass.should_receive(:new).with(client, "base.smurf")
      @collector.get("smurf")
    end

    specify "#all returns a hash mapping item names to instances" do
      @collector.add("item1")
      @collector.add("item2")

      instances = @collector.all
      instances["item1"].should be_a_kind_of(TestClass)
      instances["item2"].should be_a_kind_of(TestClass)
      instances.size.should == 2
    end

  end

end

