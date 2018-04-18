# frozen_string_literal: true

class OtherDocumentUploadsController < ContractorsController
  layout 'file_viewer', only: %i[pdf_viewer image_viewer]

  before_action :mark_other_document_as_read, only: %i[image_viewer
                                                       pdf_viewer]

  before_action :set_tender, only: %i[other_documents]

  before_action :authenticate_quantity_surveyor!

  def other_documents
    render layout: 'bids'
  end

  def pdf_viewer; end

  def image_viewer; end

  def update
    set_other_document_upload
    @other_document_upload.update(bid_params)
    flash[:notice] = if @other_document_upload.status.eql?('approved')
                       "You have successfully approved the
                         #{@other_document_upload.name}"
                     else
                       "#{@other_document_upload.name}
                         was rejected"
                     end
    redirect_to bid_other_documents_url(@other_document_upload.tender)
  end

  private

  def mark_other_document_as_read
    set_tender
    set_other_document_upload
    @other_document_upload.update!(read: true)
  end

  def set_tender
    @tender = Tender.find(params[:id])
  end

  def set_other_document_upload
    @other_document_upload =
      OtherDocumentUpload.find(params[:other_document_id])
  end

  def bid_params
    params.require(:other_document_upload)
          .permit(:name,
                  :tender_id,
                  :document,
                  :status,
                  :read)
  end
end
