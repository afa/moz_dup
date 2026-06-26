class Import::ConvertItemWithDefaults < Import::Base
  option :value, optional: true
  option :item_config, type: Types::Strict::Hash

  def call
    return Success(send(item_config['convertor'].to_sym, value)) if item_config.key?('convertor')

    return Success(item_config.dig('check', 'set')) if item_config.dig('check', 'with') == value

    if value.nil? && item_config.key?('if_null')
      return Try { Object.const_get(item_config['if_null']['klass']) }
             .value_or(nil)
             &.public_send(item_config['if_null']['method'].to_sym, *item_config['if_null']['params'])
    end
    Success(value)
  end

  private

  def int_to_boolean(value) # rubocop:disable Naming/PredicateMethod
    value.to_i.positive?
  end

  def int_to_time(value)
    Time.at(value)
  end
end
