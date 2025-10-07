module Api
  class RatingsController < ApplicationController
    include ErrorHandler

    def create
      creator = Ratings::Creator.new(
        post_id: rating_params[:post_id],
        user_id: rating_params[:user_id],
        value: rating_params[:value]
      ).call

      if creator.success?
        render json: { average_rating: creator.average_rating.to_s }, status: :created
      else
        render_validation_errors(creator.errors)
      end
    end

    private

    def rating_params
      params.require(:rating).permit(:post_id, :user_id, :value)
    end
  end
end
