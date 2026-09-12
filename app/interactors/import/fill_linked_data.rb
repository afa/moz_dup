class Import::FillLinkedData < BaseInteractor
  option :table_config, type: Types::Strict::Hash
  option :item_hash, type: Types::Strict::Hash
  option :item_id, type: Types::Coercible::Integer

  def call
    Success(
      table_config.fetch('linked', {}).each_with_object({}) do |(tbl, opts), obj|
        fkey = opts['fkey'].to_sym
        opts['fields'].each do |skey, rules|
          val = item_hash[skey.to_sym]
          next if val.nil? || val == ''

          h = rules.except('name').transform_keys(&:to_sym)
          h[rules['name'].to_sym] = val
          h[fkey] = item_id

          obj[tbl.to_sym] ||= []
          obj[tbl.to_sym] << h
          print '+'
        end
      end
    )
  end
end
