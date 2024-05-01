require "game_sf"

require "./cave/game"

module Cave
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks
  alias Screen = GSF::Screen
  alias Timer = GSF::Timer
  alias Point = NamedTuple(x: Int32, y: Int32)

  Game.new.run
end
