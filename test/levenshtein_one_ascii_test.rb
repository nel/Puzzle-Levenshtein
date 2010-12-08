require 'test/unit'
require File.join(File.dirname(__FILE__),'../lib/levenshtein_one_ascii.rb')

class TC_MyTest < Test::Unit::TestCase
  def setup
    @datastore = { 'aaa' => 1, 'aba' => 1, 'ac' => 1, 'odbc' => 1, 'abc' => 1, 'ddd' => 1, 'dbc' => 1}
    @lev = LevenshteinOneAscii.new(@datastore)
  end

  def test_social_network
    assert_equal 6, @lev.count_social_network('aaa')
    assert !@lev.social_network('abc').include?('ddd')
  end
end

