#!/usr/local/bin/python
# jirapull_db.py
import sqlite3, csv, jirapull_encoding as je
conn = sqlite3.connect('/home/jirapullapp/jirapull.db')
cur = conn.cursor()

cur.execute('DROP TABLE IF EXISTS jirasettings')
cur.execute('DROP TABLE IF EXISTS jiraquerysettings')
cur.execute('DROP TABLE IF EXISTS oraclesettings')
cur.execute('CREATE TABLE jirasettings (jiraserver TEXT, jirauser TEXT, jirapassword TEXT)')
cur.execute('CREATE TABLE jiraquerysettings(query_name TEXT, jql TEXT)')
cur.execute('CREATE TABLE oraclesettings(ip_host TEXT, port TEXT, sid TEXT, username TEXT, password TEXT, oratable TEXT)')

with open('/home/jirapullapp/jirasettings', 'r') as f:
	for line in f:
		data = line.split()
		jiraserver_l = je.jpl(data[0])
		jirauser_l = je.jpl(data[1])
		jirapassword_l = je.jpl(data[2])
		cur.execute('INSERT INTO jirasettings (jiraserver, jirauser, jirapassword) values(?,?,?)', (jiraserver_l, jirauser_l, jirapassword_l))
		if 'str' in line:
			break
conn.commit()

with open('/home/jirapullapp/jiraquerysettings', newline='') as csvfile:
	dr = csv.DictReader(csvfile, delimiter=',',quotechar='|')
	to_db = [(i['query_name'], i['jql']) for i in dr]
cur.executemany("INSERT INTO jiraquerysettings (query_name, jql) values(?,?);", to_db)
conn.commit()

with open('/home/jirapullapp/oraclesettings', newline='') as csvfile:
	dr = csv.DictReader(csvfile, delimiter=',',quotechar='|')
	to_db = [(je.jpl(i['ip_host']), je.jpl(i['port']), je.jpl(i['sid']), je.jpl(i['username']), je.jpl(i['password']), je.jpl(i['oratable'])) for i in dr]
cur.executemany("INSERT INTO oraclesettings (ip_host,port,sid,username,password,oratable) values(?,?,?,?,?,?);", to_db)
conn.commit()

conn.close()
