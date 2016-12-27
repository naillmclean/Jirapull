# Jirapull
Python Docker to pull fields from Jira into a csv

Detail stored in the wiki

# Summary Usage process (also in README)
## Prerequisite
Linux Host running Docker - I used CentOS7 but it shouldn't matter (power of Docker)
Login credentials to a Jira environment

## The Steps
1. Copy the files into a folder on your Linux machine and navigate into that folder
2. Edit `jirasettings.py `
* jiraserver - **Enter the URL** of the Jira server the data has to be extracted from
* jirauser - **Enter the username** of the Jira user that will be authenticated, this currently uses the Basic_Auth method
* jirapassword - **Enter the password** of the above user
3. Edit `jiraquerysettings.py`
* jql - **Enter the required jql**, this is the same language that Jira uses in its filters.  The jql does not need to exist in Jira but I found it was easier to copy and paste from Jira and you can test the code is correct
* csvoutput - This is the output location and name of the final csv file. The default directory is in docker is usr/local/src/ which is mapped as a volume in Docker so it can be accessed from the Linux Host
4. (optional) Amend the `crontab` file to schedule your required scheduled interval. The default is **10 minutes**.
5. Build the Docker Image form the Dockerfile
`docker build -t jirapull .`
5. Run the container where jirapullname is the name you want to give tue container. 
`docker run -dit --name jirapullname:v1 jirapull`
6. After the cron time (default `10 minutes`) the csv output file will now be avaiable
