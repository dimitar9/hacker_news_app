import psycopg2
import sys 
import mytest_nltk
import datetime
# start to retrieve data from database
con = None


try:
     
    con = psycopg2.connect(database='HackerNewsAppDB1', user='paul', password='password')  
    
    cur = con.cursor()    
    cur.execute("SELECT id, title FROM newslib WHERE judged = FALSE"  )

    rows = cur.fetchall()

    extractkw =   mytest_nltk.ExtractKW()

    for row in rows:
        print row[1]
        keywords = extractkw.get_keywords(row[1])
        print "keywords is", keywords
        try:
            m_k1 = keywords[0].decode('utf-8','ignore')
        except IndexError,e:
            m_k1=""
        try:
            m_k2 = keywords[1].decode('utf-8','ignore')
        except IndexError,e:
            m_k2 =  ""

        cur.execute("UPDATE newslib SET keyword1=%s ,keyword2=%s WHERE id=%s", (m_k1,m_k2, row[0]))        
        con.commit()

except psycopg2.DatabaseError, e:
    print 'Error %s' % e    
    sys.exit(1)
    
    
finally:
    
    if con:
        con.close()
    with open('/home/paul/Documents/linuxwork/hackerNewsApp/log.txt','a') as outf:
        outf.write('%s:db_py run successfully!\n' % datetime.datetime.now().strftime("%I:%M%p-%B %d, %Y"))


