require 'rails_helper'
require 'support/component_file'

# rubocop:disable Metrics/BlockLength
describe 'fragment caching', type: :feature do
  let(:blog) { Blog.new original_title }
  let(:path_namespace) { "#{path_namespace_base}/#{path_namespace_suffix}" }
  let(:vc_path) { "#{vc_base_path}/#{vc_name}" }
  let(:rb_file) { ComponentFile.new "#{vc_path}.rb" }
  let(:view_file) { ComponentFile.new "#{vc_path}.html.erb" }
  let(:original_title) { 'Title 1' }
  let(:updated_title) { 'Title 2' }

  def initialize_cache_and_set_baseline
    refresh_page
    set_baseline
  end

  def refresh_page
    visit "/#{path_namespace}/#{path}?#{blog.to_query}"
  end

  def update_object_and_assert_cache_has_not_bust
    blog.title = updated_title
    refresh_page
    assert_cache_has_not_bust
  end

  def update_test_file_and_refresh
    test_file.load version: 2
    refresh_page
  end

  # rubocop:disable Naming/AccessorMethodName
  def set_baseline_for_has_own_view_file(title: nil)
    assert_has_own cached_text: original_title,
                   uncached_text: title || original_title
  end
  # rubocop:enable Naming/AccessorMethodName
  alias_method :assert_baseline_for_has_own_view_file, :set_baseline_for_has_own_view_file

  # rubocop:disable Naming/AccessorMethodName
  def set_baseline_for_inherited_view_file(title: nil)
    assert_inherited cached_text: original_title,
                     uncached_text: title || original_title
  end
  # rubocop:enable Naming/AccessorMethodName
  alias_method :assert_baseline_for_inherited_view_file, :set_baseline_for_inherited_view_file

  def assert_cache_has_not_bust_for_own_view_file
    assert_baseline_for_has_own_view_file title: updated_title
  end

  def assert_cache_has_not_bust_for_inherited_view_file
    assert_baseline_for_inherited_view_file title: updated_title
  end

  def assert_uses_updated_ruby_file
    assert_has_own ruby: 2
  end

  def assert_uses_updated_view_file
    assert_has_own view: 2
  end

  def assert_uses_updated_rendered_ruby_file
    assert_inherited child: 2
  end

  def assert_uses_updated_inherited_ruby_file
    assert_inherited ruby: 2
  end

  def assert_uses_updated_inherited_view_file
    assert_inherited view: 2
  end

  def assert_base(ruby:, view:, text:)
    page.assert_selector '#uncached', text: text
    page.assert_no_selector "[ruby-version=#{other_version ruby}]"
    page.assert_no_selector "[view-version=#{other_version view}]"
  end

  def assert_has_own(ruby: 1, view: 1, text: updated_title, cached_text: text, uncached_text: text)
    assert_base ruby: ruby, view: view, text: uncached_text
    page.assert_selector "[ruby-version=#{ruby}][view-version=#{view}]", text: cached_text
  end

  # rubocop:disable Metrics/ParameterLists
  def assert_inherited(child: 1, ruby: 1, view: 1, text: updated_title, cached_text: text, uncached_text: text)
    assert_base ruby: ruby, view: view, text: uncached_text
    page.assert_selector "[child-ruby-version=#{child}][ruby-version=#{ruby}][view-version=#{view}]", text: cached_text
    page.assert_no_selector "[child-ruby-version=#{other_version child}]"
  end
  # rubocop:enable Metrics/ParameterLists

  def other_version(version)
    version == 1 ? 2 : 1
  end

  before do
    initialize_cache_and_set_baseline
    update_object_and_assert_cache_has_not_bust
    update_test_file_and_refresh
  end

  after do
    files.each(&:reset)
    Rails.cache.clear
  end

  shared_context 'with render dependency' do
    let(:path_namespace_suffix) { 'render_dependencies' }
  end

  shared_context 'with explicit dependency' do
    let(:path_namespace_suffix) { 'explicit_dependencies' }
  end

  shared_context 'with its own view file' do
    let!(:files) { [rb_file, view_file] }
    let(:path) { 'vc_has_own_view' }

    def set_baseline
      set_baseline_for_has_own_view_file
    end

    def assert_cache_has_not_bust
      assert_cache_has_not_bust_for_own_view_file
    end
  end

  shared_context 'with an inherited view file' do
    let(:rendered_rb_file) { ComponentFile.new "#{vc_base_path}/extended_#{vc_name}.rb" }
    let(:inherited_rb_file) { rb_file }
    let(:inherited_view_file) { view_file }
    let!(:files) { [rendered_rb_file, inherited_rb_file, inherited_view_file] }
    let(:path) { 'vc_inherits_view' }

    def set_baseline
      set_baseline_for_inherited_view_file
    end

    def assert_cache_has_not_bust
      assert_cache_has_not_bust_for_inherited_view_file
    end
  end

  context 'when view component dependency is configured for tracking' do
    let(:vc_base_path) { 'app/included_components/blogs' }
    let(:path_namespace_base) { 'tracked_dependencies' }
    let(:vc_name) { 'blog_component' }

    context 'when dependency is detected via `render` call' do
      include_context 'with render dependency'

      context 'when rendered component has its own view file' do
        include_context 'with its own view file'

        context "when rendered component's view file is updated" do
          let(:test_file) { view_file }

          it 'uses the updated view file' do
            assert_uses_updated_view_file
          end
        end

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rb_file }

          it 'uses the updated ruby file' do
            assert_uses_updated_ruby_file
          end
        end
      end

      context 'when rendered component inherits a view file' do
        include_context 'with an inherited view file'

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rendered_rb_file }

          it 'uses the updated ruby file' do
            assert_uses_updated_rendered_ruby_file
          end
        end

        context "when inherited component's ruby file is updated" do
          let(:test_file) { inherited_rb_file }

          it 'uses the updated ruby file' do
            assert_uses_updated_inherited_ruby_file
          end
        end

        context "when inherited component's view file is updated" do
          let(:test_file) { inherited_view_file }

          it 'uses the updated view file' do
            assert_uses_updated_inherited_view_file
          end
        end
      end
    end

    context 'when dependency is explicit' do
      include_context 'with explicit dependency'

      context 'when specified component has its own view file' do
        include_context 'with its own view file'

        context "when rendered component's view file is updated" do
          let(:test_file) { view_file }

          it 'uses the updated view file' do
            assert_uses_updated_view_file
          end
        end

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rb_file }

          it 'uses the updated ruby file' do
            assert_uses_updated_ruby_file
          end
        end
      end

      context 'when specified component inherits a view file' do
        include_context 'with an inherited view file'

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rendered_rb_file }

          it 'uses the updated ruby file' do
            assert_uses_updated_rendered_ruby_file
          end
        end

        context "when inherited component's ruby file is updated" do
          let(:test_file) { inherited_rb_file }

          it 'uses the updated ruby file' do
            assert_uses_updated_inherited_ruby_file
          end
        end

        context "when inherited component's view file is updated" do
          let(:test_file) { inherited_view_file }

          it 'uses the updated view file' do
            assert_uses_updated_inherited_view_file
          end
        end
      end
    end
  end

  context 'when the view component dependency is not configured for tracking' do
    let(:vc_base_path) { 'app/excluded_components/users' }
    let(:path_namespace_base) { 'untracked_dependencies' }
    let(:vc_name) { 'user_component' }

    context 'when dependency is detected via `render` call' do
      include_context 'with render dependency'

      context 'when rendered component has its own view file' do
        include_context 'with its own view file'

        context "when rendered component's view file is updated" do
          let(:test_file) { view_file }

          it 'does not use the updated view file' do
            assert_cache_has_not_bust
          end
        end

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rb_file }

          it 'does not use the updated ruby file' do
            assert_cache_has_not_bust
          end
        end
      end

      context 'when rendered component inherits a view file' do
        include_context 'with an inherited view file'

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rendered_rb_file }

          it 'does not use the updated ruby file' do
            assert_cache_has_not_bust
          end
        end

        context "when inherited component's ruby file is updated" do
          let(:test_file) { inherited_rb_file }

          it 'does not use the updated ruby file' do
            assert_cache_has_not_bust
          end
        end

        context "when inherited component's view file is updated" do
          let(:test_file) { inherited_view_file }

          it 'does not use the updated view file' do
            assert_cache_has_not_bust
          end
        end
      end
    end

    context 'when dependency is explicit' do
      include_context 'with explicit dependency'

      context 'when specified component has its own view file' do
        include_context 'with its own view file'

        context "when rendered component's view file is updated" do
          let(:test_file) { view_file }

          it 'does not use the updated view file' do
            assert_cache_has_not_bust
          end
        end

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rb_file }

          it 'does not use the updated ruby file' do
            assert_cache_has_not_bust
          end
        end
      end

      context 'when specified component inherits a view file' do
        include_context 'with an inherited view file'

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rendered_rb_file }

          it 'does not use the updated ruby file' do
            assert_cache_has_not_bust
          end
        end

        context "when inherited component's ruby file is updated" do
          let(:test_file) { inherited_rb_file }

          it 'does not use the updated ruby file' do
            assert_cache_has_not_bust
          end
        end

        context "when inherited component's view file is updated" do
          let(:test_file) { inherited_view_file }

          it 'does not use the updated view file' do
            assert_cache_has_not_bust
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
