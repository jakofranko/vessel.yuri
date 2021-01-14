class Scene

    ATTRS = [
        :id,
        :order,
        :time,
        :location,
        :setting,
        :action
    ]
    attr_accessor(*ATTRS)

    ##
    # Scenes will be generated from scene templates.
    # Settings and actions will be generated from text templates.
    # Time is a description of when the thing happened.
    # E.g., About mid-morning, while the merchants were selling their wares, a meteor fell from the sky.
    def initialize scene
        @id = scene["ID"]
        @order = scene["ORDER"]
        @time = scene["TIME"]
        @location = get_location
        @setting = scene["SETTING"]
        @action = scene["ACTION"]
    end

    def get_time



    end

    def get_location



    end

    def generate_setting



    end

    def generate_action



    end

    def describe

        "#{@time.capitalize}, #{@setting.downcase}, #{@action.downcase}"

    end


end
