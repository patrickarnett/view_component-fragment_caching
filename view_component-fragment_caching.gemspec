require_relative 'lib/view_component/fragment_caching/version'

::Gem::Specification.new do |spec|
  spec.name        = 'view_component-fragment_caching'
  spec.version     = ::ViewComponent::FragmentCaching::VERSION
  spec.authors     = ['Patrick Arnett']
  spec.email       = ['patrick.a.arnett@gmail.com']
  spec.summary     = 'Bust fragment caches when view components update'
  spec.description = 'Monkey patch ActionView and ViewComponent to detect and compile' \
                     'updated view components within cached fragments.'
  spec.license     = 'MIT'

  github_url = 'https://www.github.com/patrickarnett/view_component-fragment_caching'
  spec.metadata['source_code_uri'] = github_url
  spec.metadata['changelog_uri'] = "#{github_url}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 2.6.0'

  spec.files =
    ::Dir.chdir ::File.expand_path(__dir__) do
      ::Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
    end

  spec.add_dependency 'rails', '~> 7.0'
  spec.add_dependency 'view_component', '~> 2.43'

  spec.add_development_dependency 'capybara', '~> 3.36'
  spec.add_development_dependency 'rspec-rails', '~> 5.1'
  spec.add_development_dependency 'rubocop', '~> 1.26'
  spec.add_development_dependency 'rubocop-rails', '~> 2.14'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.10'
  spec.add_development_dependency 'pry-rails'
end
