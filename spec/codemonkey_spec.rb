# frozen_string_literal: true

require 'spec_helper'
require_relative '../codemonkey'
require 'dotenv'

Dotenv.load

llm_api_key = ENV.fetch('OPENAI_API_KEY', nil)
github_token = ENV.fetch('GITHUB_ACCESS_TOKEN', nil)
repo_owner = ENV.fetch('GITHUB_OWNER', nil)
repo_name = ENV.fetch('GITHUB_REPO', nil)
user_name = ENV.fetch('GITHUB_USERNAME', nil)
base_url = ENV.fetch('BASE_URL', nil)

RSpec.describe Codemonkey, :vcr do
  before do
    @codemonkey = Codemonkey.new(
      base_url: base_url,
      llm_api_key: llm_api_key,
      github_token: github_token,
      repo_owner: repo_owner,
      repo_name: repo_name,
      user_name: user_name
    )
  end

  describe '#list_issues' do
    it 'lists issues from the repository' do
      response = @codemonkey.list_issues(assignee: user_name)
      expect(response).to be_a(Array)
    end
  end

  describe '#get_issue' do
    it 'gets a specific issue' do
      response = @codemonkey.get_issue(issue_number: 4)
      expect(response).to be_a(Hash)
    end
  end

  describe '#create_branch' do
    it 'creates a new branch' do
      response = @codemonkey.create_branch(branch_name: 'new-new-branch')
      expect(response).to be_a(Hash)
    end
  end

  describe '#commit_changes' do
    it 'commits changes to a branch' do
      files = ['/tmp/lmoreira-runtime/labs-tests/test.txt']
      response = @codemonkey.commit_changes(message: 'Test commit', branch_name: 'new-new-branch', files: files)
      expect(response).to be_a(Hash)
    end
  end

  describe '#create_pull_request' do
    it 'creates a new pull request' do
      response = @codemonkey.create_pull_request(head: 'new-new-branch')
      expect(response).to be_a(Hash)
    end
  end

  describe '#clone_repo' do
    it 'clones the repository' do
      response = @codemonkey.clone_repo
      expect(response).to be_a(String)
    end
  end

  describe '#llm_with_context' do
    it 'makes a request to get LLM context' do
      response = @codemonkey.llm_with_context(issue_summary: 'Develop a "Hello World" in python.')
      expect(response).to be_a(Array)
    end
  end

  describe '#run_codemonkey' do
    it 'makes a request to run codemonkey' do
      response = @codemonkey.run_codemonkey(issue_number: 4)
      expect(response).to be_nil
    end
  end

  describe '#change_issue_status' do
    it 'changes the status of an issue' do
      response = @codemonkey.change_issue_status(issue_number: 4, state: 'closed')
      expect(response).to be_a(Hash)
    end
  end
end
