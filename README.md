# Befunger

Befunge (without the 'r' at the end!) is a two-dimensional esoteric programming language invented in 1993 by Chris Pressey with the goal of being as difficult to compile as possible. (Source: [esolangs.org](https://esolangs.org/wiki/Befunge))

Befunger is an interpreter for Befunge written in Ruby. I wrote this as an answer to [this Kata on codewars](https://www.codewars.com/kata/befunge-interpreter).

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'befunger'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install befunger

## Usage

```
require 'befunger'

Befunge.run(code)
```

## Specification

This is the [original problem statement](https://www.codewars.com/kata/befunge-interpreter) I wrote this for:

Your task is to write a method which will interpret Befunge-93 code! Befunge-93 is a language in which the code is presented not as a series of instructions, but as instructions scattered on a 2D plane; your pointer starts at the top-left corner and defaults to moving right through the code. Note that the instruction pointer wraps around the screen! There is a singular stack which we will assume is unbounded and only contain integers. While Befunge-93 code is supposed to be restricted to 80x25, you need not be concerned with code size. Befunge-93 supports the following instructions

- `0-9` Push this number onto the stack.
- `+` Addition: Pop a and b, then push a+b.
- `-` Subtraction: Pop a and b, then push b-a.
- `*` Multiplication: Pop a and b, then push a*b.
- `/` Integer division: Pop a and b, then push b/a, rounded down. If a is zero, push zero.
- `%` Modulo: Pop a and b, then push the b%a. If a is zero, push zero.
- `!` Logical NOT: Pop a value. If the value is zero, push 1; otherwise, push zero.
- `` ` `` Greater than: Pop a and b, then push 1 if b>a, otherwise push zero.
- `>` Start moving right.
- `<` Start moving left.
- `^` Start moving up.
- `v` Start moving down.
- `?` Start moving in a random cardinal direction.
- `_` Pop a value; move right if value = 0, left otherwise.
- `|` Pop a value; move down if value = 0, up otherwise.
- `"` Start string mode: push each character's ASCII value all the way up to the next ".
- `:` Duplicate value on top of the stack. If there is nothing on top of the stack, push a 0.
- `\` Swap two values on top of the stack. If there is only one value, pretend there is an extra 0 on bottom of the stack.
- `$` Pop value from the stack and discard it.
- `.` Pop value and output as an integer.
- `,` Pop value and output the ASCII character represented by the integer code that is stored in the value.
- `#` Trampoline: Skip next cell.
- `p` A "put" call (a way to store a value for later use). Pop y, x and v, then change the character at the position (x,y) in the program to the character with ASCII value v.
- `g` A "get" call (a way to retrieve data in storage). Pop y and x, then push ASCII value of the character at that position in the program.
- `@` End program.
- ` ` (i.e. a space) No-op. Does nothing.

Here's an example:

```
>987v>.v
v456<  :
>321 ^ _@
```

will create the output `123456789`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rohitpaulk/befunge-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

