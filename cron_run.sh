#!/bin/bash
rm /home/paul/Documents/linuxwork/hackerNewsApp/gotjson
echo "run cron job" > /home/paul/Documents/linuxwork/hackerNewsApp/gotjson
sh /home/paul/Documents/linuxwork/hackerNewsApp/scrap_with_data.sh
my_string=$(head -n 1 /home/paul/Documents/linuxwork/hackerNewsApp/news)
substring="items"
if [[ $my_string == *"$substring"* ]];
then
	echo "yes,sucessfully got JSON content from hacker news unofficial API"  > /home/paul/Documents/linuxwork/hackerNewsApp/gotjson
    cd /home/paul/Documents/linuxwork/hackerNewsApp/	
    /home/paul/.rvm/rubies/ruby-2.0.0-p353/bin/ruby /home/paul/Documents/linuxwork/hackerNewsApp/db.rb 
	python /home/paul/Documents/linuxwork/hackerNewsApp/db_py.py
fi



