class Import < BaseInteractor
  param :db
  param :tables
  def call
    tables.each do |params|
      name = params['name']
      puts name
      ds_from = db[name.to_sym]
      ds_to = App.db[params['table'].to_sym]
      params.fetch('linked', {}).each_key do |tbl|
        App.db[tbl.to_sym].truncate(cascade: true)
      end
      ds_to.truncate(cascade: true)
      yield copy_data(ds_from, ds_to, params)
    end
  end

  private

  def copy_data(from, to, params)
    Try {
      count = 0
      defer = params['defer'] || []
      to_post = {}
      from.order(params['pk'].to_sym).paged_each(skup_transaction: true) do |hsh|
        if (count % 10_000).zero?
          print "\n#{count}"
          GC.start
        end
        count += 1
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
        to_post[item[:id]] = stor unless stor.empty?
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
      to_post.each do |id, data|
        to.where(id:).update(data)
      end
      puts ''
    }
      .to_result
      .or { |d| pp d, d.backtrace; Failure(d) }
  end

  def try_with_defaults(val, params)
    return send(params['convertor'].to_sym, val) if params.key?('convertor')

    return params['check']['set'] if params.key?('check') && params['check']['with'] == val

    if val.nil? && params.key?('if_null')
      return Try { Object.const_get(params['if_null']['klass']) }
             .value_or(nil)
             &.public_send(params['if_null']['method'].to_sym, *(params['if_null']['params']))
    end
    val
  end

  def int_to_boolean(val)
    val.to_i.positive?
  end

  def int_to_time(val)
    Time.at(val)
  end
end
