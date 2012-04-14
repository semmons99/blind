require_relative "helper"
require_relative "../lib/blind/world"

describe Blind::World do
  it "must control player movement" do
    game = new_game

    pos = game.player_position

    game.move_player(3,2)
    game.move_player(7,-5)

    game.player_position.must_equal(Ray::Vector2.new(pos.x + 10, pos.y - 3))
  end

  it "must kill the player when out of bounds" do
    game = new_game
    dead = false

    game.on_event(:out_of_bounds) { dead = true }

    # FIXME: Remove magic numbers
    game.move_player(-game.player_position.x + 0.5, 0)
    dead.must_equal(false)

    game.move_player(-1, 0)
    dead.must_equal(true)
  end

  it "must be able to place several mines" do
    game = new_game(10)

    game.mines.count.must_equal(10)
  end

  it "must kill the player when colliding with a mine" do
    game = new_game(1) # limit to a single mine to prevent test failure
    dead = false

    game.on_event(:mine_collision) { dead = true }

    danger_zone = game.mine_positions[0]
    
    game.move_player(-game.player_position.x + danger_zone.x-6, 
                     -game.player_position.y + danger_zone.y)

    dead.must_equal(false)

    game.move_player(1,0)
    dead.must_equal(true)
  end

  it "must finish in a win when the player finds the exit" do
    game = new_game
    win  = false

    game.on_event(:exit_located) { win = true }

    game.move_player(-game.player_position.x + game.exit_position.x,
                     -game.player_position.y + game.exit_position.y - 1.5)

    win.must_equal(false)

    game.move_player(0,1)
    win.must_equal(true)
  end

  it "must be able to determine escape_risk" do
    game = new_game

    # FIXME: Remove magic numbers
    game.move_player(-game.player_position.x + 1.5,
                     -game.player_position.y + 2.5)

    game.escape_risk(10).must_equal(0.9)

    game.move_player(-game.player_position.x + 93, 0)
    game.escape_risk(10).must_equal(0.8)
  end

  it "must return an escape_risk of 0 for a player within the margins" do
    game = new_game

    game.move_player(-game.player_position.x + 25,
                     -game.player_position.y + 25)

    game.escape_risk(10).must_equal(0)
  end

  it "must return an escape_risk of 1 for an out of bounds player" do
    game = new_game

    game.move_player(-game.player_position.x,
                     -game.player_position.y)

    game.escape_risk(10).must_equal(1)
  end

  # mines are disabled by default to prevent test failure
  def new_game(mines=0)
    Blind::World.new(mines)
  end
end