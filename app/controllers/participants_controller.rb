class ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[update destroy
                                           project_information
                                           boq
                                           required_documents
                                           tender_documents
                                           results
                                           show_boq
                                           required_document_uploads
                                           other_documents
                                           other_document_uploads
                                           rating
                                           save_rates]

  include TenderTransactionsHelper

  include ApplicationHelper

  def project_information
    @tender_transaction = TenderTransaction.new
  end

  def boq
    if @participant.purchased?
      @tender_transaction = TenderTransaction.new
    else
      redirect_to participants_project_information_path(@participant)
    end
  end

  def required_documents
    if @participant.purchased?
      @tender_transaction = TenderTransaction.new
      @request = @participant.request_for_tender
      @required_document_upload = RequiredDocumentUpload.new
      @request.required_documents.each do |required_document|
        if @participant.required_document_uploads.find_by(required_document: required_document).nil?
          puts required_document.id
          @participant.required_document_uploads.build(required_document: required_document)
        end
      end
    else
      redirect_to participants_project_information_url(@participant)
    end
  end

  def tender_documents
    if @participant.purchased?
      @request = @participant.request_for_tender
    else
      redirect_to participants_project_information_url(@participant)
    end
  end

  def other_documents
  end

  def other_document_uploads
    if @participant.update(participant_params)
      flash[:notice] = 'File successfully saved'
    else
      flash[:notice] = 'File should be either a PDF of an Image.
                        And please make sure you provide a name'
    end
    redirect_to participants_required_documents_url(@participant)
  end

  def results; end

  # POST /participants
  # POST /participants.json
  def create
    @participant = Participant.new(participant_params)

    respond_to do |format|
      if @participant.save
        format.html { redirect_to @participant, notice: 'Participant was successfully created.' }
        format.json { render :show, status: :created, location: @participant }
      else
        format.html { render :new }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /participants/1
  # PATCH/PUT /participants/1.json
  def update
    respond_to do |format|
      if @participant.update(participant_params)
        format.html { redirect_to @participant, notice: 'Participant was successfully updated.' }
        format.json { render :show, status: :ok, location: @participant }
      else
        format.html { render :edit }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  def save_rates
    if @participant.save_rates(params[:rates])
      render json: @participant.to_json(include: :rates), status: :ok,
             location: @participant
    else
      render json: @participant.errors, status: :unprocessable_entity
    end
  end

  def rating
    respond_to do |format|
      if @participant.update(participant_params)
        format.html { redirect_to bid_required_documents_url(@participant), notice: 'Participant was successfully updated.' }
        format.json { render :show, status: :ok, location: @participant }
      else
        format.html { render :edit }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /participants/1
  # DELETE /participants/1.json
  def destroy
    @participant.destroy
    respond_to do |format|
      format.html { redirect_to participants_url, notice: 'Participant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def pay_public_tender
    @participant = Participant.new(email: params[:participant][:email],
                                   company_name: params[:participant][:company_name],
                                   phone_number: params[:participant][:phone_number])
    @participant.request_for_tender_id = params[:participant][:request_for_tender_id]
    @participant.purchase_time = Time.current
    @participant.save!
    payload = extract_payload(params[:participant][:tender_transaction_attributes],
                              params[:participant][:request_for_tender_id])
    json_document = get_json_document(payload)
    puts payload
    authorization_string = hmac_auth(json_document)
    params[:participant][:tender_transaction_attributes][:participant_id] = @participant.id
    puts params[:participant][:tender_transaction_attributes]
    results = TenderTransaction.make_payment(authorization_string, payload,
                                             params[:participant][:tender_transaction_attributes][:customer_number],
                                             params[:participant][:tender_transaction_attributes][:amount],
                                             params[:participant][:tender_transaction_attributes][:vodafone_voucher_code],
                                             params[:participant][:tender_transaction_attributes][:network_code],
                                             params[:participant][:tender_transaction_attributes][:status],
                                             @participant.id,
                                             @participant.request_for_tender.id,
                                             payload['transaction_id'])
    if !results.nil? && working_url?(results)
      flash[:notice] = "Visit #{view_context.link_to('here in', results)}
                        another tab to finish the paying with VISA/MASTER CARD.
                        After paying come back and refresh this page."
    else
      flash[:notice] = results + '. Check your email after responding to the
                                 prompt on your phone. Thank you!'
    end
    redirect_to participants_required_documents_url @participant
  end

  def required_document_uploads
    unless @participant.update(participant_params)
      puts @participant.errors.full_messages
      flash[:notice] = 'File should be either a PDF of an Image'
    end
    redirect_to participants_required_documents_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_participant
    if params[:id].first(6) == 'guest-'
      request_for_tender = RequestForTender.find(params[:id][6..-1])
      @participant = GuestParticipant.new(request_for_tender)
      @request = request_for_tender
    else
      @participant = Participant.find_by(auth_token: params[:id])
      @request = @participant.request_for_tender
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def participant_params
    params.require(:participant)
          .permit(:request_for_tender_id,
                  :company_name,
                  :phone_number,
                  :email,
                  :rating,
                  :purchased,
                  :submitted,
                  :purchase_time,
                  :submitted_time,
                  :read,
                  :rating,
                  :disqualified,
                  :notes,
                  tender_transaction_attributes: %i[id
                                                    customer_number
                                                    amount
                                                    transaction_id
                                                    vodafone_voucher_code
                                                    network_code
                                                    status
                                                    request_for_tender_id],
                  other_document_uploads_attributes: %i[id
                                                        name
                                                        document
                                                        _destroy],
                  required_document_uploads_attributes: %i[id
                                                           document
                                                           required_document_id
                                                           participant_id
                                                           _destroy])
  end
end
