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

Currently, `redis` is required to do inter-process communication.
We will remove this requirement until the release, and replace with simple files.

## Usage

Installing this gem add `qspec` command.

### Run spec in 8 cores

```sh
bundle exec qspec --parallel 8 spec
```

### Start 8 spork instances, then run on them

```sh
bundle exec qspec --parallel 8 --spork
bundle exec qspec --drb spec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
