class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,
           class_name: "Relationship",
           foreign_key: "follower_id",
           dependent: :destroy
  has_many :passive_relationships,
           class_name: "Relationship",
           foreign_key: "followed_id",
           dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_attached_file :cover,
                    styles: {
                        thumb: ["200x400#", :jpeg],
                        original: [:jpeg]
                    },
                     storage: :s3,
                  s3_credentials: {
                      access_key_id: ENV["S3_KEY"],
                      secret_access_key: ENV["S3_SECRET"],
                      bucket: ENV["S3_BUCKET"]
                  },
                  s3_region: ENV["S3_REGION"]
  validates_attachment :cover,
                       content_type: {content_type: /\Aimage\/.*\z/},
                       size: {less_than: 1.megabyte}
  attr_accessor :remember_token, :activation_token, :reset_token
  mount_uploader :avatar, AvatarUploader
  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: true
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}

  # Возвращает дайджест данной строки.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Возвращает случайный токен
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Запоминает пользователя в базе данных для использования в постоянной сессии.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Забывает пользователя
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Возвращает true, если данный токен совпадает с дайджестом.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Активирует аккаунт.
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Отправляет электронное письмо для активации.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Устанавливает атрибуты для сброса пароля.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Отправляет электронное письмо для сброса пароля.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Возвращает true, если истек срок давности ссылки для сброса пароля .
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    Micropost.where("user_id = ?", id)
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Возвращает true, если текущий пользователь читает сообщения другого пользователя.
  def following?(other_user)
    following.include?(other_user)
  end

  private

  # Переводит адрес электронной почты в нижний регистр.
  def downcase_email
    self.email = email.downcase
  end

  # Создает и присваивает активационнй токен и дайджест.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end


end
