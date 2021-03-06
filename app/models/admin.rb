# frozen_string_literal: true

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :confirmable,
         :timeoutable,
         :lockable

  validates :email,
            format: {
              with: /\A[a-z0-9._%+-]+@buildpals.com/i,
              message: 'You can only sign up with an official buildpals email'
            }
end
