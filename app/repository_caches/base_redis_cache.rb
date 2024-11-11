# frozen_string_literal: true

class BaseRedisCache
  extend Dry::Initializer
  option :redis, default: -> { RedisClient.instance }

  DEFAULT_REDIS_TTL = 10.minutes.to_i

  class << self
    def inherited(klass)
      klass.include Dry::Monads[:do, :maybe, :result, :try]
      super
    end

    def cache_key(key)
      instance_variable_set(:@redis_cache_key, key)
    end

    def cache_ttl(ttl)
      instance_variable_set(:@redis_cache_ttl, ttl)
    end
  end

  def cached_data(index = nil)
    Try { JSON.parse(redis.get(redis_key(index)), symbolize_names: true) }.to_result
  end

  def cache?(index = nil)
    Try { redis.exists?(redis_key(index)) }.value_or(false)
  end

  def refresh_cache(response, index = nil)
    return Success(response) if cache?(index) || response.none?

    Try {
      redis.set(redis_key(index), response.to_json, ex: redis_ttl)
    }.to_result
  end

  private

  # :reek:ControlParameter
  def redis_key(index = nil)
    [self.class.instance_variable_get(:@redis_cache_key), (index || 'index').to_s].join('_')
  end

  def redis_ttl
    self.class.instance_variable_get(:@redis_cache_ttl) || DEFAULT_REDIS_TTL
  end
end
