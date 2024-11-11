class BaseRepository
  extend Dry::Initializer
  extend Forwardable

  # ru bocop:disable Lint/MissingSuper
  class << self
    def inherited(klass)
      klass.include Dry::Monads[:do, :maybe, :result, :try]
      super
    end
  end
  # ru bocop:enable Lint/MissingSuper

  # private

  # def connect_to_huntflow
  #   ::Huntflow::ConnectToHuntflow.call
  # end

  # def result_of(response)
  #   # response isn't a monad, so we should wrap it
  #   return Success(response) if response.success?

  #   Failure(HuntflowResponseFailure.new(response.message))
  # end

  class Error < StandardError; end
end
