require 'csv'
require 'optparse'

if ARGV.length != 3
  abort "usage: hi.rb input.csv output.csv output2.csv"
end

#Print beginning time
time1 = Time.new
puts "Current Time : " + time1.inspect

input_csv  = File.open(ARGV[0],"r")
output1_csv = File.open(ARGV[1],"w+")
output2_csv = File.open(ARGV[2],"w+")

#packages = "grep iptables iputils libyaml lua libX11 nano readline rpm yum"
cve = "CVE-2014-4877"

#Search our current CSV for matching criteria and output the patch.
CSV.foreach(input_csv) do |row|       
    #match CVE
    puts cve
    if row[5] == cve
          output1_csv.write(row.to_csv)   
    end
end

input_csv.close()
output1_csv.close()
output2_csv.close()

#Print ending time
time1 = Time.new
puts "Current Time : " + time1.inspect
