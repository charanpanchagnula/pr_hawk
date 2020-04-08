# frozen_string_literal: true

module PRHawk
  # Internal: Custom error class for errors encountered while interacting
  # with GitHub REST APIs.
  class GitHubOperationError < StandardError
    # Internal: Status for the GitHub API call.
    attr_reader :status

    # Internal: Constructor for GitHubOperationError.
    #
    # message - message for the exception.
    # status - status code for the GitHub API call.
    def initialize(message, status)
      super(message)

      @status = status
    end
  end
end
