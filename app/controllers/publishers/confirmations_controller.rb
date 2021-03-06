# frozen_string_literal: true

class Publishers::ConfirmationsController < Devise::ConfirmationsController
  include Accessible

  skip_before_action :check_user, only: :show

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end

  def after_confirmation_path_for(resource_name, resource)
    sign_out resource if signed_in?(resource_name)
    token = resource.send(:set_reset_password_token)
    edit_password_url(resource, reset_password_token: token)
  end
end
