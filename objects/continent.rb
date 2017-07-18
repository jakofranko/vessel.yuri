require_relative "./entity"

class Continent < Entity

    def initialize options
        @type = "Continent"
        @adjectives = ['', 'large', 'small', 'medium']
        @child_max = 5
        @child_types = {
            :Land => {
                :name => true,
                :inherit_language => false,
                :name_self => true,
            }
        }
        @child_prepositions = {
            :Land => [
                'In the north of %s',
                'In the east of %s',
                'In the south of %s',
                'In the west of %s',
                'In the northeast of %s',
                'In the northwest of %s',
                'In the southeast of %s',
                'In the southwest of %s',
            ]
        }

        super

    end

end