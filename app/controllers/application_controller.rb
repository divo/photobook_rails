# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :user_agent
  before_action :mobile_app
  before_action :masthead_tag
  before_action :masthead_small_tag

  def user_agent
    @user_agent ||= request.user_agent
  end

  def mobile_app
    @mobile_app ||= @user_agent == 'Mementos-iOS'
  end

  def masthead_tag
    @masthead_tag ||= @mobile_app ? 'masthead-app' : 'masthead'
  end

  def masthead_small_tag
    @masthead_tag ||= @mobile_app ? 'masthead-app' : 'masthead-small'
  end
end
