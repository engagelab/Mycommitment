require 'mongoid'

class Storage
  include Mongoid::Document

  field :name, :type => String
  field :url, :type => String
  field :s3id, :type => String
end
