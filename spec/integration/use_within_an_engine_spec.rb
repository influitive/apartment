# frozen_string_literal: true

describe 'using apartment within an engine' do
  before do
    engine_path = Pathname.new(File.expand_path('../dummy_engine', __dir__))
    require engine_path.join('test/dummy/config/application')
    @rake = Rake::Application.new
    Rake.application = @rake
    stub_const 'APP_RAKEFILE', engine_path.join('test/dummy/Rakefile')
    load 'rails/tasks/engine.rake'
  end

  it 'sucessfully runs rake db:migrate in the engine root' do
    expect { Rake::Task['db:migrate'].invoke }.not_to raise_error
  end

  it 'sucessfully runs rake app:db:migrate in the engine root' do
    expect { Rake::Task['app:db:migrate'].invoke }.not_to raise_error
  end

  context 'when Apartment.db_migrate_tenants is false' do
    it 'should not enhance tasks' do
      Apartment.db_migrate_tenants = false
      expect(Apartment::RakeTaskEnhancer).not_to receive(:enhance_task).with('db:migrate')
      Rake::Task['db:migrate'].invoke
    end
  end
end
