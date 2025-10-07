
module Api
  class IpsController < ApplicationController
    include ErrorHandler

    def shared_authors
      query = Ips::SharedAuthorsQuery.new
      render json: query.as_json
    end
  end
end
