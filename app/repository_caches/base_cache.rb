class BaseCache
  class << self
    def inherited(klass)
      klass.include Dry::Monads[:do, :maybe, :result, :try]
      super
    end
  end
end
