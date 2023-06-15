# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :user_agent
  before_action :mobile_app?

  def user_agent
    @user_agent ||= request.user_agent
  end

  def mobile_app?
    @mobile_app ||= @user_agent == 'Mementos-iOS'
  end
end
