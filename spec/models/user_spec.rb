require 'spec_helper'
 
describe User do

  let (:model) { mock_model("Organization") }
  
  it 'must find an admin in find_by_admin with true argument' do
    FactoryGirl.create(:user, admin: true)
    result = User.find_by_admin(true)
    result.admin?.should be_true
  end

  it 'must find a non-admin in find_by_admin with false argument' do
    FactoryGirl.create(:user, admin: false ) 
    result = User.find_by_admin(false)
    result.admin?.should be_false
  end

  it 'does not allow mass assignment of admin for security' do
    user = FactoryGirl.create(:user, admin: false)
    user.update_attributes(:admin=> true)
    user.save!
    user.admin.should be_false
  end

  context 'is admin' do
    subject(:user) { create(:user, admin: true) }  
    
    it 'can edit organizations' do
      user.can_edit?(model).should be_true 
    end

  end
  
  context 'is not admin' do 
    
    let( :non_associated_model ) { mock_model("Organization") }
    
    subject(:user) { create(:user, admin: false, organization: model ) } 
    
    it 'can edit associated organization' do
      user.organization.should eq model
      user.can_edit?(model).should be_true 
    end
    
    it 'can not edit non-associated organization' do
      user.organization.should eq model
      user.can_edit?(non_associated_model).should be_false
    end
    
    it 'can not edit when associated with no org' do
      user.organization = nil
      user.organization.should eq nil
      user.can_edit?(non_associated_model).should be_false
    end

    it 'can not edit when associated with no org and attempting to access non-existent org' do
      user.can_edit?(nil).should be_false
    end
   
  end

  # http://stackoverflow.com/questions/12125038/where-do-i-confirm-user-created-with-factorygirl
  describe '#make_admin_of_org_with_matching_email' do
    before do
      Gmaps4rails.stub(:geocode => nil)
      @user = FactoryGirl.create(:user, email: 'bert@charity.org')
      @admin_user = FactoryGirl.create(:user, email: 'admin@charity.org')
      @mismatch_org = FactoryGirl.create(:organization, email: 'admin@other_charity.org')
      @match_org = FactoryGirl.create(:organization, email: 'admin@charity.org')
    end

    it 'should call promote_new_user after confirmation' do
      @user.should_receive(:make_admin_of_org_with_matching_email)
      @user.confirm!
    end

    it 'should not promote the user if org email does not match' do
      @user.make_admin_of_org_with_matching_email
      @user.organization.should_not eq @mismatch_org
      @user.organization.should_not eq @match_org
    end

    it 'should not promote the admin user if org email does not match' do
      @admin_user.make_admin_of_org_with_matching_email
      @admin_user.organization.should_not eq @mismatch_org
    end

    it 'should promote the admin user if org email matches' do
      @admin_user.make_admin_of_org_with_matching_email
      @admin_user.organization.should eq @match_org
    end

  end
  describe '#promote_to_org_admin' do
    subject(:user) { User.new }

    it 'gets pending org id' do
      user.should_receive(:pending_organization_id).and_return('4')
      user.stub(:organization_id=)
      user.stub(:pending_organization=)
      user.stub(:save!)
      user.promote_to_org_admin
    end
    it 'sets organization id to pending_organization id' do
      user.stub(:pending_organization_id).and_return('4')
      user.should_receive(:organization_id=).with('4')
      user.stub(:pending_organization=)
      user.stub(:save!)
      user.promote_to_org_admin
    end
    it 'sets pending organization id to nil' do
      user.stub(:pending_organization_id)
      user.stub(:organization_id=)
      user.should_receive(:pending_organization_id=).with(nil)
      user.stub(:save!)
      user.promote_to_org_admin
    end
    it 'saves changes' do
      user.stub(:pending_organization_id)
      user.stub(:organization_id=)
      user.stub(:pending_organization_id=)
      user.should_receive(:save!)
      user.promote_to_org_admin
    end
  end

  describe '#can_request_org_admin?' do
    subject(:user) { User.new }
    before(:each) do
      user.stub(:admin?).and_return(false)
      user.stub(:organization).and_return(nil)
      user.stub(:pending_organization).and_return(nil)
      @organization = double('Organization')
      @other_organization = double('Organization')
    end

    it 'is false when user is site admin' do
      user.should_receive(:admin?).and_return(true)
      user.can_request_org_admin?(@organization).should be_false
    end

    it 'is false when user is charity admin of this charity' do
      user.should_receive(:organization).and_return(@organization)
      user.can_request_org_admin?(@organization).should be_false
    end

    it 'is true when user is charity admin of another charity' do
      user.should_receive(:organization).and_return(@other_organization)
      user.can_request_org_admin?(@organization).should be_true
    end

    it 'is true when user is charity admin of no charity' do
      user.should_receive(:organization).and_return(nil)
      user.can_request_org_admin?(@organization).should be_true
    end

    it 'is false when user is pending charity admin of this charity' do
      user.should_receive(:pending_organization).and_return(@organization)
      user.can_request_org_admin?(@organization).should be_false
    end

    it 'is true when user is pending charity admin of another charity' do
      user.should_receive(:pending_organization).and_return(@other_organization)
      user.can_request_org_admin?(@organization).should be_true
    end

    it 'is true when user is pending charity admin of no charity' do
      user.should_receive(:pending_organization).and_return(nil)
      user.can_request_org_admin?(@organization).should be_true
    end

    it 'is true when user is not (site admin || charity admin of this charity || pending charity admin of this charity)' do
      user.can_request_org_admin?(@organization).should be_true
    end

  end

end
