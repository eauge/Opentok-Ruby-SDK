require "vcr"

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.hook_into                :webmock
  c.default_cassette_options = { :match_requests_on => [:method, :uri, :query, :body, :headers] }
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end


def enable_network
  if network_attached
    VCR.eject_cassette
    WebMock.allow_net_connect!
    VCR.turn_off!
  end
end

def disable_network
  if network_attached
    VCR.turn_on!
    WebMock.disable_net_connect!
  end
end
