module AutoJunk
  class Application < Rails::Application
    Rails.logger.instance_variable_get(:@logger).instance_variable_get(:@log_dest).sync = true if Rails.logger
    config.after_initialize do
      # create the global inverted index and length hashes for local documents
      num_documents, token_list = LocalDocTokenizer.GetLocalDocTokens
      $INVERTED_INDEX, $LENGTH = Indexer.CreateIndexes(num_documents, token_list)
      
      # create the global inverted index and length hashes for crawled documents
      num_documents, token_list = WebCrawler.Spider('http://msdn.microsoft.com/en-us/')
      $INVERTED_INDEX_CRAWLED, $LENGTH_CRAWLED = Indexer.CreateIndexes(num_documents, token_list)
    end
  end
end