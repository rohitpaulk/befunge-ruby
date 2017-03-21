require 'test_helper'

class BefungerTest < Minitest::Test
  TEST_SAMPLES = [
    {
      name: "Hello world",
      input: '64+"!dlroW ,olleH">:#,_@',
      output: "Hello, World!\n",
    },
    {
      name: "1 to 9",
      input: ">987v>.v\nv456<  :\n>321 ^ _@",
      output: "123456789"
    }
  ]

  def test_that_it_has_a_version_number
    refute_nil ::Befunger::VERSION
  end

  def test_against_samples
    TEST_SAMPLES.each do |sample|
      actual = Befunger::Interpreter.new(sample[:input]).run
      expected = sample[:output]

      assert_equal(expected, actual, "Expected output not matched for sample #{sample[:name]}")
    end
  end

  def test_convenience_run_function
    test_sample = TEST_SAMPLES.first

    actual = Befunger.run(test_sample[:input])
    expected = test_sample[:output]

    assert_equal(expected, actual)
  end
end
