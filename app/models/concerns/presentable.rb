module Presentable
  # TODO: Why in the hell doesn't this work on an existing object?
  def decorate
    "#{self.class}Presenter".constantize.new(self)
  end
end
