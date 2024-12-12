require "rails_helper"

RSpec.describe RelayResultsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/relay_results").to route_to("relay_results#index")
    end

    it "routes to #new" do
      expect(get: "/relay_results/new").to route_to("relay_results#new")
    end

    it "routes to #show" do
      expect(get: "/relay_results/1").to route_to("relay_results#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/relay_results/1/edit").to route_to("relay_results#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/relay_results").to route_to("relay_results#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/relay_results/1").to route_to("relay_results#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/relay_results/1").to route_to("relay_results#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/relay_results/1").to route_to("relay_results#destroy", id: "1")
    end
  end
end
