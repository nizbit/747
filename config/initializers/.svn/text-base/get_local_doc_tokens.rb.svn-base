class LocalDocTokenizer
  def self.GetLocalDocTokens
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
    return num_documents, token_list.sort_by! { |term| [term.term, term.document_id] }.reverse!
  end
end