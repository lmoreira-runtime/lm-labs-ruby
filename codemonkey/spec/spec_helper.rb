# frozen_string_literal: true

require "vcr"
require "webmock/rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock

  config.filter_sensitive_data("<OPENAI_API_KEY>") { ENV.fetch("OPENAI_API_KEY", nil) }
  config.filter_sensitive_data("<GITHUB_ACCESS_TOKEN>") { ENV.fetch("GITHUB_ACCESS_TOKEN", nil) }
  config.filter_sensitive_data("<GITHUB_OWNER>") { ENV.fetch("GITHUB_OWNER", nil) }
  config.filter_sensitive_data("<GITHUB_REPO>") { ENV.fetch("GITHUB_REPO", nil) }
  config.filter_sensitive_data("<GITHUB_USERNAME>") { ENV.fetch("GITHUB_USERNAME", nil) }
  config.filter_sensitive_data("<BASE_URL>") { ENV.fetch("BASE_URL", nil) }

  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = { record: :new_episodes }
end
