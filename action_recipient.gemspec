
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_recipient/version'

Gem::Specification.new do |spec|
  spec.name          = 'action_recipient'
  spec.version       = ActionRecipient::VERSION
  spec.authors       = ['Koji Onishi']
  spec.email         = ['fursich0@gmail.com']

  spec.summary       = 'Overwrites email recipients with ActionMailer emails to prevent accidental delivery in non-production environments.'
  spec.description   = 'Prevents accidental email delivery in non-production (typically staging) environments by replacing email addresses using ActionMailer\'s Interceptor.'
  spec.homepage      = 'https://github.com/fursich/action_recipient'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/fursich/action_recipient'
    # spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mail', '>= 2.5.4' # to liaise with ActionMailer 4.2 or higher

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
end
