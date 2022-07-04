require_relative "test_helper"

class MatrixTest < Minitest::Test
  def test_row_index_out_of_bounds
    a = OSQP::Matrix.new(2, 1)

    error = assert_raises(IndexError) do
      a[-1, 0] = 1
    end
    assert_equal "row index out of bounds", error.message

    2.times do |i|
      a[i, 0] = 1
    end

    error = assert_raises(IndexError) do
      a[2, 0] = 1
    end
    assert_equal "row index out of bounds", error.message
  end

  def test_column_index_out_of_bounds
    a = OSQP::Matrix.new(1, 2)

    error = assert_raises(IndexError) do
      a[0, -1] = 1
    end
    assert_equal "column index out of bounds", error.message

    2.times do |i|
      a[0, i] = 1
    end

    error = assert_raises(IndexError) do
      a[0, 2] = 1
    end
    assert_equal "column index out of bounds", error.message
  end

  def test_set_zero
    a = OSQP::Matrix.new(1, 2)
    a[0, 0] = 0
  end
end
