require_relative "test_helper"

class OSQPTest < Minitest::Test
  def test_version
    assert_match(/\A\d+\.\d+\.\d+\z/, OSQP.lib_version)
  end

  def test_example
    p = [[4, 1], [1, 2]]
    q = [1, 1]
    a = [[1, 1], [1, 0], [0, 1]]
    l = [1, 0, 0]
    u = [1, 0.7, 0.7]

    solver = OSQP::Solver.new
    result = solver.solve(p, q, a, l, u, alpha: 1.0, verbose: false)

    assert_equal 50, result[:iter]
    assert_equal "solved", result[:status]
    assert_in_delta 1.88, result[:obj_val]
    assert_elements_in_delta [0.3, 0.7], result[:x]

    solver.warm_start([1, 2], nil)

    error = assert_raises OSQP::Error do
      solver.warm_start([1, 2, 3], nil)
    end
    assert_equal "Expected x to be size 2, got 3", error.message
  end

  def test_matrix
    require "matrix"

    p = Matrix.rows([[4, 1], [1, 2]])
    q = Vector.elements([1, 1])
    a = Matrix.rows([[1, 1], [1, 0], [0, 1]])
    l = Vector.elements([1, 0, 0])
    u = Vector.elements([1, 0.7, 0.7])

    solver = OSQP::Solver.new
    result = solver.solve(p, q, a, l, u, alpha: 1.0, verbose: false)

    assert_equal 50, result[:iter]
    assert_equal "solved", result[:status]
    assert_in_delta 1.88, result[:obj_val]
  end

  def test_numo
    p = Numo::NArray.cast([[4, 1], [1, 2]])
    q = Numo::NArray.cast([1, 1])
    a = Numo::NArray.cast([[1, 1], [1, 0], [0, 1]])
    l = Numo::NArray.cast([1, 0, 0])
    u = Numo::NArray.cast([1, 0.7, 0.7])

    solver = OSQP::Solver.new
    result = solver.solve(p, q, a, l, u, alpha: 1.0, verbose: false)

    assert_equal 50, result[:iter]
    assert_equal "solved", result[:status]
    assert_in_delta 1.88, result[:obj_val]
  end
end
