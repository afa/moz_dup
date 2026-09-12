require 'spec_helper'

RSpec.describe Import::ConvertItemWithDefaults, type: :interactor do
  subject(:called) { described_class.call(value:, item_config:) }

  context 'when item must be bool' do
    let(:item_config) { { 'convertor' => 'int_to_boolean' } }

    shared_context 'with int_to_boolean convertor' do |value, rezult|
      context "when item #{value}" do
        let(:value) { value }

        it "be #{rezult}" do
          expect(called.value_or(nil)).to be rezult
        end
      end
    end

    include_context 'with int_to_boolean convertor', 0, false
    include_context 'with int_to_boolean convertor', 1, true
    include_context 'with int_to_boolean convertor', nil, false
  end

  context 'when item must be time' do
    let(:item_config) { { 'convertor' => 'int_to_time' } }

    shared_context 'with int_to_time convertor' do |value, rezult|
      context "when item #{value}" do
        let(:value) { value }

        it 'be false' do
          expect(called.value_or(nil)).to eq(rezult)
        end
      end
    end

    include_context 'with int_to_time convertor', 0, Time.new(1970, in: 'UTC')
    include_context 'with int_to_time convertor', 3600, Time.new(1970, 1, 1, 1, in: 'UTC')
  end

  context 'when item must be mapped' do
    let(:item_config) { { 'check' => { 'with' => -1, 'set' => nil } } }

    shared_context 'with check mapper' do |value, rezult|
      context "when item #{value}" do
        let(:value) { value }

        it 'be expected' do
          expect(called.value!).to eq(rezult)
        end
      end
    end

    include_context 'with check mapper', -1, nil
    include_context 'with check mapper', 1, 1
  end

  context 'when null item must be filled' do
    let(:item_config) { { 'if_null' => { 'klass' => 'Time', 'method' => 'new', 'params' => [1970] } } }

    shared_context 'with null mapper' do |value, rezult|
      context "when item #{value}" do
        let(:value) { value }

        it 'be expected' do
          expect(called.value!).to eq(rezult)
        end
      end
    end

    include_context 'with null mapper', nil, Time.new(1970)
    include_context 'with null mapper', 1, 1
  end

  context 'when config clean' do
    let(:item_config) { {} }
    let(:value) { 10 }

    it 'be return same value' do
      expect(called.value!).to eq(value)
    end
  end
end
