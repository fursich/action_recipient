![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/fursich/action_recipient?color=green&style=plastic)
![GitHub](https://img.shields.io/github/license/fursich/action_recipient?color=green&style=plastic)
![Travis (.org)](https://img.shields.io/travis/fursich/action_recipient?color=green&style=plastic)

# ActionRecipient

This gem dynamically overwrites email recipients addresses sent with ActionMailer.
With this gem, you no longer have to worry about your application delivering accidental emails to your real customer in non-production environments.

It is particularily helpful if you are using gmail account for your staging mail, as it can append original recipients information in the address. (See [below](#Using Gmail) for details)

* although this gem has been developed and tested carefully, but there is no guarantee that this is 100% reliable. Please use this at your own risks, and test carefully before use.

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

Set up ActionRecipient as follows to prevent outgoing mails in your staging environment.

```ruby
# config/initializers/action_recipient.rb

if Rails.env.staging? # effective only in staging environment

  ActionRecipient.configure do |config|
    config.format = 'your_address_to_redirect@your_domain.com' # address that the emails to be redirected
  end

  ActionMailer::Base.register_interceptor(ActionRecipient::Interceptor) # register it as interceptor
end
```

If your colleague (in staging environment) accidentally send an email to `admin@your_client.com`, this gem overwrites its addresses as `your_address_to_redirect+admin_at_your_client.com@gmail.com` with help of ActionMailer's interceptor.

### Whitelist

Let's say, you wish to trap any outgoing emails, with an exception, e.g. `my_personal_adddress@example.com` that has to be actually delivered without interception.

You can' whitelist' such email addresses as follows:

```ruby
# config/initializers/action_recipient.rb

if Rails.env.staging?

  ActionRecipient.configure do |config|
    config.format = 'your_address_to_redirect+%s@gmail.com'

    # specify whitelisted addresses  as follows
    config.whitelist.addresses = [
      'safe_address@my-company.com',
      'my_personal_adddress@my-company.com'
    ]
  end

  ActionMailer::Base.register_interceptor(ActionRecipient::Interceptor)
end
```

You can also whitelist all the emails that belong to perticular domain:

```ruby
ActionRecipient.configure do |config|
  config.whitelist.domains = [
    'my-company.com'
  ]
end
```

Note: With a string matcher, you can whitelist only an address that has perfect match with it. If you prefer to whitelist all the addresses that belong to **any subdomains** under a specific domain, use regular expression instead.

```ruby
ActionRecipient.configure do |config|
  config.whitelist.domains = [
    'my-company.com',      # exact match
    /\.my-company.com\z/,  # any subdomains
  ]
end
```

This way an address such as `somebody@sales.my-company.com` is whitelisted, thus can deliver an out-going emails without getting trapped.

### Using Gmail

You might wish to keep original recipient addresses somehow, so that you can confirm where the email must have been delivered to unless it gets trapped.

This gem accepts a format where `%s` are dynamically replaced with the original address, prefixed with type of destination field (`to`, `cc`, or `bcc`).


```ruby
# config/initializers/action_recipient.rb

if Rails.env.staging? # effective only in staging environment

  ActionRecipient.configure do |config|
    config.format = 'your_address_to_redirect+%s@gmail.com' # destination type and original address will be appended after your address
  end

  ActionMailer::Base.register_interceptor(ActionRecipient::Interceptor)
end
```

This feature is particularity useful if you use gmail - as it ignores any strings that follow after a plus (+) sign appended in your address.

## Detailed Settings

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
      'my_colleagues_address@my-workplace.com'
      'a-contractor@somebody.net',
    ]

    config.whitelist.domains = [
      'my-department.my-workplace.com',
      /(\.|\A)my-private-domain.com\z/
    ]
  end
```

Whitelisted emails addresses are not overwritten, thus can be delivered as usual.

IMPORTANT:
"domains" are the last part of email addresses after `@`, and matched with original email address literally on word-to-word basis.

So whitelisted domains such as `bar.com` does NOT whitelist emails to subdomains like `somebody@foo.bar.com` (therefore redirected).

If you wish to whitelist a domain including all the subdomains under it, use regular expressions as [described earlier](#detailed-settings)

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

## Acknoledgement

I'd like to thank @akeyhero who came up with the original idea about appending recipient information after plus leveraging gmail feature.
Although the implementation work is done by myself seperately, this gem greatly benefited from his inspiring idea.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
