# This class is a simple adapter class for the bayes library. It loads the
# bayes file specified in Merb::Config[:bayes_file] (default: Merb.root /
# 'bayes.dat') and applies the classifier when receiving the 'spam?'-Messag
class SpamHelper
  # Initializes the spam filter
  # ==== Parameters
  # file_cls<~File>:: 
  #   The file class which should be used for opening and parsing the
  #   bayes-data
	def initialize(file_cls=File)
    @contents = file_cls.read(file) rescue ''
    @bayes = (Bayes.new(@contents) rescue Bayes.new)
	end

  # Returns true if the given message is spam. If not enough training data is
  # available or the message isn't spam false is returned.
  #
  # ==== Parameters
  # message<String>:: 
  #   The actual message which should be classified.
  # ==== Returns
  # :Bool::
  #   true if the given message is spam, otherwise false.
  def spam?(message)
    begin
      @bayes.classify(message) == 'spam' 
    rescue BayesError => e  # no training data available :(
      false
    end
  end

  private
  def file
  	Merb::Config[:bayes_file] || (Merb.root / 'bayes.dat')
  end
end
