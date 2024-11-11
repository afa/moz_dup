class Import < Thor
  desc 'apply', 'import defined tables'
  def apply
    ::Import.call(App.ext_db[:moz], App.config['tables'])
  end
end
