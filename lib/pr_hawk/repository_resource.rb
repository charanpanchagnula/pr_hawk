# frozen_string_literal: true

require 'json'
require './lib/pr_hawk/http_client'
require './lib/pr_hawk/errors'
require './lib/pr_hawk/constants'

module PRHawk
  # Internal: This class maintains a tight coupling to the GitHub REST APIs to
  # retrieve information about repositories.
  class RepositoryResource
    # Internal: List repositories for a given user id.
    #
    # user_id - user id for which the repositories are retrieved.
    # auth_header - authorization header to be applied for the GitHub API call.
    #
    # Raise ArgumentError if the parameter conditions are not met.
    def list_repos_for_user(user_id, auth_header)
      raise ArgumentError, 'user_id is nil' unless user_id
      raise ArgumentError, 'auth_header is nil' unless auth_header

      response = HttpClient.list("users/#{user_id}/repos?#{OFFSET_PARAM}=1&#{LIMIT_PARAM}=#{LIMIT}", auth_header)

      repos = parse_list_repos_response(user_id, response)
      return repos if response.headers[:link].nil?

      links = parse_link_header(response)
      query_params = Rack::Utils.parse_query URI(links[:last]).query
      total_results = query_params['page'].to_i

      2.upto(total_results) do |offset|
        list_response = HttpClient.list(
          "users/#{user_id}/repos?#{OFFSET_PARAM}=#{offset}&#{LIMIT_PARAM}=#{LIMIT}",
          auth_header
        )
        repos.concat(parse_list_repos_response(user_id, list_response))
      end

      repos
    end

    # Internal: Get open pull request count for all repositories
    # for a given user.
    #
    # user_id - user id to which the repo is tied to.
    # repo_id - repository for which open pr count is to be retrieved.
    # auth_header - authorization header to be applied for the GitHub API call.
    #
    # Returns a hash of non-zero open pr count keyed by name of the repository.
    #
    # Raise ArgumentError if the parameter conditions are not met.
    def get_open_pr_count(user_id, auth_header)
      raise ArgumentError, 'user_id is nil' unless user_id
      raise ArgumentError, 'auth_header is nil' unless auth_header

      response = HttpClient.list(
        "#{SEARCH_OPEN_PR_USER}#{user_id}&#{OFFSET_PARAM}=1&#{LIMIT_PARAM}=#{LIMIT}",
        auth_header
      )

      count_by_repo = parse_open_pr_count_response(user_id, response)
      return count_by_repo if response.headers[:link].nil?

      links = parse_link_header(response)
      query_params = Rack::Utils.parse_query URI(links[:last]).query
      total_results = query_params['page'].to_i

      2.upto(total_results) do |offset|
        response = HttpClient.list(
          "#{SEARCH_OPEN_PR_USER}#{user_id}&#{OFFSET_PARAM}=#{offset}&#{LIMIT_PARAM}=#{LIMIT}",
          auth_header
        )

        count_by_repo.merge(parse_open_pr_count_response(user_id, response)) { |_, val1, val2| val1 + val2 }
      end

      count_by_repo
    end

    private

    # Internal: Parses the response for the API call that retrieves
    # the list of repositories for the given user id.
    #
    # user_id - user id to which the repo is tied to.
    # response - Response for the paginated list endpoint.
    #
    # Returns the list of repositories from the response body.
    def parse_list_repos_response(user_id, response)
      repos = []

      if response.status != 200 && response.status < 500
        raise GitHubOperationError.new(
          "Unable to get repos for user #{user_id}. Code: #{response.status}",
          response.status
        )
      end

      result = JSON.parse(response.body)
      result.each { |repo| repos.push({ 'name' => repo['name'], 'url' => repo['html_url'] }) }
      repos
    end

    # Internal: Parses the response for the API call that retrieves
    # the count of all open prs for all repos for a given user id.
    #
    # user_id - user id to which the repos are tied to.
    # response - Response for the paginated list endpoint.
    #
    # Returns a hash of open pr count keyed by name of the repository.
    def parse_open_pr_count_response(user_id, response)
      if response.status != 200 && response.status < 500
        raise GitHubOperationError.new(
          "Unable to get open PRs count for user #{user_id}. Code: #{response.status}",
          response.status
        )
      end

      result = JSON.parse(response.body)

      count_by_repo = {}

      result['items'].each do |item|
        repo = item['repository_url'].split('/')[-1]
        if count_by_repo[repo]
          count_by_repo[repo] += 1
        else
          count_by_repo[repo] = 1
        end
      end

      count_by_repo
    end

    # Internal: Parses the link response header for a paginated list endpoint.
    #
    # response - Response for the paginated list endpoint.
    #
    # Returns link header in the response.
    def parse_link_header(response)
      links = {}
      parts = response.headers['link'].split(',')

      # Parse each part into a named link
      parts.each do |part, _|
        section = part.split(';')
        url = section[0][/<(.*)>/, 1]
        name = section[1][/rel="(.*)"/, 1].to_sym
        links[name] = url
      end
      links
    end
  end
end
