require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Register do

    describe 'CLAide' do
      before do
        @command = Command.parse(%w{ register })
      end
      
      it 'registers itself' do
        @command.should.be.instance_of Command::Register
      end

      it 'presents help if no spec is present' do
        should.raise CLAide::Help do
          @command.run
        end.message.should.match /A .podspec must exist in the directory `pod register` is ran/
      end

      # it 'adds podspec to register db' do
        
      # end

      # it 'adds multiple podspecs to register db' do
        
      # end

    end
  end
end
