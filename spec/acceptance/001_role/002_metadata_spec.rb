require 'spec_helper_acceptance'

describe 'xtreemfs::role::metadata class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'executing simple include with puppet code' do
    
    pp = <<-eos
    class { 'xtreemfs::settings': 
      properties => {
        'debug.level' => 1,
      }
    }
    include xtreemfs::role::metadata
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :catch_changes => true)
    end
    describe service('xtreemfs-mrc') do 
      it { should be_running }
    end
    
  end

end