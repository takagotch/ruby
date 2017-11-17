class Hand
  attr_reader :max_card

  include Comparable

  def initialize(max_card)
    @max_card = max_card
  end

  def <=>(other)
    score_diff = score - other.score
    score_diff == 0 ? max_card - other.max_card : score_diff
  end

  # Please override
  def score
  end
end

class FourOfAKind < Hand
  def score
    10
  end
end

class FullHouse < Hand
  def score
    5
  end
end

class ThreeOfAKind < Hand
  def score
    3
  end
end

class TwoPair < Hand
  def score
    2
  end
end

class OnePair < Hand
  def score
    1
  end
end

class NoHand < Hand
  def score
    0
  end
end
