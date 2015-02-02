class Subscriber < ActiveRecord::Base

  # Creates array of top ten posts from reddit's front page. Each post has attributes in a hash.
  def self.top_ten
    return RedditKit.front_page(options = {:limit => 10})
  end

  # Saves each individual post as a new record to db -- this is run every 1 minute as a sidekiq job
  def self.save_top_ten
    Subscriber.top_ten.each do |post|
      new_sub = Subscriber.new
      new_sub.title = post.title.html_safe
      new_sub.count = post.score
      new_sub.subreddit = post.subreddit
      new_sub.save!
    end
  end

  # Get the top ten title score has for past x number of minutes
  def self.title_score_hash_timeframe(x)
    # Check if the number of minutes is 0 or null and just return the latest from reddit right now
    if !x.present? or x.to_i == 0
      return title_score_hash
    end
    # If the number of minutes is greater than 0 and a valid integer search the database for x number of minutes
    ten_hash = {}
    topten = Subscriber.where('created_at > ?', Time.now.utc - x.to_i.minutes).order(count: :desc).to_a.uniq{ |item| item.title }[0..9] rescue nil
    if !topten.nil?
      topten.each do |t|
        ten_hash["#{t.title}"] = t.count
      end
    end
    return ten_hash
  end

  def self.hashify(x)
    hash = {}
    x.each do |t|
      hash["#{t.title}"] = t.score
    end
    hash = Hash[hash.sort_by{|k, v| v}.reverse]
    return hash
  end

  def self.clicked_post(title)
    postsfound = Subscriber.where("title LIKE ?", title) rescue nil
  end


# EXPERIMENTAL

  #test me with:   Subscriber.doughnut_data(Subscriber.last.title)
  def self.doughnut_data(title)
    op = Subscriber.find_by_title(title).author #find the author based on the title
    op_posts = Subscriber.where("author = ?", op) #get all op's posts
    op_posts_unique = op_posts.to_a.uniq{ |item| item.title } #only get unique posts
    op_subreddits = op_posts_unique.map(&:subreddit)
    #count the number of similar subreddits
    countsubreddits = Hash.new 0
    op_subreddits.each { |word| countsubreddits[word] += 1 } #iterate through the array, adding +1 each time a same subreddit is seen
    op_subreddits_counted = Hash[countsubreddits.sort_by{|k, v| v}] #sort the counts highest to lowest based on results count

    return op_subreddits_counted #<----- remove me, just for testing

    hash = {}
    op_posts.each do |x|
      hash["#{x.subreddit}"]
    end
  end

  def self.hashify_deux(x, k, v)
    hash = {}
    x.each do |t|
      hash["#{t.k}"] = t.v
    end
    return hash
  end
end
