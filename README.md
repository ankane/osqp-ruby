# OSQP Ruby

The [OSQP](https://osqp.org/) (Operator Splitting Quadratic Program) solver for Ruby

Check out [Opt](https://github.com/ankane/opt) for a high-level interface

[![Build Status](https://github.com/ankane/osqp-ruby/workflows/build/badge.svg?branch=master)](https://github.com/ankane/osqp-ruby/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "osqp"
```

## Getting Started

Prep the problem - here’s how it should be [setup](https://osqp.org/docs/examples/setup-and-solve.html)

```ruby
p = OSQP::Matrix.from_dense([[4, 1], [0, 2]])
q = [1, 1]
a = OSQP::Matrix.from_dense([[1, 1], [1, 0], [0, 1]])
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

Matrices can be a sparse matrix

```ruby
a = OSQP::Matrix.new(3, 2)
a[0, 0] = 1
a[1, 0] = 2
# or
OSQP::Matrix.from_dense([[1, 0], [2, 0], [0, 0]])
```

Arrays can be Ruby arrays

```ruby
[1, 2, 3]
```

Or Numo arrays

```ruby
Numo::NArray.cast([1, 2, 3])
```

## Resources

- [OSQP: An Operator Splitting Solver for Quadratic Programs](https://arxiv.org/pdf/1711.08013.pdf)
- [Benchmarks](https://github.com/oxfordcontrol/osqp_benchmarks)
- [Status values and errors](https://osqp.org/docs/interfaces/status_values.html)

## Credits

This library is modeled after the OSQP [Python API](https://osqp.org/docs/interfaces/python.html).

## History

View the [changelog](https://github.com/ankane/osqp-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/osqp-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/osqp-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/osqp-ruby.git
cd osqp-ruby
bundle install
bundle exec rake vendor:all
bundle exec rake test
```
