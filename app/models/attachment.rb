class Attachment < ActiveRecord::Base
  after_initialize do |user|
    self.token ||= SecureRandom.hex(16)
  end

  belongs_to :space
  belongs_to :user

  mount_uploader :file, AttachmentUploader

  before_create :set_file_size
  after_create :inc_space_storage_used
  after_destroy :dec_space_storage_used

  validates_presence_of :file, :user
  validate :check_space_storage_limit, :on => :create

  def set_file_size
    if file.present? && file_changed?
      self.file_size = file.file.size
    end
  end

  def inc_space_storage_used
    space.increment!(:storage_used, file_size)
  end

  def dec_space_storage_used
    space.decrement!(:storage_used, file_size)
  end

  def check_space_storage_limit
    if file.present? && (space.storage_used + file.file.size > space.storage_limit)
      errors.add(:file, I18n.t('errors.messages.storage_limit'))
    end
  end

  def file_name
    read_attribute :file
  end
end
