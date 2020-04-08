# frozen_string_literal: true

require './lib/pr_hawk/repository'
require './spec/spec_helper'

RSpec.describe PRHawk::Repository do
  describe '#initialize' do
    it 'throws an ArgumentError if repo name is nil' do
      expect { described_class.new(nil, nil, 0) }.to raise_error do |error|
        expect(error.message).to eq('repo_name is nil')
      end
    end

    it 'throws an ArgumentError if repo url is nil' do
      expect { described_class.new('a', nil, 0) }.to raise_error do |error|
        expect(error.message).to eq('repo_url is nil')
      end
    end

    it 'throws an ArgumentError if open pr count is invalid' do
      expect { described_class.new('a', 'b', -1) }.to raise_error do |error|
        expect(error.message).to eq('open_pr_count has an invalid value')
      end
    end

    it 'does not throw an error when parameters are valid' do
      expect { described_class.new('a', 'b', 1) }.to_not raise_error
    end
  end
end
