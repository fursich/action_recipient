RSpec.describe ActionRecipient do
  before do
    ActionRecipient.reset_config!
  end

  describe '.config' do
    subject { described_class.config }

    it { is_expected.to be_an_instance_of ActionRecipient::Configuration }
    it { is_expected.to respond_to(:whitelist) }
    it { is_expected.to respond_to(:format) }
    it { is_expected.to respond_to(:format=) }

    describe 'Configuration#whitelist' do
      subject { described_class.config.whitelist }
      it { is_expected.to be_an_instance_of ActionRecipient::Configuration::Whitelist }
      it { is_expected.to respond_to(:domains) }
      it { is_expected.to respond_to(:addresses) }
      it { is_expected.to respond_to(:[]) }

      describe 'Configuration::Whitelist#addresses' do
        subject { described_class.config.whitelist.addresses }

        context 'when custom list is given' do
          before do
            described_class.config.whitelist.addresses = custom_whitelist
          end

          let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }
          it { is_expected.to eq custom_whitelist }
        end
      end

      describe 'Configuration::Whitelist#domains' do
        subject { described_class.config.whitelist.domains }

        context 'when custom list is given' do
          before do
            described_class.config.whitelist.domains = custom_whitelist
          end

          let(:custom_whitelist) { ['google.co.jp', 'foobar.com'] }
          it { is_expected.to eq custom_whitelist }
        end
      end
    end

    describe '.reset_config!' do
      context 'with whitelist' do
        before do
          described_class.config.whitelist.addresses = custom_whitelist
        end
        let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }

        subject { described_class.reset_config! }

        it { expect { subject }.to change { described_class.config.whitelist.addresses }.from(custom_whitelist).to([]) }
      end
      
      context 'with format' do
        before do
          described_class.config.format = format
        end
        let(:format) { 'a_safe_address+%s@example.com' }

        subject { described_class.reset_config! }

        it { expect { subject }.to change { described_class.config.format }.from(format).to('%s') }
      end
    end

    describe 'Configuration#format' do
      subject { described_class.config.format }
      it { is_expected.to eq '%s' }

      context 'when format is given' do
        before do
          described_class.config.format = format
        end

        let(:format) { 'a_safe_address+%s@example.com' }
        it { is_expected.to eq format }
      end
    end
  end

  describe '.configure' do
    describe 'whitelist' do
      describe 'addresses' do
        subject {
          described_class.configure do |config|
            config.whitelist.addresses = custom_whitelist
          end
        }
        let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }
    
        it 'updates whitelist' do
          expect { subject }.to change { described_class.config.whitelist.addresses }.to custom_whitelist
        end
      end

      describe 'domains' do
        subject {
          described_class.configure do |config|
            config.whitelist.domains = custom_whitelist
          end
        }
        let(:custom_whitelist) { ['example.com', 'foo.jp'] }
    
        it 'updates whitelist' do
          expect { subject }.to change { described_class.config.whitelist.domains }.to custom_whitelist
        end
      end
    end
 
    describe 'format' do
      subject {
        described_class.configure do |config|
          config.format = format
        end
      }
      let(:format) { 'foo+%s@example.com' }
  
      it 'updates format' do
        expect { subject }.to change { described_class.config.format }.to format
      end
    end
  end
end
