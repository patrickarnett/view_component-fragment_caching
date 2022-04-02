require 'rails_helper'
require 'pry'
require 'support/component_file'

# rubocop:disable Metrics/BlockLength
describe 'fragment caching', type: :feature do
  let(:blog) { Blog.new title: 'Title 1' }

  context 'when view component dependency is configured for tracking' do
    let(:vc_base_path) { 'app/included_components/blogs' }

    before do
      initialize_cache_and_set_baseline
      update_object_and_assert_cache_has_not_bust
      update_test_file_and_refresh
    end

    after do
      files.each(&:reset)
      Rails.cache.clear
    end

    def refresh_page
      visit "/#{path_namespace}/#{path}?#{blog.to_query}"
    end

    def initialize_cache_and_set_baseline
      refresh_page
      set_baseline
    end

    def update_object_and_assert_cache_has_not_bust
      blog.title = 'Title 2'
      refresh_page
      assert_cache_has_not_bust
    end

    def update_test_file_and_refresh
      test_file.load_version 2
      refresh_page
    end

    context 'when dependency is detected via `render` call' do
      let(:path_namespace) { 'tracked_dependencies/render_dependencies' }

      context 'when rendered component has its own view file' do
        let(:vc_path) { "#{vc_base_path}/blog_component" }
        let(:rb_file) { ComponentFile.new "#{vc_path}.rb" }
        let(:view_file) { ComponentFile.new "#{vc_path}.html.erb" }
        let!(:files) { [rb_file, view_file] }
        let(:path) { 'vc_has_own_view' }

        def set_baseline
          page.assert_selector '#uncached', text: 'Title 1'
          page.assert_selector '[view-version=1][ruby-version=1]', text: 'Title 1'
          page.assert_no_selector '[view-version=2]'
          page.assert_no_selector '[ruby-version=2]'
        end

        def assert_cache_has_not_bust
          page.assert_selector '#uncached', text: 'Title 2'
          page.assert_selector '[view-version=1][ruby-version=1]', text: 'Title 1'
          page.assert_no_selector '[view-version=2]'
          page.assert_no_selector '[ruby-version=2]'
        end

        context "when rendered component's view file is updated" do
          let(:test_file) { view_file }

          it 'uses the updated view file' do
            page.assert_selector '#uncached', text: 'Title 2'
            page.assert_selector '[view-version=2][ruby-version=1]', text: 'Title 2'
            page.assert_no_selector '[view-version=1]'
            page.assert_no_selector '[ruby-version=2]'
          end
        end

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rb_file }

          it 'uses the updated ruby file' do
            page.assert_selector '#uncached', text: 'Title 2'
            page.assert_selector '[view-version=1][ruby-version=2]', text: 'Title 2'
            page.assert_no_selector '[ruby-version=1]'
            page.assert_no_selector '[view-version=2]'
          end
        end
      end

      context 'when rendered component inherits a view file' do
        let(:rendered_rb_file) { ComponentFile.new "#{vc_base_path}/extended_blog_component.rb" }
        let(:inherited_rb_file) { ComponentFile.new "#{vc_base_path}/blog_component.rb" }
        let(:inherited_view_file) { ComponentFile.new "#{vc_base_path}/blog_component.html.erb" }
        let!(:files) { [rendered_rb_file, inherited_rb_file, inherited_view_file] }
        let(:path) { 'vc_inherits_view' }

        def set_baseline
          page.assert_selector '#uncached', text: 'Title 1'
          page.assert_selector '[view-version=1][ruby-version=1][child-ruby-version=1]', text: 'Title 1'
          page.assert_no_selector '[view-version=2]'
          page.assert_no_selector '[ruby-version=2]'
          page.assert_no_selector '[child-ruby-version=2]'
        end

        def assert_cache_has_not_bust
          page.assert_selector '#uncached', text: 'Title 2'
          page.assert_selector '[view-version=1][ruby-version=1][child-ruby-version=1]', text: 'Title 1'
          page.assert_no_selector '[view-version=2]'
          page.assert_no_selector '[ruby-version=2]'
          page.assert_no_selector '[child-ruby-version=2]'
        end

        context "when rendered component's ruby file is updated" do
          let(:test_file) { rendered_rb_file }

          it 'uses the updated ruby file' do
            page.assert_selector '#uncached', text: 'Title 2'
            page.assert_selector '[view-version=1][ruby-version=1][child-ruby-version=2]', text: 'Title 2'
            page.assert_no_selector '[view-version=2]'
            page.assert_no_selector '[ruby-version=2]'
            page.assert_no_selector '[child-ruby-version=1]'
          end
        end

        context "when inherited component's ruby file is updated" do
          let(:test_file) { inherited_rb_file }

          it 'uses the updated ruby file' do
            page.assert_selector '#uncached', text: 'Title 2'
            page.assert_selector '[view-version=1][ruby-version=2][child-ruby-version=1]', text: 'Title 2'
            page.assert_no_selector '[view-version=2]'
            page.assert_no_selector '[ruby-version=1]'
            page.assert_no_selector '[child-ruby-version=2]'
          end
        end

        context "when inherited component's view file is updated" do
          let(:test_file) { inherited_view_file }

          it 'uses the updated view file' do
            page.assert_selector '#uncached', text: 'Title 2'
            page.assert_selector '[view-version=2][ruby-version=1][child-ruby-version=1]', text: 'Title 2'
            page.assert_no_selector '[view-version=1]'
            page.assert_no_selector '[ruby-version=2]'
            page.assert_no_selector '[child-ruby-version=2]'
          end
        end
      end
    end

    context 'when dependency is explicit' do
      let(:path_namespace) { 'tracked_dependencies/render_dependencies' }

      context 'when specified component has its own view file' do
        let(:vc_path) { "#{vc_base_path}/blog_component" }
        let(:rb_file) { ComponentFile.new "#{vc_path}.rb" }
        let(:view_file) { ComponentFile.new "#{vc_path}.html.erb" }
        let!(:files) { [rb_file, view_file] }
        let(:path) { 'vc_has_own_view' }

        def set_baseline
          page.assert_selector '#uncached', text: 'Title 1'
          page.assert_selector '[view-version=1][ruby-version=1]', text: 'Title 1'
          page.assert_no_selector '[view-version=2]'
          page.assert_no_selector '[ruby-version=2]'
        end

        def assert_cache_has_not_bust
          page.assert_selector '#uncached', text: 'Title 2'
          page.assert_selector '[view-version=1][ruby-version=1]', text: 'Title 1'
          page.assert_no_selector '[view-version=2]'
          page.assert_no_selector '[ruby-version=2]'
        end

        context "when rendered component's view file is updated" do
          let(:test_file) { view_file }

          it 'uses the updated view file' do
            page.assert_selector '#uncached', text: 'Title 2'
            page.assert_selector '[view-version=2][ruby-version=1]', text: 'Title 2'
            page.assert_no_selector '[view-version=1]'
            page.assert_no_selector '[ruby-version=2]'
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
