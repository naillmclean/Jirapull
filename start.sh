#/!bin/bash
# docker cmd file
python /home/jirapullapp/jirapull_db.py
rm /home/jirapullapp/jiraquerysettings
rm /home/jirapullapp/oraclesettings
rm /home/jirapullapp/jirasettings
rm /home/jirapullapp/jirapull_db.py
python /home/jirapullapp/jirapull.py
/bin/bash
