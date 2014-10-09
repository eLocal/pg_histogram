require_relative 'test_helper'

class HistogramTest < Minitest::Test

  def setup
    Widget.delete_all
    @hist = PgHistogram::Histogram.new(Widget.all, 'price', 0.5)
  end

  def test_with_1_result
    Widget.create!(price: 2.00)
    
    assert_equal 2.0, @hist.min, 'Minimum is the single price'
    assert_equal 2.0, @hist.max, 'Minimum is the single price'
    assert_equal 1, @hist.results[2.0], 'Frequency of 2.0 bucket'
  end

  def test_ignores_nils_with_1_result
    Widget.create!(price: 3.00)
    Widget.create!(price: nil)

    results = @hist.results
    assert_equal 3.0, @hist.min, 'Minimum is the single price'
    assert_equal 3.0, @hist.max, 'Minimum is the single price'
    assert_equal 1, results.count, 'Histogram bucket count'
    assert_equal 1, results[3.0], 'Frequency of 3.0 bucket'
  end

  def test_ignores_nils_with_multiple_results
    Widget.create!(price: 3.00)
    Widget.create!(price: 2.25)
    Widget.create!(price: nil)

    results = @hist.results
    assert_equal 2.0, @hist.min, 'Minimum'
    assert_equal 3.0, @hist.max, 'Maximum'
    assert_equal 2, results.count, 'Histogram bucket count'
    assert_equal 1, results[3.0], 'Frequency of 3.0 bucket'
    assert_equal 1, results[2.0], 'Frequency of 2.0 bucket'
  end

  def test_with_many_results
    # use a different bucket size
    hist = PgHistogram::Histogram.new(Widget.all, 'price', 0.25)

    10.times { Widget.create!(price: 3.0) }
    8.times { Widget.create!(price: 5.76) }
    min_price = Widget.create!(price: 0.98).price
    max_price = Widget.create!(price: 6.0).price
    results = hist.results

    assert_equal 0.75, hist.min, 'Histogram minimum price'
    assert_equal 6.0, hist.max, 'Histogram maximum price'
    assert_equal 21, hist.send(:num_buckets), 'Histogram buckets'
    assert_equal 4, results.size, 'Histogram buckets with results'
    assert_equal 1, results[0.75], 'Frequency of 0.75 bucket'
    assert_equal 10, results[3.0], 'Frequency of 3.0 bucket'
    assert_equal 8, results[5.75], 'Frequency of 5.75 bucket'
    assert_equal 1, results[6.0], 'Frequency of 6.0 bucket'
  end

  def test_rounding_to_bucket_size
    hist = PgHistogram::Histogram.new(nil, nil, 0.25)

    assert_equal 0.5, hist.send(:round_to_increment, 0.478), '0.478 rounded to 0.25 interval'
    assert_equal 1.0, hist.send(:round_to_increment, 1.1), '1.1 rounded to 0.25 interval'
    assert_equal 0.5, hist.send(:round_to_increment, 0.5), '0.5 rounded to 0.25 interval'
    assert_equal 0.25, hist.send(:round_to_increment, 0.478, :down), '0.478 rounded down to 0.25 interval'
    assert_equal 1.0, hist.send(:round_to_increment, 1.1, :down), '1.1 rounded down to 0.25 interval'
    assert_equal 0.5, hist.send(:round_to_increment, 0.5, :down), '0.5 rounded down to 0.25 interval'
    assert_equal 0.5, hist.send(:round_to_increment, 0.478, :up), '0.478 rounded up to 0.25 interval'
    assert_equal 1.25, hist.send(:round_to_increment, 1.1, :up), '1.1 rounded up to 0.25 interval'
    assert_equal 0.5, hist.send(:round_to_increment, 0.5, :up), '0.5 rounded up to 0.25 interval'
  end
end
