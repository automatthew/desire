class Desire

  class Collection

    def initialize(client, scope)
      @index = Desire::Hash.new(client, "#{scope}.index")
    end

    def get(key)
      redis_key = @index.hget(key)
    end

  end

end


