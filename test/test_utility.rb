require 'test_helper'

class TestUtility < Test::Unit::TestCase

  def test_decode_response
    require "json"
    object = {'key1' => 'value1', 'key2' => 'value2', 'integer_key' => 5}
    assert_equal object, Cloudsponge::Utility.decode_response_body(JSON.generate(object), 'json')
  end

end
