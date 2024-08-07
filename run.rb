require_relative 'codemonkey'
require 'dotenv'

Dotenv.load

llm_api_key = ENV['OPENAI_API_KEY']
github_token = ENV['GITHUB_ACCESS_TOKEN']
repo_owner = ENV['GITHUB_OWNER']
repo_name = ENV['GITHUB_REPO']
user_name = ENV['GITHUB_USERNAME']
base_url = ENV['BASE_URL']

codemonkey = Codemonkey.new(
  base_url: base_url,
  llm_api_key: llm_api_key,
  github_token: github_token,
  repo_owner: repo_owner,
  repo_name: repo_name,
  user_name: user_name
)

# Run Codemonkey tasks
begin
  # Replace with actual issue number
  issue_number = 4
  
  # # List issues -> OK
  # puts "Listing issues assigned to #{user_name}"
  # puts codemonkey.list_issues(assignee: user_name)
  
  # # Get issue details -> OK
  # puts "Getting details of issue number: #{issue_number}"
  # puts codemonkey.get_issue(issue_number: issue_number)
  
  # # Create a new branch -> OK
  #  branch_name = "4-TEST-ISSUE"
  # original_branch = "main"
  # puts "Creating branch: #{branch_name} from #{original_branch}"
  # puts codemonkey.create_branch(branch_name: branch_name, original_branch: original_branch)
  
  # # Change issue status -> OK
  # new_issue_state = "closed"
  # puts "Changing issue number #{issue_number} status to #{new_issue_state}"
  # puts codemonkey.change_issue_status(issue_number: issue_number, state: new_issue_state)
  
  # # Commit changes -> OK
  # commit_message = "another fix"
  # files = ["/tmp/lmoreira-runtime/labs-tests/test.txt"]
  # puts "Committing changes to branch: #{branch_name}"
  # puts codemonkey.commit_changes(message: commit_message, branch_name: branch_name, files: files)
  
  # # Create a pull request -> OK
  # pr_head = branch_name
  # pr_base = "main"
  # pr_title = "New Feature Implementation"
  # pr_body = "Description of the new feature"
  # puts "Creating pull request from #{pr_head} to #{pr_base}"
  # puts codemonkey.create_pull_request(head: pr_head, base: pr_base, title: pr_title, body: pr_body)
  
  # # Clone repository -> OK
  # puts "Cloning repository #{repo_name}"
  # puts codemonkey.clone_repo
  
  # # Running codemonkey -> OK
  # puts "Running codemonkey with issue number: #{issue_number}"
  # puts codemonkey.run_codemonkey(issue_number: issue_number)

  # Replace with actual issue summary -> OK
  # issue_summary = """
  # This project consists on the development of a Rest api to manage/views: Authors, Books and Categories.

  # Requirements

  # User needs to be able to manage Authors, Books, and Categories in the app.
  # Each Author can have many Books that he/her has written and each book can be included in multiple categories.
  # The User should be able to view lists of Authors and Books.
  # The Books should be able to be filtered by Author and by Category.
  # Optional: The App should also include a page to view some basic statistics, like the number of Books per Author, or the number of Books per Category.
  # Optional: To complicate the models. A book can have many instances and users can request an instance to take home with a
  # requested date.

  # Acceptance Criteria

  # Design the model entity relation for this project:
  # use Mermaid, this is supported out of the box by Github's Markdown
  # Design the API endpoints, including:
  # path
  # request
  # response
  # Once the design/planning part has been taken care of and agreed upon, please create tickets/issues for each of the tasks. Having those created, their commits should respect the nomenclature used in the conventional commits:

  # if it's a task: task/<number_of_the_ticket>/small-description;
  # if it's a bug: bugfix/<number_of_the_ticket>/small-description;
  # if it's a release: chore/<number_of_the_ticket>/small-description."""

  # issue_summary = """Develop a \"Hello World\" in python."""
  # puts "Running llm_with_context with issue summary: #{issue_summary}"
  # puts codemonkey.llm_with_context(issue_summary: issue_summary)
  
rescue => e
  puts "An error occurred: #{e.message}"
end
