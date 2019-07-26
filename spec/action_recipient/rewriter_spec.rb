RSpec.describe ActionRecipient::Rewriter do

  before do
    ActionRecipient.reset_config!
  end

  describe '.rewrite_addresses!' do
    let(:mail)          { Mail.new }
    let(:format)        { 'admin+%s@example.com' }
    let(:prefix)        { 'p_' }
    let(:to_addresses)  { ['foo@foo.com', 'bar@bar.org'] }
    let(:cc_addresses)  { ['foo@foo.jp',  'bar@bar.jp'] }
    let(:bcc_addresses) { ['foo@foo.fr',  'bar@bar.fr'] }

    before do
      ActionRecipient.config.format = format

      mail[:to]  = to_addresses
      mail[:cc]  = cc_addresses
      mail[:bcc] = bcc_addresses
    end

    subject { described_class.rewrite_addresses!(mail, type, prefix: prefix) }

    shared_examples 'overwriting relavant addresses' do
      let(:mail_field) { mail[type] }
      it 'is overwritten' do
        expect { subject }.to change { mail_field.addresses }.to match_array(converted_addresses)
      end
    end

    shared_examples 'leaving relevant addresses as-is' do
      let(:mail_field) { mail[type] }
      it 'is NOT overwritten' do
        expect { subject }.not_to change { mail_field.addresses }
      end
    end

    shared_examples 'leaving irrelevant addresses as-is' do
      let(:irrelevant_types) { %i(to cc bcc) - [type] }
      let(:mail_fields) { irrelevant_types.map { |t| mail[t] } }

      it 'is NOT overwritten' do
        expect { subject }.not_to change { mail_fields.map(&:addresses) }
      end
    end

    context 'with "to" addresses' do
      let(:type) { :to }

      context 'without any whitelisted addresses' do
        let(:converted_addresses) { [
            'admin+p_foo_at_foo.com@example.com',
            'admin+p_bar_at_bar.org@example.com'
        ] }
        it_behaves_like 'overwriting relavant addresses'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end

      context 'when partially whitelisted' do
        before do
          ActionRecipient.config.whitelist = [to_addresses.first, cc_addresses.first, bcc_addresses.first]
        end

        let(:converted_addresses) { [
            'foo@foo.com',
            'admin+p_bar_at_bar.org@example.com'
        ] }
        it_behaves_like 'overwriting relavant addresses'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end

      context 'when totally whitelisted' do
        before do
          ActionRecipient.config.whitelist = to_addresses
        end

        it_behaves_like 'leaving relevant addresses as-is'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end
    end

    context 'with "cc" addresses' do
      let(:type) { :cc }

      context 'without any whitelisted addresses' do
        let(:converted_addresses) { [
            'admin+p_foo_at_foo.jp@example.com',
            'admin+p_bar_at_bar.jp@example.com'
        ] }
        it_behaves_like 'overwriting relavant addresses'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end

      context 'when partially whitelisted' do
        before do
          ActionRecipient.config.whitelist = [to_addresses.first, cc_addresses.first, bcc_addresses.first]
        end

        let(:converted_addresses) { [
            'foo@foo.jp',
            'admin+p_bar_at_bar.jp@example.com'
        ] }
        it_behaves_like 'overwriting relavant addresses'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end

      context 'when totally whitelisted' do
        before do
          ActionRecipient.config.whitelist = cc_addresses
        end

        it_behaves_like 'leaving relevant addresses as-is'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end
    end

    context 'with "bcc" addresses' do
      let(:type) { :bcc }

      context 'without any whitelisted addresses' do
        let(:converted_addresses) { [
            'admin+p_foo_at_foo.fr@example.com',
            'admin+p_bar_at_bar.fr@example.com'
        ] }
        it_behaves_like 'overwriting relavant addresses'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end

      context 'when partially whitelisted' do
        before do
          ActionRecipient.config.whitelist = [to_addresses.first, cc_addresses.first, bcc_addresses.first]
        end

        let(:converted_addresses) { [
            'foo@foo.fr',
            'admin+p_bar_at_bar.fr@example.com'
        ] }
        it_behaves_like 'overwriting relavant addresses'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end

      context 'when totally whitelisted' do
        before do
          ActionRecipient.config.whitelist = bcc_addresses
        end

        it_behaves_like 'leaving relevant addresses as-is'
        it_behaves_like 'leaving irrelevant addresses as-is'
      end
    end
  end

  describe '.rewrite' do
    let(:prefix)  { 'a_rewritten_address__' }
    let(:format)  { 'base_address+%s@example.com' }

    subject { described_class.rewrite(address, prefix, format) }

    context 'with plain address' do
      let(:address) { 'foo@example.com' }
      it { is_expected.to eq 'base_address+a_rewritten_address__foo_at_example.com@example.com' }
    end

    context 'with address neither alphabetical nor dot characters' do
      let(:address) { 'foo+bar++baz@example.com' }
      it { is_expected.to eq 'base_address+a_rewritten_address__foo-bar--baz_at_example.com@example.com' }
    end
  end

  describe '.whitelisted?' do
    subject { described_class.whitelisted?(address) }
    let(:address) { 'foo@example.com' }
    it { is_expected.to be false }

    context 'when custom list is given' do
      before do
        ActionRecipient.config.whitelist = custom_whitelist
      end

      let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }

      context 'with a whitelisted address' do
        let(:address) { 'foo@example.com' }
        it { is_expected.to be true }
      end

      context 'with non-whitelisted address' do
        let(:address) { 'foo1@example.com' }
        it { is_expected.to be false }
      end
    end
  end

  describe '.whitelist' do
    subject { described_class.whitelist }
    it { is_expected.to eq [] }

    context 'when custom list is given' do
      before do
        ActionRecipient.config.whitelist = custom_whitelist
      end

      let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }
      it { is_expected.to eq custom_whitelist }
    end
  end
 
  describe '.format' do
    subject { described_class.format }
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
