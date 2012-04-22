class Indexer
  def self.CreateIndexes(num_documents, token_list)
    inverted_index = Hash.new
    length = Hash.new
    last_term = last_document_id = ''
    token_list.each do |term|
      if term.term == last_term 
        inverted_index[term.term].term_frequency += 1
        if term.document_id == last_document_id
          inverted_index[term.term].postings_list.term_frequency += 1
        else
          inverted_index[term.term].postings_list = IndexStructures::Posting.new(term.document_id, 1, inverted_index[term.term].postings_list)
          inverted_index[term.term].document_frequency += 1
          last_document_id = term.document_id
        end
      else
        if !last_term.empty?
          # compute the inverse document frequency for the previous term
          inverted_index[last_term].inverse_document_frequency = Math.log10(num_documents.to_f / inverted_index[last_term].document_frequency.to_f)
          # accumulate document lengths
          posting = inverted_index[last_term].postings_list
          while posting != nil
            # (tf*idf)^2
            tf_idf_squared = (posting.term_frequency.to_f * inverted_index[last_term].inverse_document_frequency.to_f) ** 2.to_f
            if length.has_key?(posting.document_id)
              length[posting.document_id] += tf_idf_squared
            else
              length[posting.document_id] = tf_idf_squared
            end 
            posting = posting.postings_rest
          end
        end
        inverted_index[term.term] = IndexStructures::DictionaryEntry.new(1, 0, 1, IndexStructures::Posting.new(term.document_id, 1, nil))
        last_term, last_document_id = term.term, term.document_id
      end
    end
    # finish calculating the lengths (take the square root)
    length.keys.each do |document_id|
      length[document_id] = Math.sqrt(length[document_id])
    end
    return inverted_index, length
  end
end