RSpec.describe ActionRecipient::Interceptor do

  before do
    ActionRecipient.reset_config!
  end

  describe '.delivering_email' do
    let(:mail)          { Mail.new }
    let(:to_addresses)  { ['foo_bar@foo.com', 'bar+baz@bar.org'] }
    let(:cc_addresses)  { ['foo@foo.jp',  'bar@bar.jp'] }
    let(:bcc_addresses) { ['foo@foo.fr',  'bar@bar.fr'] }

    before do
      ActionRecipient.config.format = format

      mail[:to]  = to_addresses
      mail[:cc]  = cc_addresses
      mail[:bcc] = bcc_addresses
    end

    subject { described_class.delivering_email(mail) }

    shared_examples 'overwriting addresses' do
      it 'overwrites "to" addresses' do
        expect { subject }.to change { mail.to }.from(to_addresses).to(
          a_collection_containing_exactly(*to_addresses_converted)
        )
      end

      it 'overwrites "cc" addresses' do
        expect { subject }.to change { mail.cc }.from(cc_addresses).to(
          a_collection_containing_exactly(*cc_addresses_converted)
        )
      end

      it 'overwrites "bcc" addresses' do
        expect { subject }.to change { mail.bcc }.from(bcc_addresses).to(
          a_collection_containing_exactly(*bcc_addresses_converted)
        )
      end
    end

    context 'with static format with string interporation' do
      let(:format)        { 'staging_mail@example.com' }

      context 'with non-whitelisted addresses' do
        before do
          ActionRecipient.config.whitelist.addresses = %w[foo@foo.co.fr bar@bar.jm]
        end

        let(:to_addresses_converted) { [
          'staging_mail@example.com',
          'staging_mail@example.com'
        ] }

        let(:cc_addresses_converted) { [
          'staging_mail@example.com',
          'staging_mail@example.com'
        ] }

        let(:bcc_addresses_converted) { [
          'staging_mail@example.com',
          'staging_mail@example.com'
        ] }

        it_behaves_like 'overwriting addresses'
      end
    end

    context 'with dynamic format with string interporation' do
      let(:format)        { 'staging_mail+%s@example.com' }

      context 'with non-whitelisted addresses' do
        before do
          ActionRecipient.config.whitelist.addresses = %w[foo@foo.co.fr bar@bar.jm]
        end

        let(:to_addresses_converted) { [
          'staging_mail+foo_bar_at_foo.com@example.com',
          'staging_mail+bar-baz_at_bar.org@example.com'
        ] }

        let(:cc_addresses_converted) { [
          'staging_mail+cc_foo_at_foo.jp@example.com',
          'staging_mail+cc_bar_at_bar.jp@example.com'
        ] }

        let(:bcc_addresses_converted) { [
          'staging_mail+bcc_foo_at_foo.fr@example.com',
          'staging_mail+bcc_bar_at_bar.fr@example.com'
        ] }

        it_behaves_like 'overwriting addresses'
      end

      context 'with partially whitelisted addresses' do
        before do
          ActionRecipient.config.whitelist.addresses = [to_addresses.last, cc_addresses.last, bcc_addresses.last, 'foo@foo.co.fr', 'bar@bar.jm']
        end

        let(:to_addresses_converted) { [
          'staging_mail+foo_bar_at_foo.com@example.com',
          'bar+baz@bar.org'
        ] }

        let(:cc_addresses_converted) { [
          'staging_mail+cc_foo_at_foo.jp@example.com',
          'bar@bar.jp'
        ] }

        let(:bcc_addresses_converted) { [
          'staging_mail+bcc_foo_at_foo.fr@example.com',
          'bar@bar.fr'
        ] }

        it_behaves_like 'overwriting addresses'
      end

      context 'with whitelisted addresses' do
        before do
          ActionRecipient.config.whitelist.addresses = [*to_addresses, *cc_addresses, *bcc_addresses]
        end

        it 'keeps "to" addresses unchanged' do
          expect { subject }.not_to change { mail.to }
        end

        it 'keeps "cc" addresses unchanged' do
          expect { subject }.not_to change { mail.cc }
        end

        it 'keeps "bcc" addresses unchanged' do
          expect { subject }.not_to change { mail.bcc }
        end
      end

      context 'with non-whitelisted domains' do
        before do
          ActionRecipient.config.whitelist.domains = %w[foo.co.fr bar.jm]
        end

        let(:to_addresses_converted) { [
          'staging_mail+foo_bar_at_foo.com@example.com',
          'staging_mail+bar-baz_at_bar.org@example.com'
        ] }

        let(:cc_addresses_converted) { [
          'staging_mail+cc_foo_at_foo.jp@example.com',
          'staging_mail+cc_bar_at_bar.jp@example.com'
        ] }

        let(:bcc_addresses_converted) { [
          'staging_mail+bcc_foo_at_foo.fr@example.com',
          'staging_mail+bcc_bar_at_bar.fr@example.com'
        ] }

        it_behaves_like 'overwriting addresses'
      end

      context 'with partially whitelisted domains' do
        before do
          ActionRecipient.config.whitelist.domains = %w[bar.org bar.jp bar.fr foo.co.fr foo.jm]
        end

        let(:to_addresses_converted) { [
          'staging_mail+foo_bar_at_foo.com@example.com',
          'bar+baz@bar.org'
        ] }

        let(:cc_addresses_converted) { [
          'staging_mail+cc_foo_at_foo.jp@example.com',
          'bar@bar.jp'
        ] }

        let(:bcc_addresses_converted) { [
          'staging_mail+bcc_foo_at_foo.fr@example.com',
          'bar@bar.fr'
        ] }

        it_behaves_like 'overwriting addresses'
      end

      context 'with whitelisted domains' do
        before do
          ActionRecipient.config.whitelist.domains =  %w[foo.com foo.jp foo.fr bar.org bar.jp bar.fr]
        end

        it 'keeps "to" addresses unchanged' do
          expect { subject }.not_to change { mail.to }
        end

        it 'keeps "cc" addresses unchanged' do
          expect { subject }.not_to change { mail.cc }
        end

        it 'keeps "bcc" addresses unchanged' do
          expect { subject }.not_to change { mail.bcc }
        end
      end
    end
  end
end
