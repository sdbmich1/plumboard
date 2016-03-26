require "spec_helper"

describe InvoicesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/invoices")).to route_to("invoices#index")
    end

    it "routes to #new" do
      expect(get("/invoices/new")).to route_to("invoices#new")
    end

    it "routes to #edit" do
      expect(get("/invoices/1/edit")).to route_to("invoices#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/invoices")).to route_to("invoices#create")
    end

    it "routes to #show" do
      expect(get("/invoices/1")).to route_to("invoices#show", :id => "1")
    end

    it "routes to #update" do
      expect(put("/invoices/1")).to route_to("invoices#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/invoices/1")).to route_to("invoices#destroy", :id => "1")
    end

    it "routes to #sent" do
      expect(get("/invoices/sent")).to route_to("invoices#sent")
    end

    it "routes to #received" do
      expect(get("/invoices/received")).to route_to("invoices#received")
    end

    it "routes to #autocomplete_user_first_name" do
      expect(get("/invoices/autocomplete_user_first_name")).to route_to("invoices#autocomplete_user_first_name")
    end

    it "routes to #pay" do
      expect(get("/invoices/1/pay")).to route_to("invoices#pay", :id => "1")
    end

    it "routes to #remove" do
      expect(put("/invoices/1/remove")).to route_to("invoices#remove", :id => "1")
    end

    it "routes to #decline" do
      expect(put("/invoices/1/decline")).to route_to("invoices#decline", :id => "1")
    end
  end
end

