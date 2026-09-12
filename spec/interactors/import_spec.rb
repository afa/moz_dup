# rubocop:disable RSpec/VerifiedDoubles, RSpec/MultipleMemoizedHelpers
require 'spec_helper'

RSpec.describe Import, type: :interactor do
  subject(:import) { described_class.call(source_db, table_config) }

  let(:source_db) { double('Sequel::Database') }
  let(:table_config) {
    [
      {
        'name' => 'forum_usergroup',
        'table' => 'user_group',
        'pk' => 'usergroupid',
        'fields' => {
          'usergroupid' => { 'name' => 'id' }
        }
      },
      {
        'name' => 'forum_user',
        'table' => 'user',
        'pk' => 'userid',
        'linked' => {
          'contact' => {
            'fkey' => 'user_id',
            'fields' => {
              'homepage' => { 'kind' => 1, 'name' => 'value' }
            }
          }
        },
        'fields' => {
          'userid' => { 'name' => 'id' },
          'username' => { 'name' => 'name' }
        }
      },
      { 'name' => 'forum_forum', 'table' => 'forum', 'pk' => 'forumid', 'fields' => { 'forumid' => { 'name' => 'id' } } },
      { 'name' => 'forum_thread', 'table' => 'thread', 'pk' => 'threadid', 'fields' => { 'threadid' => { 'name' => 'id' } } },
      { 'name' => 'forum_post', 'table' => 'post', 'pk' => 'postid', 'fields' => { 'postid' => { 'name' => 'id' } } }
    ]
  }
  let(:source_dataset) { double('source_dataset') }
  let(:target_dataset) { double('target_dataset') }
  let(:ordered_dataset) { double('ordered_dataset') }

  before do
    allow(source_db).to receive(:[]).and_return(source_dataset)
    allow(App.db).to receive(:[]).and_return(target_dataset)
    allow(target_dataset).to receive_messages(
      truncate: nil, insert_select: { id: 1 }, where: target_dataset, update: nil
    )
    allow(source_dataset).to receive(:order).and_return(ordered_dataset)
    allow(ordered_dataset).to receive(:paged_each).and_yield(usergroupid: 1)
    allow(Import::FillItemData).to receive(:call).and_return(Dry::Monads::Success([{ id: 1 }, {}]))
    allow(Import::FillLinkedData).to receive(:call).and_return(Dry::Monads::Success({}))
  end

  describe '#call' do
    it 'truncates target tables' do
      import

      expect(target_dataset).to have_received(:truncate).with(cascade: true).at_least(:once)
    end

    it 'processes source rows via FillItemData' do
      import

      expect(Import::FillItemData).to have_received(:call).at_least(:once)
    end

    it 'inserts transformed data into target' do
      import

      expect(target_dataset).to have_received(:insert_select).at_least(:once)
    end

    context 'with linked tables' do
      let(:linked_dataset) { double('linked_dataset') }

      before do
        allow(App.db).to receive(:[]).with(:contact).and_return(linked_dataset)
        allow(linked_dataset).to receive_messages(truncate: nil, multi_insert: nil)
        allow(Import::FillLinkedData).to receive(:call)
          .and_return(Dry::Monads::Success({ contact: [{ kind: 1, user_id: 1, value: 'http://example.com' }] }))
      end

      it 'truncates linked tables' do
        import

        expect(linked_dataset).to have_received(:truncate).with(cascade: true)
      end

      it 'multi_inserts linked data' do
        import

        expect(linked_dataset).to have_received(:multi_insert).at_least(:once)
      end
    end

    context 'with deferred fields' do
      let(:deferred_config) {
        {
          'name' => 'forum_forum',
          'table' => 'forum',
          'pk' => 'forumid',
          'defer' => ['parent_id'],
          'fields' => {
            'forumid' => { 'name' => 'id' },
            'parentid' => { 'name' => 'parent_id' }
          }
        }
      }

      before do
        table_config[2] = deferred_config
        allow(ordered_dataset).to receive(:paged_each).and_yield(forumid: 1, parentid: 5)
        allow(Import::FillItemData).to receive(:call) do |table_config:, **|
          if table_config['defer']
            Dry::Monads::Success([{ id: 1, parent_id: nil }, { parent_id: 5 }])
          else
            Dry::Monads::Success([table_config, {}])
          end
        end
        allow(Import::FillLinkedData).to receive(:call).and_return(Dry::Monads::Success({}))
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'updates deferred fields after processing' do
        import

        expect(target_dataset).to have_received(:where).with(id: 1)
        expect(target_dataset).to have_received(:update).with({ parent_id: 5 })
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    context 'when FillItemData fails' do
      before do
        allow(Import::FillItemData).to receive(:call).and_return(Dry::Monads::Failure('fill error'))
      end

      it 'returns Failure' do
        expect(import).to be_failure
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles, RSpec/MultipleMemoizedHelpers
