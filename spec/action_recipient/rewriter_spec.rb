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
          ActionRecipient.config.whitelist.addresses = [to_addresses.first, cc_addresses.first, bcc_addresses.first]
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
          ActionRecipient.config.whitelist.addresses = to_addresses
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
          ActionRecipient.config.whitelist.addresses = [to_addresses.first, cc_addresses.first, bcc_addresses.first]
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
          ActionRecipient.config.whitelist.domains = %w[foo.jp bar.jp]
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
          ActionRecipient.config.whitelist.addresses = [to_addresses.first, cc_addresses.first, bcc_addresses.first]
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
          ActionRecipient.config.whitelist.addresses = bcc_addresses
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

    context 'when no whitelist is specified' do
      let(:address) { 'foo@example.com' }
      it { is_expected.to be false }
    end

    context 'when address list is specified' do
      before do
        ActionRecipient.config.whitelist.addresses = custom_whitelist
      end

      context 'with string matcher' do
        let(:custom_whitelist) { ['foo@example.com'] }

        context 'with a whitelisted address' do
          let(:address) { 'foo@example.com' }
          it { is_expected.to be true }
        end

        context 'with non-whitelisted address' do
          let(:address) { 'bar@example.com' }
          it { is_expected.to be false }
        end
      end

      context 'with regexp matcher' do
        let(:custom_whitelist) { [/foo@example\.(co\.jp|com)/] }

        context 'with a whitelisted address' do
          let(:address) { 'foo@example.comjp' }
          it { is_expected.to be true }
        end

        context 'with non-whitelisted address' do
          let(:address) { 'foo_100@example.com' }
          it { is_expected.to be false }
        end
      end
    end

    context 'when domain list is specified' do
      before do
        ActionRecipient.config.whitelist.domains = custom_whitelist
      end

      context 'with string matcher' do
        let(:custom_whitelist) { ['example.com'] }

        context 'with a whitelisted domain' do
          let(:address) { 'foo@example.com' }
          it { is_expected.to be true }
        end

        context 'with non-whitelisted domain' do
          let(:address) { 'foo@example.com.jp' }
          it { is_expected.to be false }
        end
      end

      context 'with regexp matcher' do
        let(:custom_whitelist) { [/example/] }

        context 'with a whitelisted domain' do
          let(:address) { 'foo@example.com' }
          it { is_expected.to be true }
        end

        context 'with non-whitelisted domain' do
          let(:address) { 'example@sample.com' }
          it { is_expected.to be false }
        end
      end
    end
  end

  describe '.match_with_any_whitelisted_addresses?' do
    subject { described_class.match_with_any_whitelisted_addresses?(address) }

    before do
      ActionRecipient.config.whitelist.addresses = custom_whitelist
    end

    context 'with String matcher' do
      let(:custom_whitelist) { ['foo@example.com'] }

      context 'with a parfect matching address' do
        let(:address) { 'foo@example.com' }
        it { is_expected.to be true }
      end

      context 'with a partially matching address' do
        context 'with forward matching address' do
          let(:address) { 'foo@example.co' }
          it { is_expected.to be false }
        end

        context 'with backward matching address' do
          let(:address) { 'o@example.com' }
          it { is_expected.to be false }
        end
      end

      context 'with an address containing one of the whitelisted addresses' do
        let(:address) { 'foo@example.com.com' }
        it { is_expected.to be false }
      end

      context 'with non-matching address' do
        let(:address) { 'bar@example.co.jp' }
        it { is_expected.to be false }
      end
    end

    context 'with Regexp matcher' do
      let(:custom_whitelist) { [/foo@example.com/] }

      context 'with a parfect matching address' do
        let(:address) { 'foo@example.com' }
        it { is_expected.to be true }
      end

      context 'with a partially matching address' do
        context 'with forward matching address' do
          let(:address) { 'foo@example.co' }
          it { is_expected.to be false }
        end

        context 'with backward matching address' do
          let(:address) { 'o@example.com' }
          it { is_expected.to be false }
        end
      end

      context 'with an address containing one of the whitelisted addresses' do
        let(:address) { 'foo.foo@example.com.com' }
        it { is_expected.to be true }
      end

      context 'with non-matching address' do
        let(:address) { 'bar@example.co.jp' }
        it { is_expected.to be false }
      end
    end
  end

  describe '.match_with_any_whitelisted_domains?' do
    subject { described_class.match_with_any_whitelisted_domains?(domain) }

    before do
      ActionRecipient.config.whitelist.domains = custom_whitelist
    end

    context 'with String matcher' do
      let(:custom_whitelist) { ['example.com'] }

      context 'with a parfect matching domain' do
        let(:domain) { 'example.com' }
        it { is_expected.to be true }
      end

      context 'with a partially matching domain' do
        context 'with forward matching domain' do
          let(:domain) { 'example.co' }
          it { is_expected.to be false }
        end

        context 'with backward matching domain' do
          let(:domain) { 'xample.com' }
          it { is_expected.to be false }
        end
      end

      context 'with an domain containing one of the whitelisted domaines' do
        let(:domain) { 'subdomain.example.com' }
        it { is_expected.to be false }
      end

      context 'with non-matching domain' do
        let(:domain) { 'example.co.jp' }
        it { is_expected.to be false }
      end
    end

    context 'with Regexp matcher' do
      let(:custom_whitelist) { [/example.com\z/] }

      context 'with a parfect matching domain' do
        let(:domain) { 'example.com' }
        it { is_expected.to be true }
      end

      context 'with a partially matching domain' do
        context 'with forward matching domain' do
          let(:domain) { 'example.co' }
          it { is_expected.to be false }
        end

        context 'with backward matching domain' do
          let(:domain) { 'xample.com' }
          it { is_expected.to be false }
        end
      end

      context 'with an domain containing one of the whitelisted domaines' do
        let(:domain) { 'subdomain.example.com' }
        it { is_expected.to be true }
      end

      context 'with non-matching domain' do
        let(:domain) { 'example.co.jp' }
        it { is_expected.to be false }
      end
    end
  end

  describe '.whitelist' do
    subject { described_class.whitelist }
    it { is_expected.to be_an_instance_of ActionRecipient::Configuration::Whitelist }

    describe '#addresses' do
      subject { described_class.whitelist.addresses }
      it { is_expected.to eq [] }

      context 'when custom list is given' do
        before do
          ActionRecipient.config.whitelist.addresses = custom_whitelist
        end

        let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }
        it { is_expected.to eq custom_whitelist }
      end
    end

    describe '#domains' do
      subject { described_class.whitelist.domains }
      it { is_expected.to eq [] }

      context 'when custom list is given' do
        before do
          ActionRecipient.config.whitelist.domains = custom_whitelist
        end

        let(:custom_whitelist) { ['foo@example.com', 'bar@example.com'] }
        it { is_expected.to eq custom_whitelist }
      end
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
