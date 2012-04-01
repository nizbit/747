module AutoJunk
  class Application < Rails::Application
    Rails.logger.instance_variable_get(:@logger).instance_variable_get(:@log_dest).sync = true if Rails.logger
    config.after_initialize do
      # create a list of tokens using the Tokenizer
      num_documents = 0
      token_list = []
      Dir.glob('**/*.htm') do |name|
        num_documents += 1
        short_name = name.split('/').last.gsub('.htm', '')
        doc = IO.read(name)
        tokens = Tokenizer.tokenize(doc)
        tokens.each do |word|
          token_list.push(IndexStructures::Term.new(word, short_name))
        end
      end
      
      # sort by term (primary) and document id (secondary) in reverse to aid in the construction of the inverted index
      token_list.sort_by! { |term| [term.term, term.document_id] }.reverse!
      
      # create the global inverted index and length hashes
      $INVERTED_INDEX = Hash.new
      $LENGTH = Hash.new
      last_term = last_document_id = ''
      token_list.each do |term|
        if term.term == last_term 
          $INVERTED_INDEX[term.term].term_frequency += 1
          if term.document_id == last_document_id
            $INVERTED_INDEX[term.term].postings_list.term_frequency += 1
          else
            $INVERTED_INDEX[term.term].postings_list = IndexStructures::Posting.new(term.document_id, 1, $INVERTED_INDEX[term.term].postings_list)
            $INVERTED_INDEX[term.term].document_frequency += 1
            last_document_id = term.document_id
          end
        else
          if !last_term.empty?
            # compute the inverse document frequency for the previous term
            $INVERTED_INDEX[last_term].inverse_document_frequency = Math.log10(num_documents.to_f / $INVERTED_INDEX[last_term].document_frequency.to_f)
            # accumulate document lengths
            posting = $INVERTED_INDEX[last_term].postings_list
            while posting != nil
              # (tf*idf)^2
              tf_idf_squared = (posting.term_frequency.to_f * $INVERTED_INDEX[last_term].inverse_document_frequency.to_f) ** 2.to_f
              if $LENGTH.has_key?(posting.document_id)
                $LENGTH[posting.document_id] += tf_idf_squared
              else
                $LENGTH[posting.document_id] = tf_idf_squared
              end 
              posting = posting.postings_rest
            end
          end
          $INVERTED_INDEX[term.term] = IndexStructures::DictionaryEntry.new(1, 0, 1, IndexStructures::Posting.new(term.document_id, 1, nil))
          last_term, last_document_id = term.term, term.document_id
        end
      end
      # finish calculating the lengths (take the square root)
      $LENGTH.keys.each do |document_id|
        $LENGTH[document_id] = Math.sqrt($LENGTH[document_id])
      end
    end
  end
end