task dump_output: :environment do
  test_klass =
    Class.new do
      include ActionDispatch::Integration::Runner

      def app
        Rails.application
      end

      def run_test
        get ENV.fetch('TEST_REQUEST_PATH')
        $stdout << response.body
      end
    end

  test_klass.new.run_test
end
