# ViewComponent::FragmentCaching
With fragment caching in Rails, updates to a partial's source code will automatically bust
appropriate caches in which the partial is detectable as a dependency. There are two types
of dependencies.

### Render dependencies
```ruby
<%= render 'path/to/partial' %>
<%= render Users::AuthorCardComponent.new(...) %>
<%= render @user %>
```
In the second and third examples, ActionView will guess that the associated partial is at
`/users/_user`.

### Explicit dependencies
```ruby
<%# Template Dependency: 'path/to/partial' %>
<%= render some_object %>
```



## Usage
How to use my plugin.

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

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
