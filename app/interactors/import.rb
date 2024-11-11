class Import < BaseInteractor
  param :db
  param :tables
  def call
    tables.each do |name, params|
      puts name
      ds_from = db[name.to_sym]
      ds_to = App.db[params['table'].to_sym]
      ds_to.truncate
      yield copy_data(ds_from, ds_to, params)
    end
  end

  private

  def copy_data(from, to, params)
    Try {
      from.each do |hsh|
        data = params['fields'].each_with_object({}) do |(skey, dest), obj|
          val = hsh[skey.to_sym]
          obj[dest['name'].to_sym] = try_with_defaults(val, dest)
        end
        to.insert(data)
        print '.'
      end
      puts ''
    }
      .to_result
      .alt_map { |d| pp d; d }
  end

  def try_with_defaults(val, params)
    if val.nil? && params.key?('if_null')
      Try { Object.const_get(params['if_null']['klass']) }
        .value_or(nil)
        &.public_send(params['if_null']['method'].to_sym, *(params['if_null']['params']))
    else
      val
    end
  end
end
