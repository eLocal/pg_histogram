# PostgreSQL Histogram (for ActiveRecord)

This gem allows for you to efficiently create a histogram from large data sets in your Rails applications.

It uses PostgreSQL's [width_bucket](http://www.postgresql.org/docs/9.3/static/functions-math.html) function to handle the majority of the processing in the database, and only requires 3 database queries.



## Installation

Add this line to your application's Gemfile:

    gem 'pg_histogram'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_histogram

## Usage

Create a Histogram object using the following there parameters:

1. ActiveRecord query to use
2. Name of column to count frequency of
3. Bucket size (OPTIONAL - default is 0.5)


    histogram = PgHistogram::Histogram.new(Widget.all, 'price', 0.5)


Call the results method to retrieve a Hash of bucket minimums and frequency counts

    # create sample data
    5.times do { Widget.create(price: 1.2) }
    10.times do { Widget.create(price: 2.9 ) }

    # get the results
    @histogram_data = histogram.results
     => {1.0=>5, 2.5=>10}


The results can be used by your favorite charting libary, such as [Chartkick](https://github.com/ankane/chartkick), to plot the data.

    <%= column_chart @histogram_data %>

## Dependencies

This gem has been tested with Ruby 2.1.3 and ActiveRecord 4.1.6. Please open an issue or PR if you experience issues with other versions.
