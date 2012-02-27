module AutoJunk
  class Application < Rails::Application
    config.after_initialize do
      token_list = []
      Dir.glob('**/*.htm') do |name|
        short_name = name.split('/').last.gsub('.htm', '')
        doc = IO.read(name)
        tokens = Tokenizer.tokenize(doc)
        tokens.each do |word|
          token_list.push(IndexStructures::Term.new(word, short_name))
        end
      end
      
      token_list.sort_by! { |term| [term.term, term.document_id] }.reverse!
      
      $INVERTED_INDEX = Hash.new
      last_term = last_document_id = ''
      token_list.each do |term|
        if term.term == last_term 
          $INVERTED_INDEX[term.term].term_frequency += 1
          if term.document_id == last_document_id
            $INVERTED_INDEX[term.term].postings_list.term_frequency += 1
          else
            $INVERTED_INDEX[term.term].postings_list = IndexStructures::Posting.new(term.document_id, 1, $INVERTED_INDEX[term.term].postings_list)
            last_document_id = term.document_id
          end
        else
          $INVERTED_INDEX[term.term] = IndexStructures::DictionaryEntry.new(1, 1, IndexStructures::Posting.new(term.document_id, 1, nil))
          last_term, last_document_id = term.term, term.document_id
        end
      end
    end
  end
end