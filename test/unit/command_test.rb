require 'test_helper'

class CommandTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Command.new.valid?
  end
end
