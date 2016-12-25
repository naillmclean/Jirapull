#! /usr/bin/env python
from jira import JIRA
import jirasettings
import jiraquerysettings
import csv

jira_options = {
    'server': jirasettings.jiraserver
    }
jira = JIRA(options=jira_options, basic_auth=(jirasettings.jirauser,jirasettings.jirapassword))
issues_qa_auto = jira.search_issues(jiraquerysettings.jql)
with open(jiraquerysettings.csvoutput, 'w', newline='') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_ALL)
    for issue in issues_qa_auto:
         spamwriter.writerow((issue, issue.fields.summary,  issue.fields.assignee ,issue.fields.status, issue.fields.created[:10]))

