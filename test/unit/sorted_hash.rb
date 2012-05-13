
def random_key
  (0...8).map{65.+(rand(25)).chr}.join
end

def get_timestamp
  (Time.now.to_f * 1000).floor * 1000
end

client = MockRedis.new

describe "Desire::SortedHash" do
  before(:each) do
    client.flushall
    @sorted_hash = Desire::SortedHash.new(client, "test-namespace")
  end

  describe "append" do
    describe "appending with the same timestamp" do
      before(:each) do
        timestamp = get_timestamp
        @sorted_hash.append('key1', 'one', timestamp)
        @sorted_hash.append('key2', 'two', timestamp)
      end

      specify "should append with different timestamps" do
        # Get all messages in the hash
        messages = @sorted_hash.values_by_range
        messages[0][1].should_not == messages[1][1]
      end
    end
  end

  describe "update" do
    specify "should update the element" do
      key = random_key
      @sorted_hash.append(key, "one", 0)
      @sorted_hash.update(key, "two")
      @sorted_hash.get(key).should == "two"
    end
  end

  describe "remove_by_range" do
    describe "with a hash with 0 elements" do
      describe "size" do
        specify "should be 0" do
          @sorted_hash.size.should == 0
        end
      end

      describe "remove 4" do
        before(:each) do
          @sorted_hash.remove_by_range(4, 6)
        end

        specify "should leave 0 elements" do
          @sorted_hash.size.should == 0
        end
      end
    end

    describe "with a hash with 10 elements" do
      before(:each) do
        @oldest_key = random_key
        count = 0
        @sorted_hash.append(@oldest_key, "first", count+=1)
        8.times do |i|
          @sorted_hash.append(random_key, "test#{i}", count+=1)
        end
        @newest_key = random_key
        @sorted_hash.append(@newest_key, "last", count+=1)
      end

      describe "removing range 4,6" do
        before(:each) do
          @sorted_hash.remove_by_range(4, 6)
        end

        specify "should leave 8 elements" do
          @sorted_hash.size.should == 8
        end

        specify "should leave the first and last elements" do
          @sorted_hash.get(@oldest_key).should == 'first'
          @sorted_hash.get(@newest_key).should == 'last'
        end
      end

      describe "removing the oldest 4" do
        before(:each) do
          @sorted_hash.remove_by_range(nil, 4)
        end

        specify "should leave 6 elements" do
          @sorted_hash.size.should == 6
        end

        specify "should leave the first element" do
          @sorted_hash.get(@newest_key).should == 'last'
        end

        specify "should remove the first element" do
          @sorted_hash.get(@oldest_key).should be_nil
        end
      end

      describe "removing the newest 4" do
        before(:each) do
          @sorted_hash.remove_by_range(6, nil)
        end

        specify "should leave 6 elements" do
          @sorted_hash.size.should == 6
        end

        specify "should leave the last element" do
          @sorted_hash.get(@oldest_key).should == 'first'
        end

        specify "should remove the first element" do
          @sorted_hash.get(@newest_key).should be_nil
        end
      end

      describe "removing from range 8,12" do
        before(:each) do
          @sorted_hash.remove_by_range(8, 12)
        end

        specify "should leave 8 elements" do
          @sorted_hash.size.should == 8
        end

        specify "should leave the first element" do
          @sorted_hash.get(@oldest_key).should == 'first'
        end

        specify "should remove the first element" do
          @sorted_hash.get(@newest_key).should be_nil
        end
      end

      describe "remove_before 0" do
        before(:each) do
          @sorted_hash.remove_before(0)
        end

        specify "should leave 10 elements" do
          @sorted_hash.size.should == 10
        end
      end

      describe "remove_before 5" do
        before(:each) do
          @sorted_hash.remove_before(5)
        end

        specify "should leave 5 elements" do
          @sorted_hash.size.should == 5
        end
      end

      describe "remove_before 10" do
        before(:each) do
          @sorted_hash.remove_before(10)
        end

        specify "should leave 0 elements" do
          @sorted_hash.size.should == 0
        end
      end

      describe "remove_before 15" do
        before(:each) do
          @sorted_hash.remove_before(15)
        end

        specify "should leave 0 elements" do
          @sorted_hash.size.should == 0
        end
      end
    end
  end

  describe "truncate" do
    describe "with a hash with 0 elements" do
      describe "size" do
        specify "should be 0" do
          @sorted_hash.size.should == 0
        end
      end

      describe "truncate to 5 elements" do
        before(:each) do
          @sorted_hash.truncate(5)
        end

        specify "should leave 0 elements" do
          @sorted_hash.size.should == 0
        end
      end
    end

    describe "with a hash with 10 elements" do
      before(:each) do
        @oldest_key = random_key
        @sorted_hash.append(@oldest_key, "first", get_timestamp)
        8.times do |i|
          @sorted_hash.append(random_key, "test#{i}", get_timestamp)
        end
        @newest_key = random_key
        @sorted_hash.append(@newest_key, "last", get_timestamp)
      end

      describe "size" do
        specify "should be 10" do
          @sorted_hash.size.should == 10
        end
      end

      describe "truncate to 15 elements" do
        before(:each) do
          @sorted_hash.truncate(15)
        end

        specify "should leave 10 elements" do
          @sorted_hash.size.should == 10
        end
      end

      describe "truncate to 10 elements" do
        before(:each) do
          @sorted_hash.truncate(10)
        end

        specify "should leave 10 elements" do
          @sorted_hash.size.should == 10
        end
      end

      describe "truncate to 5 elements" do
        before(:each) do
          @sorted_hash.truncate(5)
        end

        specify "should leave 5 elements" do
          @sorted_hash.size.should == 5
        end

        specify "should leave the most recent elements" do
          @sorted_hash.get(@newest_key).should == "last"
        end

        specify "should get rid of the oldest elements" do
          @sorted_hash.get(@oldest_key).should be_nil
        end
      end

      describe "truncate to 1 element" do
        before(:each) do
          @sorted_hash.truncate(1)
        end

        specify "should leave 1 elements" do
          @sorted_hash.size.should == 1
        end

        specify "should leave the most recent elements" do
          @sorted_hash.get(@oldest_key).should be_nil
        end

        specify "should get rid of the oldest elements" do
          @sorted_hash.get(@oldest_key).should be_nil
        end
      end

      describe "truncate to 0 elements" do
        before(:each) do
          @sorted_hash.truncate(0)
        end

        specify "should leave 0 elements" do
          @sorted_hash.size.should == 0
        end

        specify "should get rid the most recent elements" do
          @sorted_hash.get(@oldest_key).should be_nil
        end

        specify "should get rid of the oldest elements" do
          @sorted_hash.get(@oldest_key).should be_nil
        end
      end
    end
  end
end

