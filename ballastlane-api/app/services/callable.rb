module Callable
  extend ActiveSupport::Concern

  class_methods do
    def call(*args, **kwargs)
      new.call(*args, **kwargs)
    end
  end
end