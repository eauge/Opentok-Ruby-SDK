require "opentok/archives"
require "opentok/opentok"
require "opentok/version"
require "opentok/archive"
require "opentok/archive_list"
require "opentok/exceptions"

require "spec_helper"


if ENV["NETWORK"] != nil
  if !ENV["API_KEY"] || !ENV["API_SECRET"]
    raise 'When using network mode, API_KEY and API_SECRET must be provided'
  end
end

describe OpenTok::Archives do

  let(:fake_api_key) {"123456"}
  let(:fake_api_secret) {"1234567890abcdef1234567890abcdef1234567890"}
  let(:default_api_url) {"https://api.opentok.com"}
  let(:api_key) { ENV["API_KEY"] || fake_api_key }
  let(:api_secret) { ENV["API_SECRET"] || fake_api_secret }
  let(:api_url) { ENV["API_URL"] || default_api_url }
  let(:session_id) { "SESSIONID" }
  let(:fake_archive_id) { "ARCHIVE_ID" }
  let(:archive_name) { "ARCHIVE NAME" }
  let(:started_archive_id) { "30b3ebf1-ba36-4f5b-8def-6f70d9986fe9" }
  let(:findable_archive_id) { "f6e7ee58-d6cf-4a59-896b-6d56b158ec71" }
  let(:deletable_archive_id) { "832641bf-5dbf-41a1-ad94-fea213e59a92" }
  let(:network_attached) { ENV["NETWORK"] != nil }

  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret, api_url}
  let(:archives) { opentok.archives }
  subject { archives }

  it { should be_an_instance_of OpenTok::Archives }

  describe "when making successful api calls" do

    let(:api_key) { fake_api_key }
    let(:api_secret) { fake_api_secret }
    let(:api_url) { default_api_url }

    it "should create archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive = archives.create session_id
      expect(archive).to be_an_instance_of OpenTok::Archive
      expect(archive.session_id).to eq session_id
      expect(archive.id).not_to be_nil
    end

    it "should create named archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive = archives.create session_id, :name => archive_name
      expect(archive).to be_an_instance_of OpenTok::Archive
      expect(archive.session_id).to eq session_id
      expect(archive.name).to eq archive_name
    end


    it "should stop archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive = archives.stop_by_id started_archive_id
      expect(archive).to be_an_instance_of OpenTok::Archive
      expect(archive.status).to eq "stopped"
    end

    it "should find archives by id", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive = archives.find findable_archive_id
      expect(archive).to be_an_instance_of OpenTok::Archive
      expect(archive.id).to eq findable_archive_id
    end

    it "should delete an archive by id", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      success = archives.delete_by_id deletable_archive_id
      expect(success).to be_true
      # expect(archive.status).to eq ""
    end

    it "should find expired archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive = archives.find findable_archive_id
      expect(archive).to be_an_instance_of OpenTok::Archive
      expect(archive.status).to eq "expired"
    end

    it "should find archives with unknown properties", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive = archives.find findable_archive_id
      expect(archive).to be_an_instance_of OpenTok::Archive
    end
  end

  describe "when making requests for invalid archive" do

    let(:archive_id) { fake_archive_id }

    before(:each) do
      enable_network
    end

    after(:each) do
      disable_network
    end

    it "should reject to create archive", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      expect { archives.create session_id }.to raise_error(OpenTok::OpenTokArchiveError)
    end

    it "should reject to stop archive", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      expect { archives.stop_by_id archive_id }.to raise_error(OpenTok::OpenTokArchiveError)
    end

    it "should reject to delete archive", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      expect { archives.delete_by_id archive_id }.to raise_error(OpenTok::OpenTokArchiveError)
    end

    it "should reject to retrieve archive", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      expect { archives.find archive_id }.to raise_error(OpenTok::OpenTokArchiveError)
    end

  end

  # TODO: context "with a session that has no participants" do
  #   let(:session_id) { "" }
  #   it "should refuse to create archives with appropriate error" do
  #     expect { archives.create session_id }.to raise_error
  #   end
  # end

  context "when many archives are created" do

    before(:each) do
      enable_network
    end

    after(:each) do
      disable_network
    end

    it "should return all archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.total).to be > 1
    end

    it "should return archives with an offset", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all :count =>3, :offset => 3
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.count).to eq 3
    end

    it "should return count number of archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all :count => 2
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.count).to eq 2
    end

    it "should return part of the archives when using offset and count", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all :count => 4, :offset => 2
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.count).to eq 4
    end

  end

end
