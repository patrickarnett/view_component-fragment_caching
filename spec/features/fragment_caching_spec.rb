require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'fragment caching', type: :feature do
  def modify_file(file)
    filename = Rails.root.join file
    old_content = File.read filename
    begin
      File.open(filename, 'wb+') { |f| f.write("#{old_content}\n#comment") }
      yield
    ensure
      File.open(filename, 'wb+') { |f| f.write(old_content) }
    end
  end

  context 'when components are tracked' do
    context 'when detected via render call' do
      context 'when child component has its own view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/render_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'new title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/render_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'original title'
            end
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/render_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/render_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end

        context 'when child rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/render_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/extended_blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/render_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end

        context 'when view file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/render_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end
      end
    end

    context 'when detected via explicit dependency' do
      context 'when child component has its own view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/explicit_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'new title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/explicit_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'original title'
            end
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/explicit_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/explicit_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end

        context 'when child rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/explicit_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/extended_blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/explicit_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
          end
        end

        context 'when view file is updated' do
          it 'busts cache' do
            blog = Blog.new 'original title'
            visit "tracked_dependencies/explicit_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#blog-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#blog-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#blog-component', text: 'new title'
            end
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
            blog = Blog.new 'original title'
            visit "untracked_dependencies/render_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'original title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/render_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'original title'
            end
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'does not busts cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/render_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/render_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end

        context 'when child rb file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/render_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/extended_blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/render_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end

        context 'when view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/render_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end
      end
    end

    context 'when detected via explicit dependency' do
      context 'when child component has its own view file' do
        context 'when parent rb file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/explicit_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'original title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/explicit_dependencies/vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#extended-with-view', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_child_has_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#extended-with-view', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_child_has_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#extended-with-view', text: 'original title'
            end
          end
        end
      end

      context 'when child component inherits view file' do
        context 'when parent rb file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/explicit_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end

        context 'when parent view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/explicit_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end

        context 'when child rb file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/explicit_dependencies/vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_inherits_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/extended_blog_component.rb' do
              visit "vc_inherits_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end
      end

      context 'when component inherits from vc base' do
        context 'when rb file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/explicit_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.rb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end

        context 'when view file is updated' do
          it 'does not bust cache' do
            blog = Blog.new 'original title'
            visit "untracked_dependencies/explicit_dependencies/vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'original title'
            assert_selector '#user-component', text: 'original title'

            blog = Blog.new 'new title'
            visit "vc_has_own_view?#{blog.to_query}"
            assert_selector '#uncached', text: 'new title'
            assert_selector '#user-component', text: 'original title'

            modify_file 'app/included_components/blogs/blog_component.html.erb' do
              visit "vc_has_own_view?#{blog.to_query}"
              assert_selector '#uncached', text: 'new title'
              assert_selector '#user-component', text: 'original title'
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
