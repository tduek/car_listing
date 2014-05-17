class PicsController < ApplicationController

  def create
    extension = params[:pic_data][11..14][/jpeg|jpg|png|bmp/]
    file = Tempfile.new(["pic", ".#{extension}"])

    raw_data = params[:pic_data]["data:image/#{extension};base64,".length..-1]
    file.binmode
    file.write(Base64.decode64(raw_data))

    @pic = Pic.new(file: file)

    if @pic.save
      render json: @pic
    else
      render json: @pic.errors.full_messages, status: 422
    end
  end

end