class Character

    def initialize data = nil

        @data = data

        if data then
            @name = data['name']
        else
            raise 'Data needs to be passed into the initializer' 
        end

    end

end