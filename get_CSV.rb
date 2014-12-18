require 'csv'
require 'optparse'

#input text file of CSV entries
#input 2014-redhat.xml
#output patches

if ARGV.length != 3
  abort "usage: get_CSV.rb input.csv redhat-2014.xml output.csv"
end

#Print beginning time
time1 = Time.new
puts "Current Time : " + time1.inspect

in1_csv  = File.open(ARGV[0],"r")
in2_csv  = File.open(ARGV[1],"r")
out_csv = File.open(ARGV[2],"w+")

#Search our current CSV for matching criteria and output the patch.
CSV.foreach(in1_csv) do |row|
  CSV.foreach(in2_csv) do |line|
    if line[5] == row[0]  
      puts line.to_csv
      out_csv.write(line.to_csv)
    end
  end
end

in1_csv.close()
in2_csv.close()
out_csv.close()

#Print ending time
time1 = Time.new
puts "Current Time : " + time1.inspect
