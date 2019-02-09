# Yuri gazes into the fire, as he searches the fast archives of his mind for...
require 'glossa'
require_relative "./entity"

class Archives

    def initialize host

        @entity_types = {}
        Dir.entries("#{host.path}/memory/entity_types").each do |file|
            if file == "." || file == ".." then next end
            name = file.sub(".mh", "")
            @entity_types[name.to_sym] = Memory_Hash.new("entity_types/#{name}", host.path)
        end

    end

    def create type, options

        raise "#{type} is not a valid entity type. You should create one." unless @entity_types[type]

        return Entity.new(@entity_types[type], options)

    end


end
