require 'csv'
require 'optparse'

if ARGV.length != 3
  abort "usage: get.rb packages.txt advisory.csv output.csv"
end

#Print beginning time
time1 = Time.new
puts "Current Time : " + time1.inspect

packages   = File.open(ARGV[0],"r") 
input_csv  = File.open(ARGV[1],"r")
output1_csv = File.open(ARGV[2],"w+")

# Search advisory for matching criteria and output the patch.
CSV.foreach(input_csv) do |row|
  #match package
  @temp = row[3].split('.')[0]
  if packages.include? @temp
    #match major version
    @temp1 = row[1].split('.')[0]
    if row[1] == '6' or row[1] == '6.0'
      if row[6] == 'patched'
        output1_csv.write(row[0] + ", " + row[1] + ", " + @temp + ", " + row[5] + ", " + row[7] + "\n")
      else
        output2_csv.write(row.to_csv)
      end
    end
  end
end

input_csv.close()
output1_csv.close()
output2_csv.close()

#Print ending time
time1 = Time.new
puts "Current Time : " + time1.inspect
