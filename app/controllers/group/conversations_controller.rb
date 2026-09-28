class Group::ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :edit, :update, :open, :close, :mark_as_seen ]

  # Create a group from the user's contacts
  def new
    @conversation = Group::Conversation.new
    @contacts = current_user.all_active_contacts.order(:name)
  end

  def create
    @conversation = Group::Conversation.new(name: params.dig(:group_conversation, :name))
    @conversation.memberships.build(user: current_user)
    selected_contacts.each { |contact| @conversation.memberships.build(user: contact) }

    if @conversation.save
      add_to_conversations(@conversation)
      @conversation.users.each { |member| @conversation.broadcast_menu_to(member) }
      redirect_to messenger_group_path(@conversation), notice: "Group created"
    else
      @contacts = current_user.all_active_contacts.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # Add more of the user's contacts to the group
  def edit
    @contacts = addable_contacts
  end

  def update
    new_members = selected_contacts.where.not(id: @conversation.users.select(:id))
    if new_members.empty?
      @contacts = addable_contacts
      @conversation.errors.add(:base, "Choose at least one contact to add")
      return render :edit, status: :unprocessable_entity
    end

    new_members.each { |contact| @conversation.memberships.create!(user: contact) }
    @conversation.users.each { |member| @conversation.broadcast_menu_to(member) }
    redirect_to messenger_group_path(@conversation), notice: "#{new_members.map(&:name).to_sentence} added"
  end

  # Show a group's window (again); windows opened by an incoming message start collapsed
  def open
    add_to_conversations(@conversation)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.prepend("conversations-windows",
                                                  partial: "group/conversations/conversation",
                                                  locals: { conversation: @conversation, user: current_user,
                                                            expanded: params[:expanded] != "false" })
      end
      format.html { redirect_to messenger_group_path(@conversation) }
    end
  end

  def close
    remove_from_conversations(@conversation)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(helpers.conversation_window_id(@conversation)) }
      format.html { redirect_back fallback_location: root_path }
    end
  end

  # The other members' messages have been read (window opened or clicked)
  def mark_as_seen
    @conversation.broadcast_menu_to(current_user) if @conversation.mark_as_seen_by(current_user)
    head :no_content
  end

  private

  # only groups the user is a member of
  def set_conversation
    @conversation = Group::Conversation.for_user(current_user).find(params[:id])
  end

  # only the user's own contacts can be added
  def selected_contacts
    current_user.all_active_contacts.where(id: Array(params.dig(:group_conversation, :user_ids)))
  end

  def addable_contacts
    current_user.all_active_contacts.where.not(id: @conversation.users.select(:id)).order(:name)
  end
end
