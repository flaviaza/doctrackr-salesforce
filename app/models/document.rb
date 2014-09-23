class Document < ActiveRecord::Base
  attr_accessible :dt_reference, :last_event_at, :name, :sf_reference

  attr_accessible :file

  belongs_to :user

  def file=(attribute)
    @file = attribute
  end

  def file
    @file
  end
end
