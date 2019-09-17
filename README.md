# HttpStore

This is a http client, based on rest-client. It provide a activerecord table to save the request.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http_store

## Usage

first, you need create migration whit this command.

```
rake http_store_engine:install:migrations
```

and you can extend the HttpStore::RestRequest to create your rest-client request.

```ruby 
class YourRequest < HttpStore::RestRequest
  def build_request
    @query_params_hash = {   
      ..
    }
    
    self.http_method = 'POST'
    self.url         = 'https://www.example.com'
  end
    
  def response_status_check
    status_code == 200 && response_hash.access_token.present?
  end
    
  def rsp_success_data
    response_hash.access_token
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/http_store.
