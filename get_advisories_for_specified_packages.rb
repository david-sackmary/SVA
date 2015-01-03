require 'csv'
require 'optparse'

abort 'usage: get.rb packages.txt advisory.csv output.csv' if ARGV.length != 3

# Print beginning time
time1 = Time.new
puts 'Current Time : ' + time1.inspect

packages   = File.open(ARGV[0], 'r')
input_csv  = File.open(ARGV[1], 'r')
output1_csv = File.open(ARGV[2], 'w+')

# Search advisory for matching criteria and output the patch.
CSV.foreach(input_csv) do |row|
  # match package
  package = VersionHelper.major(row[3])
  if packages.include? package
    if row[1] == '6' || row[1] == '6.0'
      if row[6] == 'patched'
        output1_csv.write(row[0] + ', ' + row[1] + ', ' + package + ', ' +
                          row[5] + ', ' + row[7] + "\n")
      end
    end
  end
end

input_csv.close
output1_csv.close

# Print ending time
time1 = Time.new
puts 'Current Time : ' + time1.inspect
