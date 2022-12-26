require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Unregister do

    describe 'CLAide' do
      before do
        @command = Command.parse(%w{ unregister })
      end
      
      it 'registers itself' do
        @command.should.be.instance_of Command::Unregister
      end

      it 'presents help if no spec is present' do
        should.raise CLAide::Help do
          @command.run
        end.message.should.match /A .podspec must exist in the directory `pod unregister` is ran/
      end

      # it 'removes podspec from register db' do
        
      # end

      # it 'removes multiple podspecs to register db' do
        
      # end

      # it 'does nothing if podspec is not registered' do
        
      # end

    end
  end
end
