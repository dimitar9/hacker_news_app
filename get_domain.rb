
# need pre-process /comments/72828 this kind of url
# add http:/ will work

require ('uri')
class Domain
	def get_host_without_www(url)
	  url.gsub!(/^\/comments/, "http://comments/")
	  uri = URI.parse(url)
	  uri = URI.parse("http://#{url}") if uri.scheme.nil?
	  host = uri.host.downcase
	  host.start_with?('www.') ? host[4..-1] : host
	end


end


	#testurl = '/comments/23342'
	#testurl.gsub!(/^\/comments/, "http://comments/")
	#puts testurl