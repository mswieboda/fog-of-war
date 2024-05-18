require "game_sf"

require "./fog_of_war/game"

module FogOfWar
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks
  alias Screen = GSF::Screen
  alias Timer = GSF::Timer
  alias Point = NamedTuple(x: Int32, y: Int32)

  Game.new.run
end
