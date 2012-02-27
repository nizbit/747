class HomeController < ApplicationController
  def index
  end

  def search
    @query = params[:query]
    query_array = Tokenizer.tokenize(@query)
    
    # turn first postings list into an array
    @accumulation = Array.new
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
  end
  
  def result
    @document = IO.read(Rails.root.to_s + "/config/initializers/docs/" + params[:document] + ".htm")
    respond_to do |format|
      format.html { render :text => @document }
    end
  end
end
