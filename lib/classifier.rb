path = File.expand_path('../../lib/classifier', __FILE__)
$:.unshift(path) if File.directory?(path) && !$:.include?(path)

require 'json'

module NewsAgg
  module Classifier
    autoload :Statistic, 'statistic'

    # TODO: classify item
    def self.classify(item)
      classifier = Statistic.new(training_data)
      scores = classifier.scores(item.content)

      category, score = scores.max_by{ |k,v| v }
      R.zadd("category:#{category}", item.timestamp, item.key) # sorted set
      R.set("score:#{item.key}", scores.to_json) # hash

      # DEBUG: classified object
      p "classifying... medium => #{item.medium_key}, key => #{item.key}, title => #{item.title}, :category => #{category}"
    end

    private
      def self.training_data
        return @training_data if @training_data

        @training_data = {}
        Category.all.each do |category|
          @training_data[category.name] = TrainingSet.find(category.name).content
        end
        @training_data
      end
  end
end