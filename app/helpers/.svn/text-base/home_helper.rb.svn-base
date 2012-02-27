module HomeHelper
  class BQprocessor
    def self.intersect(accumulation, p2)
      intersection = Array.new
      i = 0
      while i < accumulation.length && p2 != nil
        if accumulation[i] == p2.document_id
          intersection.push(accumulation[i])
          i += 1
          p2 = p2.postings_rest
        elsif accumulation[i] < p2.document_id
          i += 1
        else 
          p2 = p2.postings_rest
        end
      end
      return intersection
    end
  end
end
