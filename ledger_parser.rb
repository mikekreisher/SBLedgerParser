require 'optparse'
require 'json'

#http://www.swagbucks.com/?cmd=sb-acct-ledger&allTime=true

activity_codes = {
  0 => 'Registration',
  1 => 'Searching the Web',
  2 => 'Referral SB from',
  3 => 'Shop',
  4 => 'Trade-In',
  5 => 'Rewards Store Refund',
  6 => 'Rewards Store Purchase',
  7 => 'Swag Code',
  8 => 'Submission',
  9 => 'Other',
  10 => 'Flipswap',
  11 => 'Swagstakes Entry',
  12 => 'Answer',
  13 => 'Discover',
  14 => 'Play',
  15 => 'Bonus SB',
  16 => 'Watch',
  17 => 'Tasks',
  18 => 'Mobile Watch',
  19 => 'Social Games',
  20 => 'Swagbucks Rewards',
  21 => 'Accelerator Bonus',
  22 => 'nCrave',
  23 => 'Swagbucks Visa Card',
  24 => 'Mobile Offers',
  25 => 'Swagbucks Local',
  98 => 'Correction',
  99 => 'Adjustment'
}

options = {}
begin
  opt_parser = OptionParser.new do |opts|
    opts.on('-f n', '--file FILENAME', 'Filename') do |f|
      options[:filename] = f
    end

    opts.on('-s n', '--start-date=n', 'StartDate',
            'Start Date (yyyymmdd)') do |s|
      options[:start_date] = s
      raise ArgumentError unless s =~ /\d{8}/
    end

    opts.on('-e n', '--end-date=n', 'EndDate',
            'End Date (yyyymmdd)') do |e|
      options[:end_date] = e
      raise ArgumentError unless e =~ /\d{8}/
    end

    opts.on('-h', '--help', 'Help',
            'Displays Help') do
      puts opts
      exit
    end
  end

  opt_parser.parse!

  if options[:filename].nil?
    print 'Enter json file: '
    options[:filename] = gets.chomp
  end

  if options[:start_date].nil?
    print 'Enter start date (yyyymmdd): '
    options[:start_date] = gets.chomp
    raise ArgumentError unless options[:start_date] =~ /\d{8}/
  end

  options[:end_date] = options[:start_date] if options[:end_date].nil?
rescue OptionParser::MissingArgument
  print 'Missing an argument\n'
  exit
rescue ArgumentError
  print 'Improper date format. Must be YYYYMMDD'
  exit
end

idx = 0
lifetime = 0
my_data = []

File.open(options[:filename]).each do |line|
  idx = line.index('@')
  lifetime = line[2...idx]
  my_data = eval(line[idx + 3..-1])
end

earnings = []
spendings = []
amount_earned = 0
amount_spent = 0
i = 0
until i >= my_data.length
  entry = ''
  if my_data[i][1].to_i <= options[:end_date].to_i
    entry_date = my_data[i][1].to_s.gsub(/(\d{4})(\d{2})(\d{2})/, '\1-\2-\3')
    entry = "#{entry_date}\t#{activity_codes[my_data[i][0]]}\t#{my_data[i][5]}\t#{my_data[i][3]}"
    if my_data[i][0] == 6
      spendings << entry
      amount_spent += my_data[i][3]
    else
      earnings << entry
      amount_earned += my_data[i][3]
    end

  end
  i += 1
  break if my_data[i][1].to_i < options[:start_date].to_i

end

print "Statistics for #{options[:start_date]} - #{options[:end_date]}:\n"

File.open('earnings.txt', 'w+') { |f| f.puts earnings.reverse }
print "Total Earned: #{amount_earned} SB\n"
print "Printed #{earnings.length} records to earnings.txt\n"

File.open('spendings.txt', 'w+') { |f| f.puts spendings.reverse }
print "Total Spent: #{amount_spent} SB\n"
print "Printed #{spendings.length} records to spendings.txt\n"
