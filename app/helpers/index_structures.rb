module IndexStructures
  class Term
    attr_accessor :term, :document_id
    
    def Initialize(term, document_id)
      @term = term
      @document_id = document_id
    end
  end
  
  class DictionaryEntry
    attr_accessor :document_frequency, :term_frequency, :postings_list
    
    def initialize(document_frequency, term_frequency)
      @document_frequency = document_frequency
      @term_frequency = term_frequency
      @postings_list = Posting.new nil
    end
  end
  
  class Posting
    attr_accessor :document_id, :term_frequency, :postings_rest
    
    def initialize(document_id, term_frequency)
      @document_id = document_id
      @term_frequency = term_frequency
      @postings_rest = Posting.new nil
    end
  end
end