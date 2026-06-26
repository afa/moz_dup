require 'dry/types'
require 'dry/initializer'
require 'dry/monads'
class BaseInteractor
  module Types
    include Dry::Types()
  end

  extend Dry::Initializer

  class << self
    def inherited(klass)
      klass.include Dry::Monads[:do, :maybe, :result, :try, :list]
      super
    end

    # Instantiates and calls the service at once
    def call(*, **, &)
      new(*, **).call(&)
    end
  end
end
