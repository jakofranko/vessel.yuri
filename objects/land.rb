require_relative "./entity"

class Land < Entity

    def initialize options
        @type = "Land"
        @adjectives = ['', 'verdant', 'sparse', 'desert', 'arctic', 'cursed', 'unknown']
        @child_max = 5
        @child_types = {
            :Forest => {
                :name => false,
                :inherit_language => true,
                :name_self => false,
            },
            :River => {
                :name => false,
                :inherit_language => true,
                :name_self => false,
            },
            :Mountains => {
                :name => false,
                :inherit_language => true,
                :name_self => false,
            },
            :Swamp => {
                :name => false,
                :inherit_language => true,
                :name_self => false,
            },
        }
        @child_prepositions = {
            :Forest => [
                'In the north of %s',
                'In the east of %s',
                'In the south of %s',
                'In the west of %s',
                'In the northeast of %s',
                'In the northwest of %s',
                'In the southeast of %s',
                'In the southwest of %s',
            ],
            :River => [
                'In the north of %s',
                'In the east of %s',
                'In the south of %s',
                'In the west of %s',
                'In the northeast of %s',
                'In the northwest of %s',
                'In the southeast of %s',
                'In the southwest of %s',
            ],
            :Mountains => [
                'In the north of %s',
                'In the east of %s',
                'In the south of %s',
                'In the west of %s',
                'In the northeast of %s',
                'In the northwest of %s',
                'In the southeast of %s',
                'In the southwest of %s',
            ],
            :Swamp => [
                'In the north of %s',
                'In the east of %s',
                'In the south of %s',
                'In the west of %s',
                'In the northeast of %s',
                'In the northwest of %s',
                'In the southeast of %s',
                'In the southwest of %s',
            ],
        }

        super

    end

end