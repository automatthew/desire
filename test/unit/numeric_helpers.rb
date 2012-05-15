include Desire::NumericHelpers

describe "NumericHelpers#to_number" do

  specify "converts a string representation of an integer into an Integer" do
    %w[ 1 2 4 8 16 32 64 357 11 13 17 19 23 29 ].each do |string|
      to_number(string).should be_a_kind_of(Integer)
    end
  end

  specify "converts a string representation of a float into a Float" do
    %w[ 1.0 2.345 67.89 103953425378.23].each do |string|
      to_number(string).should be_a_kind_of(Float)
    end
  end

  specify "fails when the string cannot be parsed" do
    %w[ xyz 1.x x-4 5-3].each do |string|
      lambda {
        to_number(string)
      }.should raise_error(ArgumentError)
    end
  end

end
