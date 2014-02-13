# parse scrapped hacker news JSON file.
require "rubygems"
require "json"
#curl http://api.ihackernews.com/new
class NewsParser
	def getParsedLatestPage(filename="/home/paul/Documents/linuxwork/hackerNewsApp/news")
		
		
		
	


		file = File.open(filename,"rb")
		contents = file.read

		parsed = JSON.parse(contents) # returns a hash

=begin
	parsed["items"].each do |item|
  		puts item["id"]
  		puts item["title"]
  		puts item["url"]
  		puts item["points"]
  		puts item["postedAgo"]
  		puts item["postedBy"]
	end
=end
		return parsed
	end
end
