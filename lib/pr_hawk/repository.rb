# frozen_string_literal: true

module PRHawk
  # Class representing a GitHub repository.
  class Repository
    # Returns a String representing the name of GitHub repository.
    attr_reader :repo_name
    # Returns a String representing the url of GitHub repository.
    attr_reader :repo_url
    # Returns an Integer, representing the number of open pull requests.
    attr_reader :open_pr_count

    # Constructor for Repository.
    #
    # repo_name - Name of the GitHub repository.
    # repo_url - Url for the GitHub repository.
    # open_pr_count - Integer value representing the number of open pull requests.
    #
    # Raise ArgumentError if the parameter conditions are not met.
    def initialize(repo_name, repo_url, open_pr_count)
      raise ArgumentError, 'repo_name is nil' unless repo_name
      raise ArgumentError, 'repo_url is nil' unless repo_url
      raise ArgumentError, 'open_pr_count has an invalid value' unless open_pr_count >= 0

      @repo_name = repo_name
      @repo_url = repo_url
      @open_pr_count = open_pr_count
    end
  end
end
