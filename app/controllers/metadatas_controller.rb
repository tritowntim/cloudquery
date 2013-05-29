class MetadatasController < ApplicationController

	def index
		@metadatas = Metadata.order('size_bytes DESC')
	end

end