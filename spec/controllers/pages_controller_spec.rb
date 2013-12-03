require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe PagesController do

  # This should return the minimal set of attributes required to create a valid
  # Page. As you add validations to Page, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "name" => "MyString", "permalink" => "about" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PagesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before(:each) do
    controller.stub(:admin?).and_return(true)
  end

  describe "GET index" do
    it "assigns all pages as @pages" do
      page = Page.create! valid_attributes
      get :index, {}
      assigns(:pages).should eq([page])
    end
  end

  describe "GET show" do
    before :each do
      admin_user = double('User')
      admin_user.stub(:admin?).and_return(true)
      controller.stub(:current_user).and_return(admin_user)
      @valid_page = double('Page')
      @error_page = double('Page')
    end

    it 'assigns @admin if current_user is admin' do
      get :show, { :id => 'lalalala' }
      assigns(:admin).should be_true
    end

    it 'assigns @page if params[id] is a valid permalink' do
      Page.should_receive(:find_by_permalink!).with('lalala').and_return(@valid_page)
      get :show, { :id => 'lalala'}
      assigns(:page).should eq @valid_page
    end

    it 'assigns 404 page if params[id] is not a valid permalink' do
      Page.should_receive(:find_by_permalink!).with('lalala').and_raise(ActiveRecord::RecordNotFound)
      Page.should_receive(:find_by_permalink!).with('404').and_return(@error_page)
      get :show, { :id => 'lalala'}
      assigns(:page).should eq @error_page
    end

    #TODO  Test respond_to with correct status codes
    it 'respond code should be ' do
      Page.stub(:find_by_permalink!)
      get :show, { :id => 'lalala' }, :format => :json
      post :create, :my_model => {'these' => 'params'}, :format => :json
      response.body.should == my_model.to_json
    end

  end

  describe "GET new" do
    it "assigns a new page as @page" do
      get :new, {}
      assigns(:page).should be_a_new(Page)
    end
  end

  describe "GET edit" do
    it "assigns the requested page as @page" do
      page = Page.create! valid_attributes
      get :edit, {:id => page.to_param}
      assigns(:page).should eq(page)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Page" do
        expect {
          post :create, {:page => valid_attributes}
        }.to change(Page, :count).by(1)
      end

      it "assigns a newly created page as @page" do
        post :create, {:page => valid_attributes}
        assigns(:page).should be_a(Page)
        assigns(:page).should be_persisted
      end

      it "redirects to the created page" do
        post :create, {:page => valid_attributes}
        response.should redirect_to(Page.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved page as @page" do
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        post :create, {:page => { "name" => "invalid value" }}
        assigns(:page).should be_a_new(Page)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        post :create, {:page => { "name" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested page" do
        page = Page.create! valid_attributes
        # Assuming there are no other pages in the database, this
        # specifies that the Page created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Page.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
        put :update, {:id => page.to_param, :page => { "name" => "MyString" }}
      end

      it "assigns the requested page as @page" do
        page = Page.create! valid_attributes
        put :update, {:id => page.to_param, :page => valid_attributes}
        assigns(:page).should eq(page)
      end

      it "redirects to the page" do
        page = Page.create! valid_attributes
        put :update, {:id => page.to_param, :page => valid_attributes}
        response.should redirect_to(page)
      end
    end

    describe "with invalid params" do
      it "assigns the page as @page" do
        page = Page.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        put :update, {:id => page.to_param, :page => { "name" => "invalid value" }}
        assigns(:page).should eq(page)
      end

      it "re-renders the 'edit' template" do
        page = Page.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Page.any_instance.stub(:save).and_return(false)
        put :update, {:id => page.to_param, :page => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested page" do
      page = Page.create! valid_attributes
      expect {
        delete :destroy, {:id => page.to_param}
      }.to change(Page, :count).by(-1)
    end

    it "redirects to the pages list" do
      page = Page.create! valid_attributes
      delete :destroy, {:id => page.to_param}
      response.should redirect_to(pages_url)
    end
  end

end
