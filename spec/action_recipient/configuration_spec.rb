RSpec.describe ActionRecipient do
  before do
    ActionRecipient.reset_config!
  end

  describe '.config' do
    subject { ActionRecipient.config }

    it { is_expected.to be_an_instance_of ActionRecipient::Configuration }
    it { is_expected.to respond_to(:whitelist) }
    it { is_expected.to respond_to(:format) }
    it { is_expected.to respond_to(:whitelist=) }
    it { is_expected.to respond_to(:format=) }

    describe 'Configuration#whitelist' do
      subject { ActionRecipient.config.whitelist }
      it { is_expected.to eq [] }

      context 'when custom list is given' do
        before do
          ActionRecipient.config.whitelist = custom_whitelist.dup
        end

        let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }
        it { is_expected.to eq custom_whitelist }

        context 'when another address is added' do
          before do
            ActionRecipient.config.whitelist << new_address
          end

          let(:new_address) { 'baz@another_domain.example.com' }
          it { is_expected.to eq custom_whitelist + [new_address] }
        end
      end
    end

    describe '.reset_config!' do
      context 'with whitelist' do
        before do
          ActionRecipient.config.whitelist = custom_whitelist
        end
        let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }

        subject { ActionRecipient.reset_config! }

        it { expect { subject }.to change { ActionRecipient.config.whitelist }.from(custom_whitelist).to([]) }
      end
      
      context 'with format' do
        before do
          ActionRecipient.config.format = format
        end
        let(:format) { 'a_safe_address+%s@example.com' }

        subject { ActionRecipient.reset_config! }

        it { expect { subject }.to change { ActionRecipient.config.format }.from(format).to('%s') }
      end
    end

    describe 'Configuration#format' do
      subject { ActionRecipient.config.format }
      it { is_expected.to eq '%s' }

      context 'when format is given' do
        before do
          ActionRecipient.config.format = format
        end

        let(:format) { 'a_safe_address+%s@example.com' }
        it { is_expected.to eq format }
      end
    end
  end

  describe '.configure' do
    describe 'whitelist' do
      subject {
        ActionRecipient.configure do |config|
          config.whitelist = custom_whitelist
        end
      }
      let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }
  
      it 'updates whitelist' do
        expect { subject }.to change { ActionRecipient.config.whitelist }.to custom_whitelist
      end
    end
 
    describe 'format' do
      subject {
        ActionRecipient.configure do |config|
          config.format = format
        end
      }
      let(:format) { 'foo+%s@example.com' }
  
      it 'updates format' do
        expect { subject }.to change { ActionRecipient.config.format }.to format
      end
    end
  end
end
