require "spec_helper"
require "rototiller/utilities/color_text.rb"

describe Rototiller::ColorText do
  # extended class
  let(:extended_dummy) { Class.new { extend Rototiller::ColorText } }
  let(:string) { random_string }
  let(:color) { 8 }

  it { expect(extended_dummy.colorize(string, color)).to match color.to_s + "m" + string }

  it { expect(extended_dummy.yellow_text(string)).to match "33m" + string }
  it { expect(extended_dummy.green_text(string)).to match "32m" + string }
  it { expect(extended_dummy.red_text(string)).to match "31m" + string }
end
