module IndexStructures
  class Term
    attr_accessor :term, :document_id
    
    def initialize(term, document_id)
      @term = term
      @document_id = document_id
    end
  end
  
  class DictionaryEntry
    attr_accessor :document_frequency, :term_frequency, :postings_list
    
    def initialize(document_frequency, term_frequency, postings_list)
      @document_frequency = document_frequency
      @term_frequency = term_frequency
      @postings_list = postings_list
    end
  end
  
  class Posting
    attr_accessor :document_id, :term_frequency, :postings_rest
    
    def initialize(document_id, term_frequency, postings_rest)
      @document_id = document_id
      @term_frequency = term_frequency
      @postings_rest = postings_rest
    end
  end
end