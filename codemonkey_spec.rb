require 'rspec'
require 'webmock/rspec'
require_relative 'codemonkey' # Adjust path as necessary

RSpec.describe Codemonkey do
  let(:llm_api_key) { 'fake_llm_api_key' }
  let(:github_token) { 'fake_github_token' }
  let(:repo_owner) { 'fake_owner' }
  let(:repo_name) { 'fake_repo' }
  let(:user_name) { 'fake_user' }

  subject { Codemonkey.new(llm_api_key: llm_api_key, github_token: github_token, repo_owner: repo_owner, repo_name: repo_name, user_name: user_name) }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  it 'makes a POST request to /codemonkey/run with the correct body' do
    stub_request(:post, "http://api.example.com:443/codemonkey/run").
    with(
      body: "{\"issue_number\":123}",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Bearer fake_llm_api_key',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: "", headers: {})

    subject.run_codemonkey(issue_number: 123)
  end

  it 'makes a POST request to /codemonkey/llm_with_context with the correct body' do
    stub_request(:post, "http://api.example.com:443/codemonkey/llm_with_context").
         with(
           body: "{\"github\":{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"},\"issue_summary\":{\"issue_summary\":\"Issue summary text\"}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Authorization'=>'Bearer fake_llm_api_key',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.llm_with_context(issue_summary: 'Issue summary text')
  end

  it 'makes a POST request to /github/list-issues with the correct body' do
    stub_request(:post, "http://api.example.com:443/github/list-issues").
         with(
           body: "{\"request\":{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"},\"params\":{\"assignee\":\"user\",\"state\":\"closed\",\"per_page\":50}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.list_issues(assignee: 'user', state: 'closed', per_page: 50)
  end

  it 'makes a POST request to /github/get-issue with the correct body' do
    stub_request(:post, "http://api.example.com:443/github/get-issue").
         with(
           body: "{\"request\":{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"},\"params\":{\"issue_number\":123}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.get_issue(issue_number: 123)
  end

  it 'makes a POST request to /github/create-branch with the correct body' do
    stub_request(:post, "http://api.example.com:443/github/create-branch").
         with(
           body: "{\"request\":{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"},\"params\":{\"branch_name\":\"feature/new-branch\",\"original_branch\":\"main\"}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.create_branch(branch_name: 'feature/new-branch', original_branch: 'main')
  end

  it 'makes a POST request to /github/change-issue-status with the correct body' do
    stub_request(:post, "http://api.example.com:443/github/change-issue-status").
         with(
           body: "{\"request\":{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"},\"params\":{\"issue_number\":123,\"state\":\"closed\"}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.change_issue_status(issue_number: 123, state: 'closed')
  end

  it 'makes a POST request to /github/commit-changes with the correct body' do
    stub_request(:post, "http://api.example.com:443/github/commit-changes").
         with(
           body: "{\"request\":{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"},\"params\":{\"message\":\"Fixes bug\",\"branch_name\":\"feature/branch\",\"files\":[\"file1.rb\",\"file2.rb\"]}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.commit_changes(message: 'Fixes bug', branch_name: 'feature/branch', files: ['file1.rb', 'file2.rb'])
  end

  it 'makes a POST request to /github/create-pull-request with the correct body' do
    stub_request(:post, "http://api.example.com:443/github/create-pull-request").
         with(
           body: "{\"request\":{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"},\"params\":{\"head\":\"feature/branch\",\"base\":\"main\",\"title\":\"New Feature\",\"body\":\"Detailed description\"}}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.create_pull_request(head: 'feature/branch', base: 'main', title: 'New Feature', body: 'Detailed description')
  end

  it 'makes a POST request to /github/clone with the correct body' do
    stub_request(:post, "http://api.example.com:443/github/clone").
         with(
           body: "{\"github_token\":\"fake_github_token\",\"repo_owner\":\"fake_owner\",\"repo_name\":\"fake_repo\",\"user_name\":\"fake_user\"}",
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Content-Type'=>'application/json',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})

    subject.clone_repo
  end
end
