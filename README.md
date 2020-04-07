# pr_hawk

PR Hawk is a web application that gives users visibility into how well GitHub repository owners are managing their Pull Requests.

## Tech Stack

* This web application uses Sinatra, a DSL for creating light weight web applications in ruby.
* The application is deployed as a Rack based app that uses WEBrick web server.
* Bundler to manage dependencies for the project.
* Faraday HTTP client to interact with GitHub REST APIs.
* Embedded ruby for the (very bare bones) UX.
* RSpec for unit tests.

## How to use it

* Install the dependencies:

```
bundle install
```

* Check lint errors:

```
rubocop
```

* Run tests:

```
bundle exec rspec
```

* To stand up the web application 

```
bundle exec rackup
```

You should now be able to hit the endpoint `http://localhost:9292/user/{userId}`

## GitHub REST API

This application hits two GitHub API endpoints

* https://developer.github.com/v3/repos/#list-repositories-for-the-authenticated-user to retrieve repositories for
the given user id.
* https://developer.github.com/v3/search/#search-issues-and-pull-requests to get open pull requests info for all
repositories for the given user id.

## GitHub Rate Limiting Rules

* Authenticated requests are rate limited at 5000 per hour. 
* Search APIs are rate limited at 30 per minute. 
