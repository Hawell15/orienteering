require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/entries", type: :request do
  
  # This should return the minimal set of attributes required to create a valid
  # Entry. As you add validations to Entry, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      Entry.create! valid_attributes
      get entries_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      entry = Entry.create! valid_attributes
      get entry_url(entry)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_entry_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      entry = Entry.create! valid_attributes
      get edit_entry_url(entry)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Entry" do
        expect {
          post entries_url, params: { entry: valid_attributes }
        }.to change(Entry, :count).by(1)
      end

      it "redirects to the created entry" do
        post entries_url, params: { entry: valid_attributes }
        expect(response).to redirect_to(entry_url(Entry.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Entry" do
        expect {
          post entries_url, params: { entry: invalid_attributes }
        }.to change(Entry, :count).by(0)
      end

    
      it "renders a successful response (i.e. to display the 'new' template)" do
        post entries_url, params: { entry: invalid_attributes }
        expect(response).to be_successful
      end
    
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested entry" do
        entry = Entry.create! valid_attributes
        patch entry_url(entry), params: { entry: new_attributes }
        entry.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the entry" do
        entry = Entry.create! valid_attributes
        patch entry_url(entry), params: { entry: new_attributes }
        entry.reload
        expect(response).to redirect_to(entry_url(entry))
      end
    end

    context "with invalid parameters" do
    
      it "renders a successful response (i.e. to display the 'edit' template)" do
        entry = Entry.create! valid_attributes
        patch entry_url(entry), params: { entry: invalid_attributes }
        expect(response).to be_successful
      end
    
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested entry" do
      entry = Entry.create! valid_attributes
      expect {
        delete entry_url(entry)
      }.to change(Entry, :count).by(-1)
    end

    it "redirects to the entries list" do
      entry = Entry.create! valid_attributes
      delete entry_url(entry)
      expect(response).to redirect_to(entries_url)
    end
  end
end
