# Qspec

Qspec makes rspec test fast.  Q is for **queue** and **quick**.

## Installation

Add this line to your application's Gemfile:

    gem 'qspec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qspec

## Additional Installation

You can use `spork` to cut the overhead of Qspec startup.
**Use 1.0**. Old `spork` does not detect Qspec.

```ruby
  gem 'spork', '~> 1.0rc'
```

If you are on rails, remember to add `spork-rails` too.

By default, qspec uses file based inter-process communication.
This is poorly implemented and becomes a burden.

We recommend to use `redis`.

- Setting up redis-server with default port
- Add `redis` gem to your Gemfile
- Specify `redis` for IPC method in `.qspec.yml`

## Usage

Installing this gem adds `qspec` and `qspec-helper` commands.

### Setup

```sh
$ bundle exec qspec-helper init
# edit .qspec.yml
```

### Run spec

```sh
bundle exec qspec spec/
```

### Run with spork

```sh
bundle exec qspec-helper spork
bundle exec qspec spec/
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
