require_relative "./entity"

class World < Entity

    def initialize name, name_self = false, language = Glossa::Language.new(true)
        @type = "World"
        @adjectives = ['', 'blue', 'green', 'verdant', 'dark', 'evil']
        @verbs = ['', '', '', '', 'swirling with chaos']
        @adverbs = ['', '', '', '', 'violently']
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
            :Continent => [
                'On %s', 'Sprawling across the southern hemisphere of %s',
                'Sprawling across the northern hemisphere of %s',
                'Spread out upon the northern hemisphere of %s',
                'Spread out upon the southern hemisphere of %s'
            ],
            :Sea => ['Spreading across %s', 'Covering %s', 'Upon the surface of %s']
        }

        # TODO: adjectives

        super

    end

end