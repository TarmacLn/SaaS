class ContactsController < ApplicationController
  before_action :authenticate_user!

  # Send a contact request
  def create
    @contact = current_user.contacts.build(contact_id: params[:user_id])
    if @contact.save
      respond_with_updates notice: "Contact request sent"
    else
      respond_with_error @contact.errors.full_messages.to_sentence
    end
  end

  # Accept a request someone sent to the current user
  def update
    @contact = current_user.all_received_contact_requests.pending.find(params[:id])
    @contact.accept!
    respond_with_updates notice: "#{@contact.user.name} is now one of your contacts"
  end

  # Decline a received request, cancel a sent one, or remove a contact
  def destroy
    @contact = Contact.where(user: current_user).or(Contact.where(contact: current_user)).find(params[:id])
    @contact.destroy!
    respond_with_updates notice: "Contact removed"
  end

  private

  # The same updates the other user gets over Action Cable, straight in the response
  def respond_with_updates(notice:)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: @contact.ui_updates_for(current_user).map { |update|
          turbo_stream.action(update[:action], update[:target], partial: update[:partial], locals: update[:locals])
        }
      end
      format.html { redirect_back fallback_location: root_path, notice: notice }
    end
  end

  def respond_with_error(message)
    respond_to do |format|
      format.turbo_stream { head :unprocessable_entity }
      format.html { redirect_back fallback_location: root_path, alert: message }
    end
  end
end
