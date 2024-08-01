require 'base64'
require 'net/http'
require 'json'
require 'logger'
require 'fileutils'
require 'git'

class GithubRequests
  attr_reader :github_token, :repo_owner, :repo_name, :username, :github_api_url, :directory_dir

  def initialize(github_token:, repo_owner:, repo_name:, user_name: nil)
    @github_token = github_token
    @repo_owner = repo_owner
    @repo_name = repo_name
    @username = user_name
    @github_api_url = "https://api.github.com/repos/#{repo_owner}/#{repo_name}"
    @directory_dir = "/tmp/#{repo_owner}/#{repo_name}"
    @logger = Logger.new($stdout)
  end

  def list_issues(assignee = nil, state = "open", per_page = 100)
    assignee ||= @username
    url = URI("#{@github_api_url}/issues")
    params = { state: state, per_page: per_page }
    params[:assignee] = assignee unless assignee == "all"

    response = make_request(url, params: params)
    return [] unless response

    JSON.parse(response.body)
  rescue StandardError => e
    @logger.error("An unexpected error occurred: #{e}")
    []
  end

  def get_issue(issue_number)
    url = URI("#{@github_api_url}/issues/#{issue_number}")

    response = make_request(url)
    return nil unless response

    JSON.parse(response.body)
  rescue StandardError => e
    @logger.error("An unexpected error occurred: #{e}")
    nil
  end

  def create_branch(branch_name, original_branch = "main")
    url = URI("#{@github_api_url}/git/refs/heads/#{original_branch}")
    response = make_request(url)
    return nil unless response && response.code.to_i == 200
    sha = JSON.parse(response.body)["object"]["sha"]
    create_ref_url = URI("#{@github_api_url}/git/refs")
    branch_name_str = branch_name[:branch_name]
    data = { ref: "refs/heads/#{branch_name_str}", sha: sha }.to_json
    response = make_request(create_ref_url, method: 'POST', body: data)
    JSON.parse(response.body) if response
  rescue StandardError => e
    @logger.error("An unexpected error occurred: #{e}")
    nil
  end

  def change_issue_status(issue_number, state)
    raise ArgumentError, "Invalid state. The state must be 'open' or 'closed'." unless %w[open closed].include?(state)

    url = URI("#{@github_api_url}/issues/#{issue_number}")
    data = { state: state }.to_json

    response = make_request(url, method: 'PATCH', body: data)
    JSON.parse(response.body) if response
  rescue StandardError => e
    @logger.error("An unexpected error occurred: #{e}")
    nil
  end

  def commit_changes(message:, branch_name:, files:)
    latest_commit_sha = get_latest_commit_sha(branch_name)
    return nil unless latest_commit_sha

    base_tree_sha = get_base_tree_sha(latest_commit_sha)
    tree_items = files.map { |file_path| create_blob(file_path) }
    new_tree_sha = create_tree(base_tree_sha, tree_items)
    new_commit_sha = create_commit(message, latest_commit_sha, new_tree_sha)
    update_branch_ref(branch_name, new_commit_sha)
  rescue StandardError => e
    @logger.error("An unexpected error occurred: #{e}")
    nil
  end

  def create_pull_request(head, base = "main", title = "New Pull Request", body = "")
    url = URI("#{@github_api_url}/pulls")
    data = { title: title, body: body, head: head, base: base }.to_json

    response = make_request(url, method: 'POST', body: data)
    JSON.parse(response.body) if response
  rescue StandardError => e
    @logger.error("An unexpected error occurred: #{e}")
    nil
  end

  def clone
    url = "https://github.com/#{@repo_owner}/#{@repo_name}.git"
    branch = "main"
    probe = File.join("/tmp", @repo_owner, @repo_name, ".git")
    return @directory_dir if File.exist?(probe)

    Git.clone(url, @directory_dir, branch: branch)
    @directory_dir
  rescue StandardError => e
    @logger.error("An unexpected error occurred: #{e}")
    nil
  end

  private

  def make_request(url, method: 'GET', params: nil, body: nil)
    uri = url.is_a?(URI) ? url : URI(url)
    uri.query = URI.encode_www_form(params) if params

    request = case method
              when 'POST'
                Net::HTTP::Post.new(uri)
              when 'PATCH'
                Net::HTTP::Patch.new(uri)
              else
                Net::HTTP::Get.new(uri)
              end
    request['Authorization'] = "token #{@github_token}"
    request['Accept'] = "application/vnd.github.v3+json"
    request['Content-Type'] = 'application/json' if body
    request.body = body if body
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
    response.is_a?(Net::HTTPSuccess) ? response : (handle_error(response); nil)
  end

  def handle_error(response)
    @logger.error("HTTP Request failed: #{response.code} #{response.message}")
  end

  def get_latest_commit_sha(branch_name)
    url = URI("#{@github_api_url}/git/refs/heads/#{branch_name}")
    response = make_request(url)
    return nil unless response

    JSON.parse(response.body)["object"]["sha"]
  end

  def get_base_tree_sha(latest_commit_sha)
    url = URI("#{@github_api_url}/git/commits/#{latest_commit_sha}")
    response = make_request(url)
    return nil unless response

    JSON.parse(response.body)["tree"]["sha"]
  end

  def create_blob(file_path)
    file_name = file_path.sub(/^#{Regexp.escape(@directory_dir)}\//, '')
    file_content = Base64.encode64(File.read(file_path)).strip
    blob_url = URI("#{@github_api_url}/git/blobs")
    data = { content: file_content, encoding: 'base64' }.to_json

    response = make_request(blob_url, method: 'POST', body: data)
    blob_sha = JSON.parse(response.body)["sha"]
    { path: file_name, mode: '100644', type: 'blob', sha: blob_sha }
  end

  def create_tree(base_tree_sha, tree_items)
    tree_url = URI("#{@github_api_url}/git/trees")
    data = { base_tree: base_tree_sha, tree: tree_items }.to_json

    response = make_request(tree_url, method: 'POST', body: data)
    JSON.parse(response.body)["sha"]
  end

  def create_commit(message, latest_commit_sha, new_tree_sha)
    commit_url = URI("#{@github_api_url}/git/commits")
    data = {
      message: message,
      parents: [latest_commit_sha],
      tree: new_tree_sha
    }.to_json

    response = make_request(commit_url, method: 'POST', body: data)
    JSON.parse(response.body)["sha"]
  end

  def update_branch_ref(branch_name, new_commit_sha)
    update_ref_url = URI("#{@github_api_url}/git/refs/heads/#{branch_name}")
    data = { sha: new_commit_sha, force: false }.to_json

    response = make_request(update_ref_url, method: 'PATCH', body: data)
    JSON.parse(response.body)
  end
end
