# frozen_string_literal: true

require './lib/pr_hawk/repository_resource'
require './spec/spec_helper'

RSpec.describe PRHawk::RepositoryResource do
  let(:response) { instance_double(Faraday::Response) }

  describe '#list_repos_for_user' do
    it 'throws an ArgumentError if user id is nil' do
      expect { described_class.new.list_repos_for_user(nil, nil) }.to raise_error do |error|
        expect(error.message).to eq('user_id is nil')
      end
    end

    it 'throws an ArgumentError if auth header is nil' do
      expect { described_class.new.list_repos_for_user('test', nil) }.to raise_error do |error|
        expect(error.message).to eq('auth_header is nil')
      end
    end

    it 'returns 404 when the user id does not exist' do
      allow(response).to receive(:status).and_return(404)
      allow(PRHawk::HttpClient).to receive(:list).with(anything, anything).and_return(response)

      expect { described_class.new.list_repos_for_user('test', 'test') }.to raise_error do |error|
        expect(error.message).to eq('Unable to get repos for user test. Code: 404')
      end
    end

    it 'returns the correct size of repos for a given user' do
      allow(response).to receive(:body).and_return(File.read('./spec/pr_hawk/repos_list_response_single_page.json'))
      allow(response).to receive(:status).and_return(200)

      headers = { link: nil }
      allow(response).to receive(:headers).and_return(headers)

      allow(PRHawk::HttpClient).to receive(:list).with(anything, anything).and_return(response)

      repos = described_class.new.list_repos_for_user(
        'charanpanchagnula',
        'Basic c25raXJrbGFuZGludGVydmlldzplOTYwNzZlZmQyZWE5YzNlMjBjN2QxYzI0N2I5YTQ4YjkzMzE4MzU1'
      )

      expect(repos.length).to eq(9)
      expect(repos)
    end
  end

  describe '#get_open_pr_count' do
    it 'throws an ArgumentError if user id is nil' do
      expect { described_class.new.get_open_pr_count(nil, nil) }.to raise_error do |error|
        expect(error.message).to eq('user_id is nil')
      end
    end

    it 'throws an ArgumentError if auth header is nil' do
      expect { described_class.new.get_open_pr_count('test', nil) }.to raise_error do |error|
        expect(error.message).to eq('auth_header is nil')
      end
    end

    it 'returns 404 when the user id does not exist' do
      allow(response).to receive(:status).and_return(404)
      allow(PRHawk::HttpClient).to receive(:list).with(anything, anything).and_return(response)

      expect { described_class.new.get_open_pr_count('test', 'test') }.to raise_error do |error|
        expect(error.message).to eq('Unable to get open PRs count for user test. Code: 404')
      end
    end

    it 'returns the correct hash for a given user' do
      allow(response).to receive(:body).and_return(File.read('./spec/pr_hawk/open_pr_count_response_single_page.json'))
      allow(response).to receive(:status).and_return(200)

      headers = { link: nil }
      allow(response).to receive(:headers).and_return(headers)

      allow(PRHawk::HttpClient).to receive(:list).with(anything, anything).and_return(response)

      repos_hash = described_class.new.get_open_pr_count(
        'charanpanchagnula',
        'Basic c25raXJrbGFuZGludGVydmlldzplOTYwNzZlZmQyZWE5YzNlMjBjN2QxYzI0N2I5YTQ4YjkzMzE4MzU1'
      )

      expect(repos_hash['hello-github-actions']).to eq(1)
    end
  end
end
