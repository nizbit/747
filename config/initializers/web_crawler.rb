require 'open-uri'
require 'net/http'
require 'uri'

class WebCrawler
  def self.Spider(root)
    num_documents = 0
    token_list = []
    url_repository = Hash.new
    url_frontier = Queue.new
        
    url_frontier.push(root)
        
    while !url_frontier.empty? && num_documents < 5000
      url = url_frontier.pop
      if url != nil && url.include?(root) && !url_repository.has_key?(url)
        p url
        begin
          html = open(url){|f| f.read}
        rescue
          next
        end
        
        # extract url's
        html.scan(/<a\/?[^>]*>/).each do |aTag|
          url_frontier.push(URI.extract(aTag, ['http'])[0])
        end
        
        # tokenize
        Tokenizer.tokenize(html).each do |word|
          token_list.push(IndexStructures::Term.new(word, url))
        end
        
        # add to the repository
        url_repository[url] = true
        num_documents += 1
        
        # be polite
        sleep(0.1)
      end
    end
    
    # sort by term (primary) and document id (secondary) in reverse to aid in the construction of the inverted index
    return num_documents, token_list.sort_by! { |term| [term.term, term.document_id] }.reverse!
  end
end