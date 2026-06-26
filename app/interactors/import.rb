class Import < BaseInteractor
  param :db
  param :tables
  def call
    tables.each do |params|
      import_table(params)
    end
  end

  private

  def import_table(table_params)
    name = table_params['name']
    puts name
    ds_from = db[name.to_sym]
    ds_to = App.db[table_params['table'].to_sym]
    table_params.fetch('linked', {}).each_key do |tbl|
      App.db[tbl.to_sym].truncate(cascade: true)
    end
    ds_to.truncate(cascade: true)
    yield copy_data(ds_from, ds_to, table_params)
  end

  def copy_data(from, to, params)
    Try {
      defer = params.fetch('defer', [])
      postprocessable = {}
      clean_count
      from.order(params['pk'].to_sym).paged_each(skup_transaction: true) do |hsh| # skup??
        count_iteration_with_gc
        stor = {}
        data = params['fields'].each_with_object({}) do |(skey, dest), obj|
          val = hsh[skey.to_sym]
          if defer.include?(dest['name'])
            stor[dest['name'].to_sym] = try_with_defaults(val, dest)
            obj[dest['name'].to_sym] = nil
          else
            obj[dest['name'].to_sym] = try_with_defaults(val, dest)
          end
        end
        item = to.insert_select(data)
        postprocessable[item[:id]] = stor unless stor.empty?
        params.fetch('linked', {}).each do |tbl, opts|
          fkey = opts['fkey'].to_sym
          opts['fields'].each do |skey, rules|
            val = hsh[skey.to_sym]
            next if val.nil? || val == ''

            h = rules.except('name').transform_keys(&:to_sym)
            h[rules['name'].to_sym] = val
            h[fkey] = item[:id]

            App.db[tbl.to_sym].insert(h)
            print '+'
          end
        end
        print '.'
      end
      postprocessable.each do |id, data|
        to.where(id:).update(data)
      end
      puts ''
    }
      .to_result
      .or { |d|
        pp d, d.backtrace
        Failure(d)
      }
  end

  def count_iteration_with_gc
    if (@count % 10_000).zero?
      print "\n#{count}"
      GC.start
    end
    @count += 1
  end

  def clean_count
    @count = 0
  end

  def try_with_defaults(value, item_config)
    Import::ConvertItemWithDefaults.call(value:, item_config:)
  end
end
