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

### Run spec in 8 cores

```sh
bundle exec qspec --parallel 8 spec
```

### Start 8 spork instances, then run on them

```sh
bundle exec qspec --parallel 8 --spork
bundle exec qspec --drb spec
```

### options

`--parallel count`
: Start given number of worker processes.  Number of the box's cores is recommended.

`--spork`
: Start spork processes.  To stop them, kill this process with `C-c` or `kill`

`--no-gc`
: Disable GC in workers.
  WARNING: If the box has not enough memory, it becomes slower or even freezes.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
