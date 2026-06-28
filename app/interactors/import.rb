class Import < BaseInteractor
  param :db
  param :tables
  def call
    import_tables(tables.find { it['name'] == 'forum_usergroup' })
    import_tables(tables.find { it['name'] == 'forum_user' })
    import_tables(tables.find { it['name'] == 'forum_forum' })
    import_tables(tables.find { it['name'] == 'forum_thread' })
    import_tables(tables.find { it['name'] == 'forum_post' })
    # tables.each do |params|
    #   import_table(params)
    # end
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
      postprocessable = {}
      clean_count
      from.order(params['pk'].to_sym).paged_each(skip_transaction: true) do |hsh|
        count_iteration_with_gc

        data, stor = Import::FillItemData.call(table_config: params, item_hash: hsh)
        item = to.insert_select(data)
        postprocessable[item[:id]] = stor unless stor.empty?
        linked_inserts = Import::FillLinkedData.call(table_config: params, item_id: item[:id])
        linked_inserts.each do |tbl, list|
          App.db[tbl].multi_insert(list)
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
end
