require 'simple_hand_checker'

class SimpleHandCheckerTest < Test::Unit::TestCase
  def test_initialize_about_input_card_count
    assert_raise(RuntimeError) { SimpleHandChecker.new([1, 2, 3, 3, 4, 5]) }
    assert_raise(RuntimeError) { SimpleHandChecker.new([1, 2, 3, 5]) }
    assert_nothing_raised { SimpleHandChecker.new([1, 2, 3, 4, 5]) }
  end

  sub_test_case "#result" do
    def test_result_when_cards_is_four_of_a_kind
      hand = SimpleHandChecker.new([1, 1, 1, 1, 5]).result
      assert { hand.is_a?(FourOfAKind) }
      assert { hand.max_card == 1 }
    end

    def test_result_when_cards_is_full_house
      hand = SimpleHandChecker.new([1, 1, 2, 2, 2]).result
      assert { hand.is_a?(FullHouse) }
      assert { hand.max_card == 2 }
    end

    def test_result_when_cards_is_three_of_a_kind
      hand = SimpleHandChecker.new([1, 3, 2, 2, 2]).result
      assert { hand.is_a?(ThreeOfAKind) }
      assert { hand.max_card == 2 }
    end

    def test_result_when_cards_is_two_pair
      hand = SimpleHandChecker.new([1, 3, 3, 2, 2]).result
      assert { hand.is_a?(TwoPair) }
      assert { hand.max_card == 3 }
    end

    def test_result_when_cards_is_one_pair
      hand = SimpleHandChecker.new([1, 3, 4, 2, 2]).result
      assert { hand.is_a?(OnePair) }
      assert { hand.max_card == 2 }
    end
    
    def test_result_when_cards_is_no_hand
      hand = SimpleHandChecker.new([1, 3, 5, 7, 2]).result
      assert { hand.is_a?(NoHand) }
      assert { hand.max_card == 7 }
    end
  end
end
