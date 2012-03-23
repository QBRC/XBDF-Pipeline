require 'test_helper'

class RunTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Run.new.valid?
  end
end
