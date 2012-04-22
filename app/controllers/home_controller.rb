class HomeController < ApplicationController
  def index
  end

  def search
    @query = params[:query]
    query_array = Tokenizer.tokenize(@query)
    
    # results
    @accumulation = Array.new
    
    if params[:commit] == "Boolean Search"
      @search_type = "boolean"
      
      # turn first postings list into an array
      if $INVERTED_INDEX.has_key?(query_array[0])
        posting = $INVERTED_INDEX[query_array[0]].postings_list
        while posting != nil
          @accumulation.push(posting.document_id)
          posting = posting.postings_rest
        end
      end
      
      # find the running intersection
      for i in 1..query_array.length-1
        if $INVERTED_INDEX.has_key?(query_array[i])
          @accumulation = HomeHelper::BQprocessor.intersect(@accumulation, $INVERTED_INDEX[query_array[i]].postings_list)
        else
          @accumulation.clear
          break
        end
      end
    elsif params[:commit] == "Vector Search"
      @search_type = "vector"
      
      # create a query frequency hash table
      query_frequency_hash = Hash.new
      query_array.each do |term|
        if query_frequency_hash.has_key?(term)
          query_frequency_hash[term] += 1
        else
          query_frequency_hash[term] = 1
        end
      end
      
      # compute query length
      query_length = 0
      query_frequency_hash.keys.each do |term|
        if $INVERTED_INDEX.has_key?(term)
          # (tf*idf)^2
          idf = $INVERTED_INDEX[term].inverse_document_frequency
          query_length += (query_frequency_hash[term].to_f * idf) ** 2.to_f
        end
      end
      query_length = Math.sqrt(query_length)
      
      # compute document scores
      if query_length > 0
        scores = Hash.new
        query_frequency_hash.keys.each do |term|
          if $INVERTED_INDEX.has_key?(term)
            posting = $INVERTED_INDEX[term].postings_list
            while posting != nil
              # single vector element dot product ==> (tf*idf)_document * (tf*idf)_query
              idf = $INVERTED_INDEX[term].inverse_document_frequency
              score = posting.term_frequency * query_frequency_hash[term] * (idf ** 2)
              if scores.has_key?(posting.document_id)
                scores[posting.document_id] += score
              else
                scores[posting.document_id] = score
              end
              posting = posting.postings_rest
            end
          end
        end
        # finish computing the scores
        scores.keys.each do |document_id|
          scores[document_id] = (scores[document_id].to_f / ($LENGTH[document_id].to_f * query_length.to_f)).round(8)
        end
        # sort by scores
        @accumulation = scores.sort_by { |document_id, score| score }.reverse
      end
    else # Microsoft msdn niche search
      @search_type = "msdn"
      
      # create a query frequency hash table
      query_frequency_hash = Hash.new
      query_array.each do |term|
        if query_frequency_hash.has_key?(term)
          query_frequency_hash[term] += 1
        else
          query_frequency_hash[term] = 1
        end
      end
      
      # compute query length
      query_length = 0
      query_frequency_hash.keys.each do |term|
        if $INVERTED_INDEX_CRAWLED.has_key?(term)
          # (tf*idf)^2
          idf = $INVERTED_INDEX_CRAWLED[term].inverse_document_frequency
          query_length += (query_frequency_hash[term].to_f * idf) ** 2.to_f
        end
      end
      query_length = Math.sqrt(query_length)
      
      # compute document scores
      if query_length > 0
        scores = Hash.new
        query_frequency_hash.keys.each do |term|
          if $INVERTED_INDEX_CRAWLED.has_key?(term)
            posting = $INVERTED_INDEX_CRAWLED[term].postings_list
            while posting != nil
              # single vector element dot product ==> (tf*idf)_document * (tf*idf)_query
              idf = $INVERTED_INDEX_CRAWLED[term].inverse_document_frequency
              score = posting.term_frequency * query_frequency_hash[term] * (idf ** 2)
              if scores.has_key?(posting.document_id)
                scores[posting.document_id] += score
              else
                scores[posting.document_id] = score
              end
              posting = posting.postings_rest
            end
          end
        end
        # finish computing the scores
        scores.keys.each do |document_id|
          scores[document_id] = (scores[document_id].to_f / ($LENGTH_CRAWLED[document_id].to_f * query_length.to_f)).round(8)
        end
        # sort by scores
        @accumulation = scores.sort_by { |document_id, score| score }.reverse
      end
    end
  end
  
  def result
    @document = IO.read(Rails.root.to_s + "/config/initializers/docs/" + params[:document] + ".htm")
    respond_to do |format|
      format.html { render :text => @document }
    end
  end
end
