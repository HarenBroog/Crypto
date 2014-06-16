require 'certificate_authority'

class Certificate
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :init
  belongs_to :user

  validates_format_of :domain, with: /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/

  field :cert, type: String
  field :parent, type: String
  
  field :root, type: Boolean, default: false
  field :organization, type: String
  field :text, type: String
  field :domain, type: String
  


  private

  def init
    if root
      
      
      
    end
  end
  
end
