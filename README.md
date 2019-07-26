![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/fursich/action_recipient?color=green&style=plastic)
![GitHub](https://img.shields.io/github/license/fursich/action_recipient?color=green&style=plastic)
![Travis (.org)](https://img.shields.io/travis/fursich/action_recipient?color=green&style=plastic)

# ActionRecipient

This gem overwrites email recipients addresses sent with ActionMailer.
It helps you prevent your application from dispatching emails accidentally to existing addresses, expecially your users or clients in non-production environments.

* althugh this gem has been developed and tested carefully, but there is no guarantee that this is 100% reliable. Please use this at your own risks, and test carefully before use.

* Non-Actionmailer emails cannot be blocked nor redirected, as it works based on ActionMailer's interceptor mechanism.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_recipient'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install action_recipient

## Usage

### Getting Started

Let's say, you need to trap all the emails that are sent out in staging environment.

More specifically, you wish to replace outgoing emails' addresses to your work address `your_address_to_redirect@gmail.com`, with a few exception such as `my_personal_adddress@example.com`.

Set up ActionRecipient as follows, and you're done.

```ruby
# config/initializers/action_recipient.rb

if Rails.env.staging? # effective only in staging environment

  ActionRecipient.configure do |config|
    config.format = 'your_address_to_redirect+%s@gmail.com'

    config.whitelist.addresses = [
      'safe_address@example.com',
      'my_personal_adddress@example.com'
    ]
  end

  ActionMailer::Base.register_interceptor(ActionRecipient::Interceptor)
end
```

Then, if you send an email to `admin@your_client.com` using ActionMailer, this gem traps it and overwrites its addresses as `your_address_to_redirect+admin_at_your_client.com@gmail.com`.

You can find the email at your mailbox in `your_address_to_redirect@gmail.com`, just as your client would do if it were in production - with the only difference in its `to` address that are slightly modified.

### Detailed Settings

1. set your "safe address" to indicate ActionRecipient an address to redirect outgoing emails:

```ruby
  ActionRecipient.configure do |config|
    config.format = 'your_address_to_rediredt+%s@gmail.com'
  end
```

If you add **%s** in the format, it is automatically replaced with the original addresses after a few modifications. (see overwriting rules for deatils)

**DO NOT FORGET to specify a format**, otherwise your email addresses are not properly transformed, and your emails will not be successfully delivered.

2. you could also set a collection of whitelisted addresses and/or domains:

```ruby
  ActionRecipient.configure do |config|
    config.whitelist.addresses = [
      'my_personal_address@example.com',
      'my_colleagues_address@example.com'
    ]

    config.whitelist.domains = [
      'my_office_domain.com',
      'subdomain.my_office_domain.com'
    ]
  end
```

Whitelisted emails addresses are not overwritten, thus can be delivered as usual.

IMPORTANT:
With current version (version <~ 0.2.0) "domains" are the last part of email addresses after `@`, and matched with original email address literally on word-to-word basis.

So whitelisted domains such as `bar.com` does NOT whitelist emails to subdomains like `somebody@foo.bar.com` (therefore redirected).

3. register ActionRecipient as the interceptor

```ruby
  ActionMailer::Base.register_interceptor(ActionRecipient::Interceptor)
```

And you are good to go!

### Overwriting Rules

The original address is being transformed as follows:

- `@` is replaced with `_at_`
- any alphabetical/numeric charactors are preserved
- any dots `.` and underscores `_` are preserved as well
- any other charactors are replaced with hyphens `-`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fursich/action_recipient.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
