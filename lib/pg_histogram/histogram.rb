module PgHistogram
  class Histogram
    attr_reader :query, :column, :bucket_size

    BUCKET_COL = 'bucket'
    FREQUENCY_COL = 'frequency'
    ROUND_METHODS_BY_DIRECTION = {
      nil => :round,
      down:  :floor,
      up:    :ceil
    }

    # column_name name must be safe for SQL injection
    def initialize(query, column_name, options = 1.0)
      @query = query
      @column = column_name.to_s
      if options.is_a? Hash
        if options[:buckets]
          @min = options[:min] || 0
          @max = options[:max]
          @buckets = options[:buckets]
          @bucket_size = calculate_bucket_size
        else
          @min = options[:min]
          @max = options[:max]
          @bucket_size = options[:bucket_size].to_f || 1.0
        end
      else
        @bucket_size = options.to_f
      end
    end

    # returns histogram as hash
    # bucket minimum as a key
    # frequency as value
    def results
      # error handling case
      if max == min
        { min => query.where("#{column} = ?", min).count }
      else
        labeled_histogram
      end
    end

    def min
      @min ||= round_to_increment(query.minimum(column), :down)
    end

    def max
      @max ||= round_to_increment(query.maximum(column), :up)
    end

    private
    
    def calculate_bucket_size
      (max - min).to_f / @buckets
    end

    def num_buckets
      @buckets ||= ((max - min) / bucket_size).to_i
    end

    # returns the bucket label (minimum which can be in bucket) based on bucket #
    def bucket_num_to_label(bucket_num)
      min + bucket_size * (bucket_num - 1)
    end

    # rounds to the nearest bucket_size increment
    # can optionally pass :up or :down to always round in one direction
    def round_to_increment(num, direction = nil)
      return 0 if num.nil?
      round_method = ROUND_METHODS_BY_DIRECTION[direction]
      denominator = 1 / bucket_size
      (num * denominator).send(round_method) / denominator.to_f
    end

    # executes the query and converts bucket numbers to minimum step in bucket
    def labeled_histogram
      query_for_buckets.each_with_object({}) do |row, results|
        results[bucket_num_to_label(row[BUCKET_COL].to_i)] = row[FREQUENCY_COL].to_i \
          unless row[BUCKET_COL].nil?
      end
    end

    def query_for_buckets
      ActiveRecord::Base.connection.execute(
        <<-SQL
          SELECT width_bucket(#{column}, #{min}, #{max}, #{num_buckets}) as #{BUCKET_COL},
            count(*) as #{FREQUENCY_COL}
          FROM (#{subquery.to_sql}) as subq_results
          GROUP BY #{BUCKET_COL}
          ORDER BY #{BUCKET_COL}
        SQL
      )
    end

    # use passed AR query as a subquery to not interfere with group clause
    def subquery
      # override default order
      query.select(column).order('1')
    end
  end
end
