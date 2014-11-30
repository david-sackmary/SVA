# Autoupdate.rb Searches our current CSV for 'noadv' and 'truepos' rows which can be
# updated to 'patched' based on data from the new pull.
#
# Inputs all rows from Oval which have been classified as 'patched'.
# Inputs our current CSV.
# Output our current CSV, identical except for rows matching the criteria.
#
# The criteria for a match is rows in out current CSV must have 'noadv' or 'truepos' status,
# and the same major version, architecture, package and CVE as the row from the
# most recent pull.
#
# The only fields we update in case of a match are:
# 'status','minfixver', and notes.
#
# Input:    CSV from git.
# Input:    CSV file of patched rows.
# Output:   CSV from git with patch updates.
# Output:   Changelog.
#
# TESTING (files are in git):
#
# To perform these tests, Cut and Paste the command lines below:
#
# Proving it does what it says:
#   ruby autopatch.rb  autopatch_test1.csv test_patches.csv autopatch_test1_out.csv autopatch_test1_changelog.csv
#   diff autopatch_test1.csv autopatch_test1_out.csv  #shows that 5 rows of 'noadv' are now 'patched'
#   cat test1_changelog.csv                           #shows original row followed by modified row
#
# Proving it does not modify anything else:
#   ruby autopatch.rb  autopatch_test2.csv test_patches.csv autopatch_test2_out.csv autopatch_test2_changelog.csv
#   diff autopatch_test2.csv autopatch_test2_out.csv  #shows that input is identical to output
#   cat test2_changelog.csv                           #blank, showing nothing changed
#
# Proving that it does both when the above test cases are intermingled:
#   ruby autopatch.rb  autopatch_test3.csv test_patches.csv autopatch_test3_out.csv autopatch_test3_changelog.csv
#   diff autopatch_test3.csv autopatch_test3_out.csv  #shows that 5 rows of 'noadv' are now 'patched'
#   diff test1_changelog.csv test3_changelog.csv      #diff against 1st changelog, an identical diff proves only the rows expected to change have changed.

require 'csv'
require 'optparse'

if ARGV.length != 4
  abort "usage: autopatch.rb current_CSV_from_git.csv just-patches_from_new_pull.csv updated-CSV_from_git.csv changelog.csv"
end

#Print beginning time
time1 = Time.new
puts "Current Time : " + time1.inspect

input1_csv  = File.open(ARGV[0],"r")
input2_csv  = File.open(ARGV[1],"r")
output1_csv = File.open(ARGV[2],"w+")
output2_csv = File.open(ARGV[3],"w+")

@linespatchedcount = 0

#Search our current CSV for matching criteria and apply the patch.
CSV.foreach(input1_csv) do |row|
  @rowfound = false

  # we only care about rows with a status of 'noadv' or 'truepos'.  (Only these states can occur before a patch comes out).
  if row[6] == 'noadv' or row[6] == 'truepos'

    #For every row in the Redhat Advisory
    CSV.foreach(input2_csv) do |line|

      # So we match only on the major version below.  This ensures thus ensuring all minor versions in our database are updated
      # in response to the advisory update.
      @temp1 = VersionHelper.major(row[1])
      @temp1 = VersionHelper.major(line[1])

      # Match on package.  exclude architecture from comparision by taking only first atom
      @temp3 = row[3].split('.')[0]

      # The lines we update are defined as having a status of 'noadv' or 'truepos', and
      # the same major version, architecture, package and CVE as our new row with a minfix.
      #if @temp1 == @temp2 and row[2] == line[2] and row[3] == line[3] and row[5] == line[5]
      if (@temp1 == @temp2 and (line[3].include? @temp3) and row[5] == line[5])
        @rowfound = true
        @linespatchedcount = @linespatchedcount + 1

        #For QA, write both rows to the changelog.  Every change made is recorded right here!
        output2_csv.write(row.to_csv)     #write out row of this match to the changelog
        output2_csv.write(line.to_csv)    #write out line of this match to the changelog
        output2_csv.write("\n")    #write out line of this match to the changelog

        row[6] = "patched"                #update status
        row[7] = line[7]                  #update minfix
        row[9] = "Autopatch.rb 11/14/14"  #FIX THIS DATE
        output1_csv.write(row.to_csv)     #HERE:  WE UPDATE A LINE OF OUR CSV WITH A PATCH.  THIS IS ALL THIS PROGRAM DOES.
        puts row.to_csv
        break
      end
    end
  end

  if @rowfound == false
    output1_csv.write(row.to_csv)    #HERE:  WE OUTPUT THE ORIGINAL ROW BECUASE THERE WAS NO MATCH.
  end
end

puts "Autopatch.rb:  There were a total of #{@linespatchedcount} rows updated"

input1_csv.close()
input2_csv.close()
output1_csv.close()
output2_csv.close()

#Print ending time
time1 = Time.new
puts "Current Time : " + time1.inspect

### VERIFY RESULTS AFTER PROGRAM HAS COMPLETED:

### Convert belowfrom Python:
#
# Verify that the number of lines of input matches the number of lines of output:
#
#num_lines_in   = sum(1 for line in open(sys.argv[2]))
#num_lines_out  = sum(1 for line in open(sys.argv[3]))
#if (num_lines_in == num_lines_out):
#   print "Autopatch.py PASS: input %d lines, output %d lines" % (num_lines_in, num_lines_out)
#else
#   sys.exit("Autopatch.py FAIL: input %d lines, output %d lines" % (num_lines_in, num_lines_out))
#end
