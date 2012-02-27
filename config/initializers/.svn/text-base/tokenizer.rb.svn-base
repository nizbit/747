class Tokenizer  
  def self.tokenize(doc_string)
    tokens = Array.new
    doc_string.gsub(%r{</?[^>]+?>}, '').gsub(/[^A-Za-z\s]+/, '').downcase.split.each do |token|
      if !token.start_with?("http")
        tokens.push(token)
      end
    end
    return tokens
  end
end