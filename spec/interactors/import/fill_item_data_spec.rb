require 'spec_helper'

RSpec.describe Import::FillItemData, type: :interactor do
  subject(:cmd_call) { described_class.call(table_config:, item_hash:) }

end
