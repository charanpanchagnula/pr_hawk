# frozen_string_literal: true

require 'sinatra'
require './lib/pr_hawk/constants'
require './lib/pr_hawk/http_client'
require './lib/pr_hawk/repository_resource'
require './lib/pr_hawk/repository'

before do
  halt 401 unless env[PRHawk::AUTH_HEADER_KEY]
end

get '/user/:userId' do
  repo_resource = PRHawk::RepositoryResource.new

  repos = repo_resource.list_repos_for_user(params[:userId], env[PRHawk::AUTH_HEADER_KEY])
  count_by_repo = repo_resource.get_open_pr_count(params[:userId], env[PRHawk::AUTH_HEADER_KEY])

  @repositories =
    repos.map do |repo|
      if count_by_repo[repo['name']]
        PRHawk::Repository.new(repo['name'], repo['url'], count_by_repo[repo['name']])
      else
        PRHawk::Repository.new(repo['name'], repo['url'], 0)
      end
    end

  @repositories.sort_by! { |item| -item.open_pr_count }
  erb :index
rescue PRHawk::GitHubOperationError => e
  return e.status, e.message
end
