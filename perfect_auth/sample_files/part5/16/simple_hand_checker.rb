require_relative './hand'

class SimpleHandChecker
  def initialize(cards)
    raise "count of cards must be 5" if cards.size != 5
    @cards = cards
  end

  def result
    grouped = @cards.each_with_object({}) do |card, h|
      h[card] ||= 0
      h[card] += 1
    end

    case grouped.values
    when ->(counts) { counts.max == 4 }
      FourOfAKind.new(grouped.key(4))
    when ->(counts) { counts.sort == [2, 3] }
      FullHouse.new(grouped.key(3))
    when ->(counts) { counts.max == 3 }
      ThreeOfAKind.new(grouped.key(3))
    when ->(counts) { counts.max == 2 && counts.size == 3 }
      TwoPair.new(grouped.select { |_, v| v == 2 }.keys.max)
    when ->(counts) { counts.max == 2 && counts.size == 4 }
      OnePair.new(grouped.select { |_, v| v == 2 }.keys.max)
    else
      NoHand.new(@cards.max)
    end
  end
end
