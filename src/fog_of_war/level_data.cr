require "json"

module FogOfWar
  class LevelData
    include JSON::Serializable

    getter levels : Hash(String, Level)

    FilePath = "./assets/level_data.dat"

    def initialize
      level = Level.new
      @levels = Hash(String, Level).new
      @levels[level.key] = level
    end

    def update_level(level)
      # TODO: add prompt to confirm overwrite, for now, always overwrite
      @levels[level.key] = level
    end

    def remove_level(id)
      levels.delete(level) if levels.has_key?(id)
    end

    def save
      File.write(FilePath, to_json)
    end

    def self.load
      if File.exists?(FilePath)
        self.from_json(File.read(FilePath))
      else
        data = self.new
        data.save
        data
      end
    end
  end
end
