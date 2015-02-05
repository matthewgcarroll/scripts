from xml.dom import minidom
import urllib, urllib2, re, datetime, bpgsql

url='https://treeno/webservices2/docutronWS2.php?wsdl'
dsn = "host=myserver dbname=mydb user=myuser password=blahblah"
head={"Content-type": "text/xml;charset=UTF-8", "Accept-Encoding": "gzip,deflate"}
login = open('login.txt').read()
createFolder = open('create.txt').read()
createSubFolder = open('createsubfolder.txt').read()
uploadFile = open('upload.txt').read()
search = open('search.txt').read()
searchResult = open('searchresult.txt').read()
sql = open('sql.txt').read()
passkey = ""

def treeno_req(req):
    "Make a SOAP call to treeno, passing req and returning xml"
    #handler = urllib2.HTTPHandler(debuglevel=1)
    #opener = urllib2.build_opener(handler)
    #urllib2.install_opener(opener)
    r = urllib2.Request(url, data=req, headers=head)
    response = urllib2.urlopen(r).read()
    return minidom.parseString(response)

def treeno_login():
    "Login to Treeno as admin, returning session passkey for other calls"
    xml = treeno_req(login)
    msgs = xml.getElementsByTagName('message')
    return msgs[0].firstChild.nodeValue

def treeno_search(searchCust, customerName, searchApp, searchSched):
    "Find an 'entity' in Treeno, that we can add documents to - if there are multiple, pick the first that matches"
    li=[]
    if searchApp != 4002:
        return ""
    req = search%{'passkey':passkey, 'customernum':searchCust, 'appnum':searchApp, 'schedulenum':searchSched}
    xml = treeno_req(req)
    results = xml.getElementsByTagName('resultID')
    resultID = results[0].firstChild.nodeValue
    numResultss = xml.getElementsByTagName('numResults')
    numResults = numResultss[0].firstChild.nodeValue
    if numResults == 0:
        return ""

    # Now get the list of matches, build a list of (docID, customer, app, schedule)
    req = searchResult%{'passkey':passkey, 'resultID':resultID}
    xml = treeno_req(req)

    for nodes in xml.getElementsByTagName('item'):
        for elem in nodes.childNodes:
            if elem.nodeType == 1 and elem.tagName == "docID":
                # The docid node always comes before the field nodes
                docID=elem.firstChild.nodeValue
            if elem.nodeType == 1 and elem.tagName == "cabinetIndices":
                # Parse the XML returned for cabinetIndices and extract customer, app, schedule numbers
                xml2 = minidom.parseString(elem.firstChild.nodeValue)
                cust = app = sched = ""
                for field in xml2.getElementsByTagName("field"):
                    #print field.toxml()
                    if field.getAttribute("index") == "ccan":
                        if field.firstChild is not None:
                            cust = field.firstChild.nodeValue
                    if field.getAttribute("index") == "application_number":
                        if field.firstChild is not None:
                            app = field.firstChild.nodeValue
                    if field.getAttribute("index") == "contract_number":
                        if field.firstChild is not None:
                            sched = field.firstChild.nodeValue
                # If we are searching for a customer, don't want the apps or schedules etc...
                if searchApp == "" and app != "" and app != "(null)":
                    continue
                if searchSched == "" and sched != "" and sched != "(null)":
                    continue
                li.append([docID, cust, app, sched])
    if len(li) == 0:
        # Couldn't find it, so make a new one, and then return that docid
        docID=treeno_create(searchCust, customerName, searchApp, searchSched)
        li = [docID, searchCust, searchApp, searchSched]
    print li[0], len(li)
    # Return the first hit (arbitrarily), there is usually (but not definitely) only one
    return li[0]

def treeno_create(customernum, customername, appnum, schedulenum):
    "Create a new 'entity' in Treeno, that can have folders attached to it"
    #if appnum == "":
    #    appnum = "(null)"
    #if schedulenum == "":
    #    schedulenum = "(null)"
    req = createFolder%{'passkey':passkey, 'customernum':customernum, 'appnum':appnum, 'schedulenum':schedulenum,
                        'customername':customername, 'businessline':'Kodiak'}
    xml = treeno_req(req)
    returns = xml.getElementsByTagName('return')
    tdocid = returns[0].firstChild.nodeValue
    return tdocid

def treeno_createsub(docID, folderName):
    "Create a sub folder (aka tab) of an existing folder"
    req = createSubFolder%{'passkey':passkey, 'docID':docID, 'folderName':folderName}
    xml = treeno_req(req)
    print xml

def treeno_upload(tdocid, docid, title, filepath):
    "Upload a file to Treeno, given Treeno and Kodiak docids"
    print "TODO: read the doc from the /dms folder, and base64 encode"
    req = uploadFile%{'passkey':passkey, 'docid':docid, 'title':title}
    xml = treeno_req(req)
    print "TODO: get unique id for doc and store in kodiak database..."

def kodiak_query():
    "Run a query against DB and then loop thru resulting docs adding to Treeno"
    conn = bpgsql.connect(dsn)
    cur = conn.cursor()
    cur.execute(sql)
    while True:
        row = cur.fetchone()
        if row == None:
            break
        # Extract fields from row
        entitynumber = row[0]
        customername = row[1]
        appnum = row[2]
        schedulenum = row[3]
        #title = row[4]
        #docid = row[5]

        if entitynumber is None:
            entitynumber = ""
        if appnum is None:
            appnum = ""
        if schedulenum is None:
            schedulenum = ""
        #print entitynumber, appnum, schedulenum, title, docid
        print entitynumber, appnum, schedulenum

        # Search for, and optionally create the metadata record
        #tdocid = treeno_search(entitynumber, customername, appnum, schedulenum)
        #if not(tdocid):
        #    treeno_createsub(tdocid, "Kodiak Migrated")
            #print "no documents found"
            #tdocid = treeno_create(entitynumber, entityname, appnum, schedulenum)
        # Upload the document
        #treeno_upload(tdocid, docid, title, filepath)

print "Logging into treeno"
passkey = treeno_login()
print passkey
if re.match(r'^.+==$', passkey):
    print "Selecting documents"
    kodiak_query()
else:
    print "Error logging in to Treeno"
