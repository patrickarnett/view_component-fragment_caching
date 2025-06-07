require 'spec_helper'

require 'nokogiri'

# rubocop:disable Metrics/BlockLength, RSpec/MultipleExpectations
describe 'fragment caching' do
  before { clear_cache }
  after(:all) { clear_cache } # rubocop:disable RSpec/BeforeAfterAll

  def clear_cache
    with_dummy_app { `rm -rf tmp/cache` }
  end

  def modify_file(file)
    filename = "spec/dummy/#{file}"
    old_content = File.read filename
    begin
      File.open(filename, 'wb+') { |f| f.write "#{old_content}\n#comment" }
      yield
    ensure
      File.open(filename, 'wb+') { |f| f.write old_content }
    end
  end

  def with_dummy_app(&block)
    og_pwd = Dir.pwd
    Dir.chdir 'spec/dummy'
    block.call
  ensure
    Dir.chdir og_pwd
  end

  def render_output(path)
    with_dummy_app do
      Nokogiri::HTML(`RAILS_ENV=test TEST_REQUEST_PATH=#{path} bundle exec rake dump_output`)
    end
  end

  def extract_text(html, id)
    html.at_css(id).text.gsub(/\A\s+|\s+\z/, '')
  end

  context 'when components are tracked' do
    context 'when detected via render call' do
      context 'when child component has its own view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/included_components/blogs/component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'new title'
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/tracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/included_components/blogs/component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end

        context 'when parent view file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end

        context 'when child rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/extended_blog_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end

        context 'when view file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end
      end
    end

    context 'when detected via explicit dependency' do
      context 'when child component has its own view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/included_components/blogs/component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'new title'
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/tracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/included_components/blogs/component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end

        context 'when parent view file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end

        context 'when child rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/extended_blog_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end

        context 'when view file is updated' do
          it 'busts cache' do
            title = 'original title'
            path = "/tracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            title = 'new title'
            path = "/tracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'original title'

            modify_file('app/included_components/blogs/component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#blog-component')).to eq 'new title'
          end
        end
      end
    end
  end

  context 'when components are not tracked' do
    context 'when detected via render call' do
      context 'when child component has its own view file' do
        context 'when parent rb file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/render_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'does not busts cache' do
            title = 'original title'
            path = "/untracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end

        context 'when child rb file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/render_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/extended_user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end

        context 'when view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/render_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end
      end
    end

    context 'when detected via explicit dependency' do
      context 'when child component has its own view file' do
        context 'when parent rb file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/explicit_dependencies/vc_child_has_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#extended-with-view')).to eq 'original title'
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end

        context 'when child rb file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/explicit_dependencies/vc_inherits_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/extended_user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.rb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end

        context 'when view file is updated' do
          it 'does not bust cache' do
            title = 'original title'
            path = "/untracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'original title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            title = 'new title'
            path = "/untracked_dependencies/explicit_dependencies/vc_has_own_view?title=#{CGI.escape title}"
            html = render_output path
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'

            modify_file('app/excluded_components/users/user_component.html.erb') { html = render_output path }
            expect(extract_text(html, '#uncached')).to eq 'new title'
            expect(extract_text(html, '#user-component')).to eq 'original title'
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength, RSpec/MultipleExpectations
