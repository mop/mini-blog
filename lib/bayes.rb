# This class is an error class which might be thrown on error by the library.
class BayesError < RuntimeError
end

# This class implements a simple naive bayes classifier
# @public
# ---
#
class Bayes
  # Initializes the classifier with optional data
  # === Parameters
  # data<~String>:: the data, which is dumped via the Marshal.dump command
	def initialize(data=nil)
		@data = data
    @categories = Marshal.load(data) if data
    @categories ||= {}
	end

  # Returns a list of categories
  #
  # === Returns
  # Array<String>:: A list of categories is returned
  def categories
  	@categories.keys.map(&:to_s)
  end

  # Trains the naive bayes classifier with the given string which belongs to
  # the given category.
  #
  # === Parameters
  # cat<~String>:: The category to which the given string belongs
  # str<~String>:: The text, which should be categorized.
  def train(cat, str)
    c = cat.to_sym
    hash = str_to_hash(str)
    @categories[c] ||= {}
    @categories[c] = merge_by_inc(@categories[c], hash)
    clear_word_count
  end

  # Classifies the given text based upon the training-data
  #
  # === Returns
  # String:: The name of the category is returned to which the text belongs to
  def classify(text)
    raise BayesError.new("too few categories") if @categories.empty?
    words = text_to_words(text)
    res = @categories.map { |k, c| [k, cat_score(c, words)] }.sort_by do |val|
      val[1] 
    end
    res.last[0].to_s
  end

  # Dumps the object's data-hash using the marshaller module
  #
  # === Returns
  # String:: A string is returned, which represents the data of this object. It
  #   can be saved to disk.
  def dump
  	Marshal.dump(@categories)
  end

  private
  # Splits the given text into an array of (tokenized, normalized, ...) words.
  #
  # === Parameters
  # text<~String>:: The text which should be converted into a list of words
  #
  # === Returns
  # Array<String>:: A list of words is returned.
  def text_to_words(text)
  	text.split
  end

  # Converts a given text-string into a hash which counts the occurence of all
  # words in the given text-string.
  #
  # === Parameters
  # str<~String>:: The text, whose words should be counted.
  #
  # === Returns
  # Hash<String => Integer>:: Returns a hash which mappes words to word-counts.
  def str_to_hash(str)
    hash = Hash.new { |h, k| h[k] = 0 }
  	text_to_words(str).inject(hash) do |h, w|
    	h[w] += 1
      h
    end
  end

  # Merges the two given hashes into a single hash by adding their values
  #
  # === Example
  #   merge_by_inc({ "a" => 1 }, { "a" => 4, "b" => 2 })
  #   # => { "a" => 5, "b" => 2 }
  #
  # === Parameters
  # h1<Hash<String => Fixnum>>:: The first hash into which values are merged
  # h2<Hash<String => Fixnum>>:: The second hash from which values are taken
  #
  # === Returns
  # Hash<String => Fixnum>:: A new hash with the updated values is returned.
  def merge_by_inc(h1, h2)
  	h2.keys.inject(h1.dup) do |result, key|
    	result[key] ||= 0
      result[key] += h2[key]
      result
    end
  end

  # Returns the score which the given category achieved for the given list of
  # words.
  #
  # === Parameters
  # cat<Hash<String => Fixnum>>:: A hash which represents the category which
  #   consists of words which are mapped to their number of occurenced
  # words<Array<String>>:: A list of words which are occuring in the string
  #   which should be classified
  # 
  # === Returns
  # Float:: A number representing the score is returned (the more, the better)
  def cat_score(cat, words)
    sum = words.inject(1) do |result, word|
    	occur_cat   = cat[word] || 0.5
      occur_whole = word_count[word]
      next result unless occur_cat && occur_whole
      result *= occur_cat.to_f / occur_whole.to_f
    end
    sum.to_f * cat_sum_words(cat).to_f / num_words.to_f
  end

  # Returns the sum of the words in the given category
  #
  # === Parameters
  # cat<Hash<String => Fixnum>>:: A hash which maps words to their number of
  #   occurences in the category
  # 
  # === Returns
  # Fixnum:: The total number of words in the given category is returned.
  def cat_sum_words(cat)
    cat.inject(0) do |result, vals|
      word, word_count = vals
    	result += word_count
    end
  end

  # Returns the total number of words in all categories
  # 
  # === Returns
  # Fixnum:: The total number of words is returned.
  def num_words
  	word_count.inject(0) do |result, vals|
      word, wc = vals
    	result += word_count[word]
    end
  end

  # Returns a hash, which includes every possible word with their number of 
  # occurences
  #
  # === Returns
  # Hash<String => Fixnum>:: A hash which maps words to their number of
  #   occurences is returned.
  def word_count
    @word_count ||= compute_word_count
  end

  # Computes the actual word count for the word_count-method
  def compute_word_count
  	@categories.inject({}) do |result, vals|
      key, cat = vals
    	cat.inject(result) do |res, vals|
        word, word_count = vals
      	res[word] ||= 0 
        res[word] += word_count
        res
      end
      result
    end
  end

  # Clears the word_count cache, which makes sense after training the
  # classifier.
  def clear_word_count
  	@word_count = nil
  end
end
