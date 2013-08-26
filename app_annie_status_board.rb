#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'date'
require 'optparse'

#####################################################################
# Copy project.yml.sample for each graph you want to build and then
# pass the file name in with -c
#####################################################################

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} -c CONFIG_FILE"
  
  opts.separator ""
  opts.separator "Required options:"
  
  options[:config_file] = nil;
  opts.on("-c", "--config CONFIG_FILE",
  "configuration file to use") do |user|
  	options[:config_file] = user
  end

	opts.on_tail('-h', '--help', 'Display this help') do 
		puts opts
		exit
	end

end

begin
	optparse.parse!
	mandatory = [:config_file]
	missing = mandatory.select{ |param| options[param].nil? }
	if not missing.empty?
		puts "Missing options: #{missing.join(', ')}"
		puts
		puts optparse
		exit
	end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
	puts $!.to_s
	puts optparse
	exit
end

@config = YAML.load_file(options[:config_file])

options = { :basic_auth => { :username => @config['username'] , :password => @config['password'] } }
end_date = Date.today
start_date = (end_date - @config['days_to_show'])

data_sequences = []
min_total = 0
max_total = 0

@config['products'].each do |p|
  sales_data = []
  response = HTTParty.get("https://api.appannie.com/v1/accounts/#{@config['account_id']}/apps/#{p[:app_id]}/sales?break_down=date&start_date=#{start_date.to_s}&end_date=#{end_date.to_s}", options)

  sales = response.parsed_response["sales_list"]
  sales.reverse!

  sales.each do |datapoint|
    date = Date.parse(datapoint["date"])
    date_string = date.strftime(@config['date_format'])

    value = datapoint["revenue"]["app"]["downloads"]

    min_total = value.to_i if value.to_i < min_total || min_total == 0
    max_total = value.to_i if value.to_i > max_total

    sales_data << {
      :title => date_string,
      :value => value
    }
  end

  # Add the product to the data sequences.
  data_sequences << { :title => p[:title], :color => p[:color], :datapoints => sales_data }
end

sales_graph = {
  :graph => {
    :title => @config['graph_title'],
    :type => @config['graph_type'],
    :yAxis => {
      :hide => @config['hide_totals'],
      :minValue => min_total,
      :maxValue => max_total,
      :units => {
        :prefix => "$",
      }
    },
    :datasequences => data_sequences
  }
}

File.open(@config['outputFile'], "w") do |f|
  f.write(sales_graph.to_json)
end
