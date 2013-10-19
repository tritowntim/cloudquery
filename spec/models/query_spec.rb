require 'spec_helper'

describe Query do

  it { should belong_to :database }

  context 'basic CRUD' do
    let(:database) { Database.create(name: 'test') }

    it "saves a new instance" do
      Query.create( { sql_text: "SELECT NOW()", record_count: 1, duration_ms: 9, database: database })
    end
  end

end


