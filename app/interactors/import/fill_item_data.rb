class Import::FillItemData < BaseInteractor
  option :table_config, type: Types::Strict::Hash
  option :item_hash, type: Types::Strict::Hash

  def call
    stor = {}
    defer = table_config.fetch('defer', []).map(&:to_sym)
    table_config['fields'].each_with_object({}) do |(skey, dest), obj|
      name = dest['name'].to_sym
      val = yield try_with_defaults(item_hash[skey.to_sym], dest)
      if defer.include?(name)
        stor[name] = val
        obj[name] = nil
      else
        obj[name] = val
      end
    end
    Success([table_config, stor])
  end

  def try_with_defaults(value, item_config)
    Import::ConvertItemWithDefaults.call(value:, item_config:)
  end
end
