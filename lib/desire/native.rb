class Desire
  class Native
    include Desire::Key

    attr_reader :client, :key

    def initialize(client, key)
      @client = client
      @key = key
    end

  end
end
