require_relative 'config'
require_relative 'github'

# require_relative 'labs/github_requests'
# require_relative 'labs/config'
# require_relative 'labs/nlp_interface'
# require_relative 'labs/response_parser'
# require_relative 'litellm_service/request_litellm'
# require_relative 'rag/rag'
# require_relative 'vector/vectorize_to_db'
# require_relative 'vector/queries'

class IssueProcessor
  def initialize
    @gh_requests = nil
    @litellm_requests = nil
  end

  def setup
    @gh_requests = GithubRequests.new(
      github_token: GITHUB_ACCESS_TOKEN,
      repo_owner: GITHUB_OWNER,
      repo_name: GITHUB_REPO
    )

    #@litellm_requests = RequestLiteLLM.new(LITELLM_API_KEY)
  end

  def get_issue(issue_number)
    @gh_requests.get_issue(issue_number)
  end

  def create_branch(issue_number, issue_title)
    branch_name = "#{issue_number}-#{issue_title}".gsub(" ", "-")
    create_result = @gh_requests.create_branch(branch_name: branch_name)
    [create_result, branch_name]
  end

  def apply_nlp_to_issue(issue_text)
    nlp = NLPInterface.new(issue_text)
    nlp.run
  end

  def change_issue_to_in_progress
    # Implement this method if needed
  end

  def load_context(nlp_summary)
    # destination = "/tmp/#{GITHUB_OWNER}/#{GITHUB_REPO}"
    # vectorize_to_db("https://github.com/runtimerevolution/labs", nil, destination)
    # find_similar_embeddings(nlp_summary), destination
    be
  end

  def call_llm_with_context(context, nlp_summary)
    prepared_context = context.map do |file|
      {
        "role" => "system",
        "content" => "File: #{file[1]} Content: #{file[2]}"
      }
    end

    prepared_context << {
      "role" => "user",
      "content" => nlp_summary
    }

    @litellm_requests.completion_without_proxy(
      prepared_context,
      model: "openai/gpt-3.5-turbo"
    )
  end

  def call_agent_to_apply_code_changes(llm_response)
    response_string = llm_response[1]['choices'][0]['message']['content']
    actions = parse_llm_output(response_string)
    files = []

    actions.each do |action|
      case action.action_type
      when "create"
        files << create_file(action.path, action.content)
      when "modify"
        files << modify_file(action.path, action.content)
      else
        puts "Unknown action '#{action.action_type}' in step #{action.step_number}"
      end
    end

    files
  end

  def commit_changes(branch_name, file_list)
    @gh_requests.commit_changes(message: "fix", branch_name: branch_name, files: file_list)
  end

  def create_pull_request(branch_name)
    @gh_requests.create_pull_request(branch_name)
  end

  def change_issue_to_in_review
    # Implement this method if needed
  end

  def run
    issue_number = 1

    setup
    issue = get_issue(issue_number)
    create_result, branch_name = create_branch(issue_number, issue["title"])

    # # nlped_text = apply_nlp_to_issue(issue["body"])
    # # change_issue_to_in_progress()
    # # nlp_summary = "..."
    # # prompt = <<~PROMPT
    # #   You're a diligent software engineer AI. You can't see, draw, or interact with a 
    # #   browser, but you can read and write files, and you can think.
    # #   You've been given the following task: #{issue['body']}.Your answer will be in yaml format.
    # #   Please provide a list of actions to perform in order to complete it, considering the current project.
    # #   Any imports will be at the beginning of the file.
    # #   Add tests for the new functionalities, considering any existing test files.
    # #   Each action should contain two fields:
    # #   action, which is either 'create' to add a new file or 'modify' to edit an existing one;
    # #   args, which is a map of key-value pairs, specifying the arguments for that action:
    # #   path - the absolute path of the file to create/modify and content - the content to write to the file.
    # #   If the file is to be modified, on the contents send the finished version of the entire file.
    # #   Please don't add any text formatting to the answer, making it as clean as possible.
    # # PROMPT

    # context, repo_dir = load_context(issue["body"])
    # puts "Context: #{context}"
    # puts "Repo Dir: #{repo_dir}"

    # # llm_response = call_llm_with_context(context, prompt)
    # # new_file_path = call_agent_to_apply_code_changes(llm_response)
    
    new_file_path = ["sandbox/test.txt"]
    commit_result = commit_changes(branch_name, new_file_path)
    pr_result = create_pull_request(branch_name)

    # # change_issue_to_in_review()
  end
end

# To run the process
processor = IssueProcessor.new
processor.run
