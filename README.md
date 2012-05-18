# Desire

Desire is a library that provides wrappers around Redis storage types,
as well as composite classes that manage multiple keys and/or types.
Desire currently does not wrap the PUB/SUB commands for a number of reasons:

* they do not use the same namespace as the storage commands
* they are already quite simple to use.
* SUBSCRIBE and PSUBSCRIBE block the client

That last reason also explains the lack of BLPOP and its pals in Desire::Native::List.

## Overview

You can instantiate Desire wrappers directly:

    hash = Desire::Hash.new(client, "some_key")

Or use the convenience methods:

    desire = Desire.new(client) # client is duck-typed to redis-rb behavior
    hash = desire.hash("some_key")

Once you have a wrapper instance, use any Redis method defined for that type:

    desire = Desire.new(redis_client)
    hash = desire.hash("some_key")
    hash.hset("one_two", "buckle my shoe") # exact native command
    hash.set("three_four", "shut the door") # same thing, but redundant 'h' prefix removed

Where possible and sensible, native wrappers alias the names of idiomatic Ruby methods
to the Redis equivalents

    hash["three_four"] #=> "shut the door"
    hash["five_six"] = "pick up sticks"
    hash.values_at("one_two", "seven_eight") #=> ["buckle my shoe", nil]

The base Desire class includes the Transaction mixin, which provides #multi
and #watch methods so you can be sure you're using the right client
at all times in a transaction attempt.

    hash = desire.hash("smurf")
    set = desire.set("seven_dwarfs")
    desire.multi do
      hash.hset("color", "blue")
      set.add("grumpy")
    end

The composite classes provide useful combinations of native features.  The
composite that kicked off the whole project is Desire::SortedHash, which
combines a Hash for data storage with a SortedSet for ordered indexing.

    sorted_hash = desire.sorted_hash("messages")
    sorted_hash.set(message_key, message_body, timestamp)

When you instantiate a composite class, the key is treated as a "base key", i.e.
a string that will serve as the prefix to the actual keys used
within the composite wrapper. A composite class claims the right to all keys
which begin with its base key, so be careful not to use keys that may
collide, either in other Desire composites, or manually.

    desire.client.keys("messages.*")
    # => ["messages.index", "messages.store"]

## Convention Versioning

TBW

