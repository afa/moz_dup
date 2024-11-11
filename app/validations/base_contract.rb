require 'dry-validation'

module Types
  include Dry::Types()
end

Dry::Validation.load_extensions(:monads)

class BaseContract < Dry::Validation::Contract; end
