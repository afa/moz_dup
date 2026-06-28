class Import::ConvertItemWithDefaults < Import::Base
  option :value, optional: true
  option :item_config, type: Types::Strict::Hash

  CONVERTORS = {
    'int_to_boolean' => :int_to_boolean,
    'int_to_time' => :int_to_time
  }.freeze

  def call
    with_convertors(value)
      .bind { return Success(it) }
      .or_fmap { it }
      .bind { with_mapper(it) }
      .bind { return Success(it) }
      .or_fmap { it }
      .bind { with_null_transform(it) }
      .bind { return Success(it) }
      .or { Success(value) }
  end

  private

  def with_convertors(value)
    return Try { method(CONVERTORS[item_config['convertor']]).call(value) } if CONVERTORS.key?(item_config['convertor'])

    Failure(value)
  end

  def with_mapper(value)
    return Failure(value) unless item_config.key?('check') && item_config.dig('check', 'with') == value

    Success(item_config.dig('check', 'set'))
  end

  def with_null_transform(value)
    return Failure(value) unless value.nil? && item_config.key?('if_null')

    null_config = item_config['if_null']
    Try { Object.const_get(null_config['klass']) }
      .or { return Failure(value) }
      .fmap { it.public_send(null_config['method'].to_sym, *null_config['params']) }
  end

  def int_to_boolean(value) # rubocop:disable Naming/PredicateMethod
    value.to_i.positive?
  end

  def int_to_time(value)
    Time.at(value, in: 'UTC')
  end
end
