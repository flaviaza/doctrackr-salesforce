class Document < ActiveRecord::Base
  attr_accessible :dt_reference, :last_event_at, :name, :sf_reference
end
