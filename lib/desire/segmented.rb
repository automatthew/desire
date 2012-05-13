class Segmented
  include Enumerable

  attr_reader :base_key
  def initialize(client, klass, base_key)
    @client = client
    @base_key = base_key
    @index_key = "#{@base_key}.index"
    @index = Desire::Set.new(client, @index_key)
  end

  def segment_keys
    @client.smembers(@index_key)
  end

  def segment_key(name)
    "#{@base_key}.#{name}"
  end

  def segment(name)
    add(name)
    klass.new(@client, segment_key(name))
  end

  def has_segment(name)
    @client.exists(segment_key(name))
  end

  def add(name)
    @client.sadd(@index_key, segment_key(name))
  end

  def segments
    out = {}
    each do |key, segment|
      out[key] = segment
    end
    out
  end

  def all
    out = {}
    each do |key, segment|
      out[key] = segment.getall
    end
    out
  end

  def each
    segment_keys.each do |key|
      yield [key, klass.new(@client, key)]
    end
  end

end
