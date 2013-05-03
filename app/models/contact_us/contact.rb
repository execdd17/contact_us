class ContactUs::Contact
  include ActiveModel::Conversion
  include ActiveModel::Validations

  include Humanizer       
  require_human_on :create

  attr_accessor :email, :message, :name, :subject
  attr_accessor :humanizer_answer, :humanizer_question_id

  validates :email,   :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i },
                      :presence => true
  validates :message, :presence => true
  validates :name,    :presence => {:if => Proc.new{ContactUs.require_name}}
  validates :subject, :presence => {:if => Proc.new{ContactUs.require_subject}}
  validate :is_human?

  def is_human?
    errors[:humanizer_answer] = 'Incorrect Answer' unless humanizer_correct_answer?
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def save
    if self.valid?
      ContactUs::ContactMailer.contact_email(self).deliver
      return true
    end
    return false
  end
  
  def persisted?
    false
  end
end
