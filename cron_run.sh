#!/bin/bash
sh scrap_with_data.sh
my_string=$(head -n 1 news)
substring="items"
if [[ $my_string == *"$substring"* ]];
then
	echo "yes,sucessfully got JSON content from hacker news unofficial API"
	ruby db.rb
	python db_py.py
fi



