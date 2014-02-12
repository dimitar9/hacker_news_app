#!/bin/sh
rm -f news
curl http://api.ihackernews.com/page > news
#curl http://api.ihackernews.com/new > /home/paul/Documents/linuxwork/hackerNewsApp/news 
#curl http://hnify.herokuapp.com/get/newest > hnify_news_newest
filename="news"
echo $filename 
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Current Time : $current_time"
newfilename="$filename.$current_time" 
echo $newfilename
cp $filename $newfilename
 
echo "news scrapper run sucessful"
