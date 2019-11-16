# OSQP

The [OSQP](https://osqp.org/) (Operator Splitting Quadratic Program) solver for Ruby

[![Build Status](https://travis-ci.org/ankane/osqp.svg?branch=master)](https://travis-ci.org/ankane/osqp) [![Build status](https://ci.appveyor.com/api/projects/status/o93q4b56anxmnvwn/branch/master?svg=true)](https://ci.appveyor.com/project/ankane/osqp/branch/master)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'osqp'
```

## Getting Started

Prep the problem - here’s how it should be [setup](https://osqp.org/docs/examples/setup-and-solve.html)

```ruby
p = [[4, 1], [0, 2]]
q = [1, 1]
a = [[1, 1], [1, 0], [0, 1]]
l = [1, 0, 0]
u = [1, 0.7, 0.7]
```

And solve it

```ruby
solver = OSQP::Solver.new
solver.solve(p, q, a, l, u, alpha: 1.0)
```

All of [these settings](https://osqp.org/docs/interfaces/solver_settings.html#solver-settings) are supported.

Warm start

```ruby
solver.warm_start(x, y)
```

## Data

Arrays and matrices can be Ruby arrays

```ruby
[[1, 2, 3], [4, 5, 6]]
```

Or a Numo NArrays

```ruby
Numo::DFloat.new(3, 2).seq
```

## Resources

- [OSQP: An Operator Splitting Solver for Quadratic Programs](https://arxiv.org/pdf/1711.08013.pdf)
- [Benchmarks](https://github.com/oxfordcontrol/osqp_benchmarks)
- [Status values and errors](https://osqp.org/docs/interfaces/status_values.html)

## Credits

This library is modeled after the OSQP [Python API](https://osqp.org/docs/interfaces/python.html).

## History

View the [changelog](https://github.com/ankane/osqp/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/osqp/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/osqp/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development and testing:

```sh
git clone https://github.com/ankane/osqp.git
cd osqp
bundle install
bundle exec rake test
```
