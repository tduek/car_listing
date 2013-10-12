class PicsController < ApplicationController

  def show
    @pic = Pic.find(params[:id])

    redirect_to @pic.src
  end
end
