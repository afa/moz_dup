class BaseInstanceCache < BaseCache
  # extend Dry::Initializer

  # class << self
  #   def inherited(klass)
  #     klass.include Dry::Monads[:do, :maybe, :result, :try]
  #     super
  #   end

  #   def cache_key(key)
  #     instance_variable_set(:@redis_cache_key, key)
  #   end

  #   def cache_ttl(ttl)
  #     instance_variable_set(:@redis_cache_ttl, ttl)
  #   end
  # end

  def cached_data(_index = nil)
    Maybe(@data).to_result
    # Try { JSON.parse(redis.get(redis_key(index)), symbolize_names: true) }.to_result
  end

  def cache?(_index = nil)
    Try { @data && !@data.empty? }.value_or(false)
    # Try { redis.exists?(redis_key(index)) }.value_or(false)
  end

  def refresh_cache(response, index = nil)
    return Success(response) if cache?(index) || response.none?

    Try {
      @data = response
      # redis.set(redis_key(index), response.to_json, ex: redis_ttl)
    }.to_result
  end
end
