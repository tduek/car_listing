class PicsController < ApplicationController

  def show
    @pic = Pic.find(params[:id])

    if @pic.src[/craigslist/]

    end

    redirect_to @pic.src
  end
end
