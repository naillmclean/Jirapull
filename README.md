# Jirapull
Python Docker to pull fields from Jira into a csv

Detail stored in the wiki

# Summary Usage process (also in README)
## Prerequisite
Linux Host running Docker - I used CentOS7 but it shouldn't matter (power of Docker)
Login credentials to a Jira environment

## The Steps

Copy the files into a folder on your Linux machine and navigate into that folder
Edit jirasettings using a text editor. Only one row is supported, Add a space between each
Enter the URL of the Jira server the data has to be extracted from
Enter the username of the Jira user that will be authenticated, this currently uses the Basic_Auth method
Enter the password of the above user
Edit jiraquerysettings using a text editor, multiple rows are supported, keep the headings row.
queryname - This is the output name of the csv file. The default directory is in docker is usr/local/src/ which is mapped as a volume in Docker so it can be accessed from the Linux Host
jql - Enter the required jql wrapped in the | symbol. This is the same language that Jira uses in its filters. The jql does not need to exist in Jira but I found it was easier to copy and paste from Jira and you can test the code is correct
Optional Edit oraclesettings to include the Oracle DB connection details Unfortunately, Oracle does not allow us to include their software in docker-images, so you need to download Oracle Instant Client linux binaries (and accept their license) before we build the image.
Get the following files

oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
from here

Place the files in the same directory as the Dockerfile.

leave the headings row, the data is , separate data
The fields are ip_host,port,sid,username,password,oratable *oratable needs to be the schema.tablename e.g. HR.USERS
Aa your tnsnames.ora into the root folder that contains the dockerfile, replace tue default
Build the Docker Image form the Dockerfile docker build -t jirapull .
Run the container where jirapullname is the name you want to give the container. docker run -dit --name jirapullname jirapull
The csv output and Oracle table will be populated and then the data will be replaced every 10 minutes
