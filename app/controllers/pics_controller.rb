class PicsController < ApplicationController

  def create
    if params[:pic_data] && extension = params[:pic_data][11..14][/jpeg|jpg|png/]
      file = Tempfile.new(["pic", ".#{extension}"])

      raw_data = params[:pic_data]["data:image/#{extension};base64,".length..-1]
      file.binmode
      file.write(Base64.decode64(raw_data))

      @pic = Pic.new(file: file)

      if @pic.save
        render json: @pic
      else
        render json: @pic.errors, status: 422
      end

    else
      render json: {error: "Invalid data submitted"}, status: 422
    end

  end

end