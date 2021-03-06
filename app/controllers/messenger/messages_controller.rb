module Messenger
  class MessagesController < ApplicationController
    layout false

    attr_reader :receipt

    def create
      service = Services::MessagesControllerCreate.new(sender: current_user, params: params[:message])
      service.run
      redirect_to action: :index
    end

    def destroy
      receipt.destroy
      redirect_to action: :index
    end

    def index
      render locals: { messages: messages }
    end

    def new
      @message = Message.new
    end

    def show
      render locals: { message: message }
    end

    private

      def message
        @message ||= receipt.message
      end

      def messages
        @messages ||= current_user.messages
      end

      def receipt
        @receipt ||= begin
          id = params.fetch(:id, nil)
          current_user.receipts.includes(:message).where(message_id: id).first
        end
      end

      def whitelisted_params
        params
          .require(:message)
          .permit(:body, { recipients: [:class, :id] }, :sender, :subject)
      end
  end
end
