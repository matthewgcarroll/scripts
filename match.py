from fuzzywuzzy import fuzz
# Attempt to fuzzy match names between two spreadsheets, creating a third that is a xref between the two
import xlrd
import csv

#Open/create the output CSV file
myfile = open('ACH_MATCH.csv','wb')
wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)

# Stick the first set of names in a list
dealers = []
wb = xlrd.open_workbook('DEALERS.xls')
ws = wb.sheet_by_index(0)
num_dlr = ws.nrows - 1
curr_row = -1
while curr_row < num_dlr:
    curr_row += 1
    dealers.append(ws.row_values(curr_row))

# Now loop thru the other information and try to match
wb = xlrd.open_workbook('ACH.xls')
ws = wb.sheet_by_index(0)
num_ach = ws.nrows - 1
curr_row = -1
while curr_row < num_ach:
    curr_row += 1
    row = ws.row_values(curr_row)
    if curr_row > 0:
        ach_name = row[0]
        # Yipes, now loop thru the dealers, looking for the best match
        # If you have a lot of rows, this is going to take a while...
        best_dlr_num = ""
        best_dlr_name = ""
        best_dlr_match = 0
        for dlr_rec in dealers:
            dlr_num = dlr_rec[0]
            dlr_name = dlr_rec[1]
            match = fuzz.token_sort_ratio(ach_name, dlr_name)
            if match > best_dlr_match:
                #print "new match:",ach_name,dlr_name,match
                best_dlr_match = match
                best_dlr_num = dlr_num
                best_dlr_name = dlr_name
        print curr_row, num_ach, ach_name, '|', best_dlr_name, best_dlr_match
        row.append(best_dlr_num)
        row.append(best_dlr_name)
        row.append(best_dlr_match)
    else:
        row.append('DEALER_NUM')
        row.append('DEALER_NAME')
        row.append('MATCH_PCT')
    wr.writerow(row)
