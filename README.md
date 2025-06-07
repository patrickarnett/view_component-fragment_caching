# ViewComponent::FragmentCaching
With fragment caching in Rails, updates to a partial's source code will automatically bust
appropriate caches in which the partial is detectable as a dependency.

This gem augments ActionView's fragment caching strategy to detect and parse view components. In addition to digesting a
component's view file (if present), it will also digest the component's ruby file and those of any superclasses
descended from `ViewComponent::Base`. 

## Installation
Add this line to your application's Gemfile:

```ruby
gem "view_component-fragment_caching"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install view_component-fragment_caching
```

## Configuration
By default, view components will be detected in `ViewComponent::Base.view_component_path` (`app/components` typically).
This can be configured in an initializer:

```ruby
ViewComponent::FragmentCaching.configure do |c|
  c.view_component_paths = %w(
    app/components
    app/additional_components
  )
end
```

## Use
It is important that naming conventions are followed. The tracker will ignore components whose class names do not end with "Component".

#### Render dependencies
```erb
<%= render Users::AuthorComponent.new(...) %>
<%= render Users::AuthorComponent.with_collection(...) %>
```

#### Explicit dependencies
```erb
<%# View Component Dependency: Users::AuthorComponent %>
<%= render @author %>  
```

## Contributing
Please follow conventions and write tests.
```bash
$ bundle exec appraisal rspec
$ bundle exec rubocop
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
