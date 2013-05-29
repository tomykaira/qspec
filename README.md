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
HEAD version is highly recommended.  Old `spork` does not detect Qspec in cases.

```ruby
  gem 'spork', github: 'sporkrb/spork'
```

By default, qspec uses file based inter-process communication.
This is poor implementation and becomes a burden.

We recommend to use `redis`.  Setting up redis-server with default port, and add `redis` gem to your Gemfile is enough.
If `require 'redis'` succeed, it uses automatically redis for IPC.

## Usage

Installing this gem adds `qspec` command.

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
