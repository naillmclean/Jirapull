#!/usr/local/bin/python
import csv, cx_Oracle

def orawriter(jira_search_results_var,updated_var, ip_host_var, port_var, sid_var, username_var, password_var, oracletable_var):
	ip = ip_host_var
	port = port_var
	SID = sid_var
	username = username_var
	password = password_var
	table = oracletable_var
	column = 'KEY, SUMMARY, ASSIGNEE, STATUS, CREATED_DATE, UPDATED'
	dsn = cx_Oracle.makedsn(ip, port, SID)
	connection = cx_Oracle.connect(username,password,dsn)
	cur = cx_Oracle.Cursor(connection)
	cur.execute('delete from '  + table)
	sql = """INSERT INTO """ + table + """ ( """ + column + """) 
		VALUES (:key,:summary,:assignee,:status,to_date(:created_date,'YYYY-MM-DD'), to_date(:updated, 'YYYY-MM-DD HH24:MI:SS') )"""
	for issue in jira_search_results_var:
		cur.execute(sql, {"key" : str(issue),
				"summary" : str(issue.fields.summary), 
				"assignee" : str(issue.fields.assignee),
				"status" : str(issue.fields.status), 
				"created_date" : str(issue.fields.created[:10]), 
				"updated" : str(updated_var) })
	connection.commit()
	cur.close()
	connection.close()

def csvwriter (csv_loc_var, jira_search_results_var,updated_var):
	with open(csv_loc_var + '.csv', 'w', newline='') as csvfile:
		spamwriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_ALL)
		for issue in jira_search_results_var:
			spamwriter.writerow((issue, issue.fields.summary,  issue.fields.assignee ,issue.fields.status, issue.fields.created[:10],updated_var))
