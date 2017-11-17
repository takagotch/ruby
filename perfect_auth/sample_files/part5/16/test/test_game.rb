require 'game'
require 'test/unit/rr'
require 'stringio'

class TestForGameStart < Test::Unit::TestCase
  def setup
    @__current_stdout__ = $stdout
    $stdout = StringIO.new

    @game = Game.new
  end

  def cleanup
    @stdout = @__current_stdout__
  end

  def test_start_if_player1_win
    mock(@game).shuffle_deck do
      [
        1, 1, 2, 3, 4,
        5, 7, 8, 10, 12,
      ]
    end

    assert_empty(@game.results)
    @game.start
    assert_match(/player1 win/, $stdout.string)
    last_result = @game.results.last
    assert_equal([1, 1, 2, 3, 4], last_result[0])
    assert_instance_of(OnePair, last_result[1])
    assert_equal([5, 7, 8, 10, 12], last_result[2])
    assert_instance_of(NoHand, last_result[3])
    assert_equal("player1", last_result[4])
  end

  def test_start_if_player2_win
    mock(@game).shuffle_deck do
      [
        5, 7, 8, 10, 12,
        1, 1, 2, 3, 4,
      ]
    end

    assert_empty(@game.results)
    @game.start
    assert_match(/player2 win/, $stdout.string)
    last_result = @game.results.last
    assert_equal([5, 7, 8, 10, 12], last_result[0])
    assert_instance_of(NoHand, last_result[1])
    assert_equal([1, 1, 2, 3, 4], last_result[2])
    assert_instance_of(OnePair, last_result[3])
    assert_equal("player2", last_result[4])
  end

  def test_start_if_draw
    mock(@game).shuffle_deck do
      [
        1, 1, 2, 3, 4,
        1, 1, 2, 3, 4,
      ]
    end

    assert_empty(@game.results)
    @game.start
    assert_match(/draw/, $stdout.string)
    last_result = @game.results.last
    assert_equal([1, 1, 2, 3, 4], last_result[0])
    assert_instance_of(OnePair, last_result[1])
    assert_equal([1, 1, 2, 3, 4], last_result[2])
    assert_instance_of(OnePair, last_result[3])
    assert_nil(last_result[4])
  end

  def test_win_ratio_case1
    mock(@game).shuffle_deck do
      [
        1, 1, 2, 3, 4,
        5, 7, 8, 10, 12,
        1, 1, 2, 3, 4,
        5, 7, 8, 10, 12,
        11, 11, 2, 3, 4,
        9, 9, 9, 0, 10,
      ]
    end

    assert_empty(@game.results)
    @game.start
    @game.start
    @game.start
    assert_equal(3, @game.results.size)
    @game.win_ratio
    assert_match(/player1: 66.7%/, $stdout.string)
    assert_match(/player2: 33.3%/, $stdout.string)
  end

  def test_win_ratio_case2
    mock(@game).shuffle_deck do
      [
        1, 1, 2, 3, 4,
        5, 7, 8, 10, 12,
        1, 1, 2, 3, 4,
        5, 7, 8, 10, 12,
      ]
    end

    assert_empty(@game.results)
    @game.start
    @game.start
    assert_equal(2, @game.results.size)
    @game.win_ratio
    assert_match(/player1: 100.0%/, $stdout.string)
    assert_match(/player2: 0.0%/, $stdout.string)
  end

  def test_win_ratio_case3
    mock(@game).shuffle_deck do
      [
        1, 1, 2, 3, 4,
        5, 7, 8, 10, 12,
        5, 7, 8, 10, 12,
        1, 1, 2, 3, 4,
      ]
    end

    assert_empty(@game.results)
    @game.start
    @game.start
    assert_equal(2, @game.results.size)
    @game.win_ratio
    assert_match(/player1: 50.0%/, $stdout.string)
    assert_match(/player2: 50.0%/, $stdout.string)
  end

  def test_proxy
    obj = Object.new
    mock(obj).foo(3) { |count| "foo" * count }
    assert { obj.foo(3) == "foofoofoo" }

    mock(obj).bar.with_any_args.times(2) # obj.barをどんな引数でも良いがちょうど2回呼び出している必要がある
    obj.bar(1)
    obj.bar(2)
    mock(obj).buz.with_no_args.times(2..3) # obj.buzを引数無しで少なくとも2回呼び出している必要がある
    obj.buz
    obj.buz
  end
end
