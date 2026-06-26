require 'spec_helper'

RSpec.describe Import::ConvertItemWithDefaults, type: :interactor do
  subject(:called) { described_class.call(value:, item_config:) }

  context 'when item must be bool' do
    let(:item_config) { { 'covertor' => 'int_to_boolean' } }

    context 'when item zero' do
      let(:value) { 0 }

      it 'be false' do
        expect(called).to be false
      end
    end
  end
end
