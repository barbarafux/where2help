require "rails_helper"

require "chatbot/operation"

describe ChatbotOperation::Message do
  let(:optin_message) { JSON.load(File.read(Rails.root.join("spec", "fixtures", "chatbot_optin_message.json"))) }
  let(:text_message) { JSON.load(File.read(Rails.root.join("spec", "fixtures", "chatbot_text_message.json"))) }

  it "should relate message to user when user connects" do
    ref = "fake_reference" # this is brittle, but it works
    user = create(:user)
    user.create_facebook_account(referencing_id: ref)
    ChatbotOperation::Message.(optin_message)
    expect(user.reload.facebook_account.facebook_id).to eq("fake_sender_id")
  end

  it "should save a record of a text message" do
    user = create(:user)
    user.create_facebook_account(facebook_id: "fake_sender_id")
    ChatbotOperation::Message.(text_message)
    payload = user.reload.bot_messages.where(from_bot: false).first.payload
    text = payload["_text"]
    expect(text).to eq("hi")
  end
end
