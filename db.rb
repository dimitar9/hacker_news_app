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

  # Create our test table (assumes it doesn't already exist)
  def createNewsLibTable
    begin
      @conn.exec("CREATE TABLE newslib 
	 (id integer NOT NULL, 
 	 title character varying(255),
	 url character varying(255),
 	 points integer,
	 submitter character varying(255),
   domain    character varying(255),
   keyword1  character varying(32),
   keyword2  character varying(32),	
   likeness  integer,
   judged boolean,
   archivetime timestamp,
 CONSTRAINT newslib_pkey PRIMARY KEY (id)) WITH (OIDS=FALSE);");
    rescue
      puts 'Table newslib already exist'
    end
  end

  # When we're done, we're going to drop our test table.
  #def dropUserTable
  #  @conn.exec("DROP TABLE users")
  #end


  def prepareInsertNewsStatement
    @conn.prepare("insert_news", "insert into newslib 
    ( id ,
      title,
      url,
      points,
      submitter,
      domain,
      keyword1,
      keyword2, 
      likeness,
      judged,
      archivetime )
      values ($1, $2 ,$3 ,$4, $5, $6, $7, $8, $9, $10, $11)")
  end

  def addNews(id ,title,url="",points=0,submitter="",domain="",
    keyword1="",keyword2="", likeness=0,judged=FALSE,archivetime =Time.now.getutc)
    begin
      @conn.exec_prepared("insert_news", [id ,title,url,points,submitter,
      domain,keyword1,keyword2, likeness,judged,archivetime])
    rescue Exception => e
      puts 'record already exists'
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



  logger.debug("ruby db.rb in main.\n")
  p = PostgresDirect.new()
  logger.error("ruby db.rb after new.\n")
  p.connect
  logger.debug("ruby db.rb after connect.\n")
  begin
    p.createNewsLibTable
    p.prepareInsertNewsStatement
    np = NewsParser.new()
    dm = Domain.new()
    news_json=[]
    files = Dir['/home/paul/Documents/linuxwork/hackerNewsApp/news.20*']
    files.each { |x| 
    news_json = np.getParsedLatestPage(x)
  }

    news_json["items"].each do |item|
      p.addNews(item["id"], item["title"].encode('utf-8'),item["url"],
        item["points"], item["postedBy"],get_host_without_www(item["url"]),"","",0, FALSE,Time.now.getutc)
    end
    p.queryNewsTable {|row| 
      printf("id:%d title:%s submitter:%s\n", row['id'], row['title'],row['submitter'])
    }
    
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  ensure
    p.disconnect
  end
  logger.debug("ruby db.rb finished.\n")
  logger.close
end


main