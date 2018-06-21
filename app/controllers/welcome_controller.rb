# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    if current_quantity_surveyor
      redirect_to quantity_surveyor_root_path
    elsif current_contractor
      redirect_to quantity_surveyor_root_path
    else
      redirect_to 'https://www.tenderswift.com'
    end
  end

  def query_request_for_tender
    render layout: false
  end

  def find_request_for_tender
    @search_result = RequestForTender.find(params[:reference_number])
    redirect_to purchase_tender_url(@search_result)
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = 'Sorry, we couldn\'t find a request for tender ' \
                     'with the specified reference number.'
    redirect_to 'https://public.tenderswift.com/'
  end
end
