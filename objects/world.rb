require_relative "./entity"

class World < Entity

    @type = "World"
    @child_max = 8
    @child_types = {
        :Continent => {
            :name => false,
            :inherit_language => false,
            :name_self => true,
        },
        :Sea => {
            :name => false,
            :inherit_language => false,
            :name_self => true,
        }
    }
    @child_prepositions = {
        :Continent => ['On %s'],
        :Sea => ['On %s']
    }

    def initialize name, name_self = false, language = Glossa::Language.new(true)

       super

    end

end