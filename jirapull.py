#!/usr/local/bin/python

from jira import JIRA
import logging, sqlite3, datetime, time, os, sys, schedule
sys.path.append('/home/jirapullapp/')
import jirapull_encoding as je, jirapull_output as jo

# add logging control
logger = logging.getLogger("jirapullapp")
logger.setLevel(logging.INFO)
fh = logging.FileHandler("/var/log/jirapullapp.log")
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(lineno)d - %(message)s')
fh.setFormatter(formatter)
logger.addHandler(fh)

def main():
	logger.info("Jirapullapp started")

	csvoutput = True
	logger.info("CSV output active: %s" % (csvoutput))
	oraoutput = True
	logger.info("Oracle output active: %s" % (csvoutput))

	conn = sqlite3.connect('/home/jirapullapp/jirapull.db')
	cur = conn.cursor()
	cur.execute('SELECT jiraserver, jirauser, jirapassword FROM jirasettings')
	for row in cur:
		server_var = je.jpu(row[0])
		user_var = je.jpu(row[1])
		password_var = je.jpu(row[2])
		logger.debug("Server: %s" % (server_var))
		logger.debug("User: %s" % (user_var))
		logger.debug("Server: %s" % (password_var))
	jira_options = {
	    'server': server_var
	    }
	jira = JIRA(options=jira_options, basic_auth=(user_var,password_var))
	
	ts = time.time()
	updated_var = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
	
	if csvoutput:
		cur.execute('SELECT query_name, jql FROM jiraquerysettings')
		for row in cur:
			csv_loc_var = '/usr/local/src/' + row[0]
			logger.info("CSV output location: %s" % (csv_loc_var))
			jql_var = row[1]
			logger.debug("Jira Query JQL: %s" % (jql_var))
			jira_search_results_var = jira.search_issues(jql_var)
			logger.debug("Jira search results %s" % (jira_search_results_var))
			logger.debug("csv writing start")
			jo.csvwriter(csv_loc_var, jira_search_results_var, updated_var)
		logger.debug("csv end")
	if oraoutput:
		cur.execute('SELECT ip_host, port, sid, username, password, oratable FROM oraclesettings')
		for row in cur:
			logger.debug("Oracle writing start")
			ip_host_var = je.jpu(row[0])
			port_var = je.jpu(row[1])
			sid_var = je.jpu(row[2]) 
			username_var = je.jpu(row[3]) 
			password_var = je.jpu(row[4]) 
			oracletable_var = je.jpu(row[5])
			jo.orawriter(jira_search_results_var,updated_var, ip_host_var, port_var, sid_var, username_var, password_var, oracletable_var)
		logger.debug("Oracle end")
	logger.info("Jirapullapp complete")
	conn.close()

if __name__== "__main__":
	schedule.every(10).minutes.do(main)
	main()
	while 1:
		schedule.run_pending()
		time.sleep(1)
