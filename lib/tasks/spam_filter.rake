def bayes_file
	Merb::Config[:bayes_file] || (Merb.root / "bayes.dat")
end

namespace :spam do 
  desc "Rebuilds the bayes spam database"
	task :rebuild do 
  	Merb.start_environment

    spammy = Comment.all(:spam => true).map(&:text)
    hammy  = Comment.all(:spam => false).map(&:text)
    bayes = Bayes.new

    spammy.each { |spam| bayes.train("spam", spam) }
    hammy.each  { |ham| bayes.train("ham", ham) }

    File.open(bayes_file, 'w') do |f|
    	f.write(bayes.dump)
    end
  end
end
