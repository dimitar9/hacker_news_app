#bayes trainer

require 'pg'
require "rubygems"
require "json"
require "/home/paul/Documents/linuxwork/hackerNewsApp/news_parser.rb"
require "/home/paul/Documents/linuxwork/hackerNewsApp/get_domain.rb"
require ('uri')
require ('logger')

class PostgresDirect
  Liked = 2
  Noliked = -2
  Dontcare = 1
  attr_accessor :liked_keyword_hash 
  attr_accessor :noliked_keyword_hash 
  attr_accessor :dontcare_keyword_hash 

  attr_accessor :liked_keyword_prob_hash 
  attr_accessor :noliked_keyword_prob_hash 
  attr_accessor :dontcare_keyword_prob_hash 

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


  #likeCatetory: LIKED, NOLIKED,DONTCARE
  def getCategoryArticleNum(likeCategory)
    #sum = 0
    #queryNewsTable {  |row|  
    #if (row['likeness'] == likeCategory)
     # sum += 1
    #end
    #}
    return 100.0
  end


  def getCategoryKeywordCount(likeCategory, keyword)
=begin
    sum = 0
    queryNewsTable {|row| 
    if((row['likeness'] == likeCategory) and ((row['keword1'] == keyword) or(row['keword2'] == keyword)) )
      sum += 1
    end
    } 
=end
    if (keyword == '')
      return 0
    else
      return 5.0
    end
  end

  def getProbLiked
    return ( getCategoryArticleNum(Liked) / (getCategoryArticleNum(Liked) + getCategoryArticleNum(Noliked) + getCategoryArticleNum(Dontcare)))
  end

  def getProbNoLiked
    return (getCategoryArticleNum(Noliked) / (getCategoryArticleNum(Liked) + getCategoryArticleNum(Noliked) + getCategoryArticleNum(Dontcare)))
  end

  def getProbDontcare
    return (getCategoryArticleNum(Dontcare) / (getCategoryArticleNum(Liked) + getCategoryArticleNum(Noliked) + getCategoryArticleNum(Dontcare)))
  end

  def incr_liked_keyword_hashvalue(row,keyword_hash)
    if (row['keyword1'] != nil)
      keyword_hash[row['keyword1']] += 1
    end
    if (row['keyword2'] != nil)
      keyword_hash[row['keyword12']] += 1
    end
  end

  def incr_noliked_keyword_hashvalue(row,noliked_keyword_hash)
    if (row['keyword1'] != nil)
      noliked_keyword_hash[row['keyword1']] += 1
    end
    if (row['keyword2'] != nil)
      noliked_keyword_hash[row['keyword12']] += 1
    end
  end

  def incr_dontcare_keyword_hashvalue(row,dontcare_keyword_hash)
    if (row['keyword1'] != nil)
      dontcare_keyword_hash[row['keyword1']] += 1
    end
    if (row['keyword2'] != nil)
      dontcare_keyword_hash[row['keyword12']] += 1
    end
  end


end
  def main
    p = PostgresDirect.new()

    liked_keyword_hash = Hash.new(0)
    noliked_keyword_hash = Hash.new(0)
    dontcare_keyword_hash = Hash.new(0)

    liked_keyword_prob_hash = Hash.new(0)
    noliked_keyword_prob_hash = Hash.new(0)
    dontcare_keyword_prob_hash = Hash.new(0)
    file = File.open('/home/paul/Documents/linuxwork/hackerNewsApp/rubylog.log', File::WRONLY | File::APPEND)
    logger = Logger.new(file)
    m_prob_liked = p.getProbLiked
    m_prob_noliked = p.getProbNoLiked
    m_prob_dontcake = p.getProbDontcare


    logger.debug("ruby trainer.rb in main.\n")

    logger.error("ruby trainer.rb after new.\n")
    p.connect
    logger.debug("ruby trainer.rb after connect.\n")
    begin
    
      p.prepareUpdateNewsStatement

   
      
      p.queryNewsTable { |row| 
        logger.debug("ruby trainer.rb in query !after #{__LINE__}.\n" )
        
        if (row['likeness'] == '2')
          p.incr_liked_keyword_hashvalue(row,liked_keyword_hash)
        elsif (row['likeness'] == '-2')
          p.incr_noliked_keyword_hashvalue(row,noliked_keyword_hash)
        elsif (row['likeness'] == '1')
          p.incr_dontcare_keyword_hashvalue(row,dontcare_keyword_hash)
        end
      }
      logger.debug("ruby trainer.rb after #{__LINE__}.\n" )
      liked_keyword_hash.keys.each do |key|
        val = liked_keyword_hash[key]
        liked_keyword_prob_hash[key] = val / m_prob_liked
        logger.debug("ruby trainer.rb liked training after #{__LINE__}.\n" )
           
      end
      logger.debug("ruby trainer.rb after #{__LINE__}.\n" )
      noliked_keyword_hash.keys.each do |key|
        val = noliked_keyword_hash[key]
        noliked_keyword_prob_hash[key] = val / m_prob_noliked
           
      end
      logger.debug("ruby trainer.rb after #{__LINE__}.\n" )
      dontcare_keyword_hash.keys.each do |key|
        val = dontcare_keyword_hash[key] 
        dontcare_keyword_prob_hash[key] = val / m_prob_dontcake
           
      end
      logger.debug("ruby trainer.rb after #{__LINE__}.\n" )

      liked_keyword_prob_hash.delete_if {|key, value| key == nil }  
      liked_keyword_prob_hash.keys.each do |key|
        val = liked_keyword_prob_hash[key] 
        puts key + ': ' + val.to_s
     
      end
      logger.debug("ruby trainer.rb after #{__LINE__}.\n" )

    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    ensure
      p.disconnect
    end
    logger.debug("ruby trainer.rb finished.\n")
    logger.close
  end


main