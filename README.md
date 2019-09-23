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

## Default Usage

first, you need create migration whit this command.

```bash
rake http_store_engine:install:migrations # create table(default)
rails generator http_store:initializer    # create global settings
```


### HttpStore::Client
you can extend the `HttpStore::Client` to create your rest-client request.

```ruby
class BaseClient < HttpStore::Client  
  # support `http_method url data_type headers query_params data` keys
  # url not include the query, use query_params to set query
  def set_request
    {
      data_type:   'json', # support json/form default form 
      data:        {},     # http body data
      headers:     {},     # request headers
      http_method: 'post', # support get/post default post
      url:         'url'
    }
  end              
                                 
  # generate you request digest meta data,
  # default keys is `http_method url data_type data other_params requestable_id requestable_type`  
  def request_digest_hash  
    super.merge(test: 'your value')  
  end
                          
  # request checker, default is true, if return falsely the request not send 
  def request_valid?
    true 
  end  

  # response valid, check response, if return true, next same request will use cache 
  def response_valid?
    status_code == 200 
  end
           
  def build_response_data
    if response_valid
      response.data
    else
      response.error
    end
  end
end
```

### HttpStore::HttpLog

Default use activerecord, you can to rewrite it by setting

### Configuration

- store_enable: default is true
- store_class: default is `HttpStore::HttpLog`

### File storable

When request/response having a file(size limit 30_000), it will use `storable(data)` to format to a hash, `{digest: '', origin: data[0..1000]'}` 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/http_store.
