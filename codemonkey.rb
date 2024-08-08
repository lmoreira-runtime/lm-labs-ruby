require 'net/http'
require 'json'
require 'uri'
require 'dotenv'

class Codemonkey

  def initialize(base_url:, llm_api_key:, github_token:, repo_owner:, repo_name:, user_name: nil)
    @base_url = base_url
    @llm_api_key = llm_api_key
    @github_token = github_token
    @repo_owner = repo_owner
    @repo_name = repo_name
    @user_name = user_name
  end

  def run_codemonkey(issue_number:)
    request_body = {
      github_token: @github_token, 
      repo_owner: @repo_owner, 
      repo_name: @repo_name, 
      issue_number: issue_number, 
      litellm_api_key: @llm_api_key
    }
    request(:post, '/codemonkey/run', request_body, @llm_api_key)
  end

  def llm_with_context(issue_summary:)
    request_body = {
      github: { github_token: @github_token, repo_owner: @repo_owner, repo_name: @repo_name, user_name: @user_name },
      params: { issue_summary: issue_summary, token: @llm_api_key }
    }
    request(:post, '/codemonkey/llm_with_context', request_body, @llm_api_key)
  end

  def list_issues(assignee: nil, state: 'open', per_page: 100)
    request_body = {
      request: { github_token: @github_token, repo_owner: @repo_owner, repo_name: @repo_name, user_name: @user_name },
      params: { assignee: assignee, state: state, per_page: per_page }
    }
    request(:post, '/github/list-issues', request_body)
  end

  def get_issue(issue_number:)
    request_body = {
      request: { github_token: @github_token, repo_owner: @repo_owner, repo_name: @repo_name, user_name: @user_name },
      params: { issue_number: issue_number }
    }
    request(:post, '/github/get-issue', request_body)
  end

  def create_branch(branch_name:, original_branch: 'main')
    request_body = {
      request: { github_token: @github_token, repo_owner: @repo_owner, repo_name: @repo_name, user_name: @user_name },
      params: { branch_name: branch_name, original_branch: original_branch }
    }
    request(:post, '/github/create-branch', request_body)
  end

  def change_issue_status(issue_number:, state:)
    request_body = {
      request: { github_token: @github_token, repo_owner: @repo_owner, repo_name: @repo_name, user_name: @user_name },
      params: { issue_number: issue_number, state: state }
    }
    request(:post, '/github/change-issue-status', request_body)
  end

  def commit_changes(message:, branch_name:, files:)
    request_body = {
      request: { github_token: @github_token, repo_owner: @repo_owner, repo_name: @repo_name, user_name: @user_name },
      params: { message: message, branch_name: branch_name, files: files }
    }
    request(:post, '/github/commit-changes', request_body)
  end

  def create_pull_request(head:, base: 'main', title: 'New Pull Request', body: '')
    request_body = {
      request: { github_token: @github_token, repo_owner: @repo_owner, repo_name: @repo_name, user_name: @user_name },
      params: { head: head, base: base, title: title, body: body }
    }
    request(:post, '/github/create-pull-request', request_body)
  end

  def clone_repo
    request_body = {
      github_token: @github_token,
      repo_owner: @repo_owner,
      repo_name: @repo_name,
      user_name: @user_name
    }
    request(:post, '/github/clone', request_body)
  end

  private

  def request(method, path, body = nil, api_key = nil)
    uri = URI.join(@base_url, path)
    #http = Net::HTTP.new(uri.host, uri.port, use_ssl: uri.scheme == 'https')
    http = Net::HTTP.new(uri.host, uri.port)
    req = build_request(method, uri, body, api_key)
    response = http.request(req)
    parse_response(response)
  end

  def build_request(method, uri, body, api_key = nil)
    case method
    when :post
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body.to_json if body
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{api_key}" if api_key
    end
    request
  end

  def parse_response(response)
    return {} if response.body.nil? || response.body.strip.empty?
    case response.code.to_i
    when 200
      JSON.parse(response.body)
    when 422
      raise "Validation Error: #{response.body}"
    else
      raise "Unexpected Error: #{response.code} - #{response.body}"
    end
  end
end
