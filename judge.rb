require 'pg'
# parse scrapped hacker news JSON file.
require "rubygems"
require "json"
require "/home/paul/Documents/linuxwork/hackerNewsApp/news_parser.rb"
require "/home/paul/Documents/linuxwork/hackerNewsApp/get_domain.rb"
require ('uri')
require ('logger')
class PostgresDirect
  # Create the connection instance.
  def connect
    @conn = PG.connect(
        :dbname => 'HackerNewsAppDB1',
        :user => 'paul',
        :password => 'password')
  end

  def prepareUpdateNewsStatement   #UPDATE films SET kind = 'Dramatic' WHERE kind = 'Drama';
    @conn.prepare("update_news", "update  newslib  set likeness = $1 ,judged = True 
        where id=$2")
  end


  def updateNews(likeness=0,id=0)
    begin
      @conn.exec_prepared("update_news", [likeness,id])
    rescue Exception => e
      puts 'update news failed'
    end

  end

  # Get our data back
  def queryNewsTable
    @conn.exec( "SELECT * FROM newslib" ) do |result|
      result.each do |row|
        yield row if block_given?
      end
    end
  end

  # Disconnect the back-end connection.
  def disconnect
    @conn.close
  end
end
def get_host_without_www(url)
  url.gsub!(/^\/comments/, "http://comments/")
  uri = URI.parse(url)
  uri = URI.parse("http://#{url}") if uri.scheme.nil?
  host = uri.host.downcase
  host.start_with?('www.') ? host[4..-1] : host
end

def main
  file = File.open('/home/paul/Documents/linuxwork/hackerNewsApp/rubylog.log', File::WRONLY | File::APPEND)
  logger = Logger.new(file)



  logger.debug("ruby judge.rb in main.\n")
  p = PostgresDirect.new()
  logger.error("ruby judge.rb after new.\n")
  p.connect
  logger.debug("ruby judge.rb after connect.\n")
  begin
  
    p.prepareUpdateNewsStatement

 
    
    p.queryNewsTable {|row| 
     puts (row['judged'])
     if (row['judged']== 't')  then
      next
     end
    
     printf("id:%d title:%s submitter:%s\n", row['id'], row['title'],row['submitter'])
     puts "Do you like this article? (Y/N/D d means don't care)"
     a = gets.chomp
     if (a=='Y')
      puts("you like it.")
      p.updateNews(2,row['id'])
     elsif (a=='N')
      puts("you don't like it.")
      p.updateNews(-2,row['id'])
     elsif (a=='D')
      puts("you don't care about it.")
      p.updateNews(1,row['id'])
     else
      puts('you gave invalid input, skip to next.')
    end
     
    }
    
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  ensure
    p.disconnect
  end
  logger.debug("ruby judge.rb finished.\n")
  logger.close
end


main