class FormsController < ApplicationController

def new
  end
 
def create
    render text: params[:form].inspect
  end

end
