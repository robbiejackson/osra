require 'rails_helper'

RSpec.describe Hq::SponsorshipsController, type: :controller do
  let(:sponsorship) {build_stubbed :sponsorship, active: true}

  before :each do
    sign_in instance_double(AdminUser)
  end

  context "#inactivate" do
    let(:sponsorship_inactivator) {instance_double InactivateSponsorship}
    let(:date) {"2015-01-01"}

    before :each do
      expect(Sponsorship).to receive(:find).with(sponsorship.id.to_s).and_return(sponsorship)
      expect(InactivateSponsorship).to receive(:new)
        .with(sponsorship: sponsorship, end_date: date)
        .and_return(sponsorship_inactivator)
    end

    specify "successful" do
      expect(sponsorship_inactivator).to receive(:call).and_return(true)
      put :inactivate, id: sponsorship.id, sponsorship: {end_date: date}

      expect(response).to redirect_to hq_sponsor_path(sponsorship.sponsor)
      expect(flash[:success]).to_not be_nil
    end

    specify "unsuccessful" do
      expect(sponsorship_inactivator).to receive(:call).and_return(false)
      expect(sponsorship_inactivator).to receive(:error_msg).and_return("error mess")
      put :inactivate, id: sponsorship.id, sponsorship: {end_date: date}

      expect(response).to redirect_to hq_sponsor_path(sponsorship.sponsor)
      expect(flash[:error]).to eq "error mess"
    end
  end

  context "#destroy" do
    let(:sponsorship_destructor) {instance_double DestroySponsorship}

    before :each do
      expect(Sponsorship).to receive(:find).with(sponsorship.id.to_s).and_return(sponsorship)
      expect(DestroySponsorship).to receive(:new)
        .with(sponsorship).and_return(sponsorship_destructor)
    end

    specify "successful" do
      expect(sponsorship_destructor).to receive(:call).and_return(true)
      delete :destroy, id: sponsorship.id

      expect(response).to redirect_to hq_sponsor_path(sponsorship.sponsor)
      expect(flash[:success]).to_not be_nil
    end

    specify "unsuccessful" do
      expect(sponsorship_destructor).to receive(:call).and_return(false)
      expect(sponsorship_destructor).to receive(:error_msg).and_return("error mess")
      delete :destroy, id: sponsorship.id

      expect(response).to redirect_to hq_sponsor_path(sponsorship.sponsor)
      expect(flash[:error]).to eq "error mess"
    end
  end
end