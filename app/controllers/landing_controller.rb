class LandingController < ApplicationController
  def index
  end
  def profile
  end
  def people
    @list_of_people = current_user.fetch_people(params[:provider])
  end
end
