require_relative "helper"
require_relative "../lib/blind/game"

describe Blind::Game do
  it "must control player movement" do
    game = Blind::Game.new

    pos = game.player_position

    game.move_player(3,2)
    game.move_player(7,-5)

    game.player_position.must_equal(Ray::Vector2.new(pos.x + 10, pos.y - 3))
  end

  it "must kill the player when out of bounds" do
    game = Blind::Game.new
    dead = false

    game.on_event(:out_of_bounds) { dead = true }

    # FIXME: Remove magic numbers
    game.move_player(-game.player_position.x + 5, 0)
    dead.must_equal(false)

    game.move_player(-1, 0)
    dead.must_equal(true)
  end

  it "must be able to determine escape_risk" do
    game = Blind::Game.new

    # FIXME: Remove magic numbers
    game.move_player(-game.player_position.x + 6,
                     -game.player_position.y + 7)

    game.escape_risk(10).must_equal(0.9)

    game.move_player(-game.player_position.x + 93, 0)
    game.escape_risk(10).must_equal(0.8)
  end

  it "must return an escape_risk of 0 for a player within the margins" do
    game = Blind::Game.new

    game.move_player(-game.player_position.x + 25,
                     -game.player_position.y + 25)

    game.escape_risk(10).must_equal(0)
  end

  it "must return an escape_risk of 1 for an out of bounds player" do
    game = Blind::Game.new

    game.move_player(-game.player_position.x,
                     -game.player_position.y)

    game.escape_risk(10).must_equal(1)
  end
end