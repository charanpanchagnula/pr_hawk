# frozen_string_literal: true

require 'faraday'
require 'yaml'

module PRHawk
  # Internal: Generic Faraday HTTP Client.
  class HttpClient
    # Invokes a HTTP request for a GET paginated endpoint.
    #
    # resource - Represents the resource for which the HTTP call is made.
    # auth_header - Authorization header for the API call.
    #
    # Returns the possibly empty response from the HTTP call.
    #
    # Raise ArgumentError if the parameter conditions are not met.
    def self.list(resource, auth_header)
      raise ArgumentError, 'resource is nil' unless resource
      raise ArgumentError, 'auth_header is nil' unless auth_header

      uri = base_url + resource
      Faraday.new(uri, headers: { 'Content-Type' => 'application/json', 'Authorization' => auth_header }).get
    end

    # Returns the base url for which the http requests are invoked.
    def self.base_url
      # Loads the configuration file that provides the URL against
      # which the HTTP requests are invoked.
      config = YAML.load_file('config.yaml')
      config['baseApiUrl'].to_s
    end
  end
end
