# jiraquerysettings.py
#
jql = 'project = HU AND issuetype = bug AND resolution = Unresolved AND (labels in (AutomationFailTestCase, Designer_Automation_Testing, RCT, AnalyticsAutomationFail) OR summary ~ RCT) AND (createdDate > "2016/12/10" OR key in (HU-3469,HU-3430, HU-3412)) ORDER BY created DESC, priority DESC, Severity DESC'
csvoutput = '/usr/local/src/jirapulloutput.csv'
