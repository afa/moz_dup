require 'dry-validation'

Dry::Validation.load_extensions(:monads)

class BaseContract < Dry::Validation::Contract
  module Types
    include Dry::Types()
  end
end
