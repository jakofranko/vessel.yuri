# Yuri gazes into the fire, as he searches the vast archives of his mind for...
require_relative "./entity"

class Archives

    def initialize host

        @entity_types = {}
        Dir.entries("#{host.path}/memory/world_generation/entity_types").each do |file|
            if file == "." || file == ".." then next end
            name = file.sub(".mh", "")
            @entity_types[name.to_sym] = Memory_Hash.new("world_generation/entity_types/#{name}", host.path).to_h
        end

    end

    def create type, options

        raise "#{type} is not a valid entity type. You should create one. Valid entity types are #{@entity_types}" unless @entity_types[type]

        return Entity.new(@entity_types[type], options)

    end

    def get attributes, options = {}

        return Entity.new(attributes, options)

    end


end
