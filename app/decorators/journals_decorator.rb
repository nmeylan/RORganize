class JournalsDecorator < ApplicationCollectionDecorator

  def first
    object.first
  end
end
