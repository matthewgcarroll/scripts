#!/usr/bin/python
from urllib2 import urlopen
from BeautifulSoup import BeautifulSoup
import csv

def lookup_aba(a):
    # Get the address of a bank, given a valid routing number
    url = 'http://us-routing-numbers.com/search/?routing-number='+a
    soup = BeautifulSoup(urlopen(url).read())
    table = soup.find('table', id='hor-zebra')
    rows = table.findAll('td')
    return [l.text for l in rows]

writer = csv.writer(open("list2.txt", "w"), delimiter='\t')
with open('list.txt','r') as f:
    next(f)
    reader=csv.reader(f,delimiter='\t')
    for list in reader:
        name = list[0]
        aba = list[3]
        print name, aba
        address = lookup_aba(aba)
        writer.writerow(list+address)
