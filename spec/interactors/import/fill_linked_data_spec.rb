require 'spec_helper'

RSpec.describe Import::FillLinkedData, type: :interactor do
  subject(:cmd_call) { described_class.call(table_config:, item_hash:, item_id:) }

  context 'without linked in config' do
    let(:table_config) {
      {
        'name' => 'forum_usergroup',
        'table' => 'user_group',
        'pk' => 'usergroupid',
        'fields' => {
          'usergroupid' => {
            'name' => 'id'
          }
        }
      }
    }
    let(:item_hash) { {} }
    let(:item_id) { 1 }

    it 'success' do
      expect(cmd_call).to be_success
    end

    it 'empty' do
      expect(cmd_call.value!).to eq({})
    end
  end

  context 'with linked in config and no linked field' do
    let(:table_config) {
      {
        'name' => 'forum_user',
        'table' => 'user',
        'pk' => 'userid',
        'linked' => {
          'contact' => {
            'fkey' => 'user_id',
            'fields' => {
              'homepage' => {
                'kind' => 1,
                'name' => 'value'
              }
            }
          }
        }
      }
    }
    let(:item_hash) { { 'usergroupid' => 2 } }
    let(:item_id) { 1 }

    it 'success' do
      expect(cmd_call).to be_success
    end

    it 'empty' do
      expect(cmd_call.value!).to eq({})
    end
  end

  context 'with linked' do
    let(:table_config) {
      {
        'name' => 'forum_user',
        'table' => 'user',
        'pk' => 'userid',
        'linked' => {
          'contact' => {
            'fkey' => 'user_id',
            'fields' => {
              'homepage' => {
                'kind' => 1,
                'name' => 'value'
              }
            }
          }
        },
        'fields' => {
          'userid' => {
            'name' => 'id'
          }
        }
      }
    }
    let(:item_hash) { { homepage: '123' } }
    let(:item_id) { 1 }

    it 'success' do
      expect(cmd_call).to be_success
    end

    it 'empty' do
      expect(cmd_call.value!).to eq({ contact: [{ kind: 1, user_id: 1, value: '123' }] })
    end
  end
end
