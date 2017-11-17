require_relative './simple_hand_checker'
require 'pp'

class Game
  attr_reader :results

  def initialize
    @results = []
    @deck = []
  end

  def start
    if @deck.size < 10
      @deck = shuffle_deck
    end

    player1_cards = 5.times.each_with_object([]) do |_, cards|
      cards << @deck.shift
    end

    player2_cards = 5.times.each_with_object([]) do |_, cards|
      cards << @deck.shift
    end

    player1_hand = SimpleHandChecker.new(player1_cards).result
    player2_hand = SimpleHandChecker.new(player2_cards).result

    if player1_hand > player2_hand
      puts "player1 win"
      @results << [player1_cards, player1_hand, player2_cards, player2_hand, "player1"]
    elsif player1_hand < player2_hand
      puts "player2 win"
      @results << [player1_cards, player1_hand, player2_cards, player2_hand, "player2"]
    else
      puts "draw"
      @results << [player1_cards, player1_hand, player2_cards, player2_hand, nil]
    end

    pp @results.last
  end

  def win_ratio
    matches = @results.size
    group_by_winner = @results.group_by { |r| r[4] }
    win_ratio_of_player1 = (group_by_winner["player1"]&.size || 0) / matches.to_f
    win_ratio_of_player2 = (group_by_winner["player2"]&.size || 0) / matches.to_f

    puts "player1: #{(win_ratio_of_player1 * 100).round(1)}%"
    puts "player2: #{(win_ratio_of_player2 * 100).round(1)}%"
  end

  private

  def shuffle_deck
    ((1..13).to_a * 4).shuffle
  end
end
