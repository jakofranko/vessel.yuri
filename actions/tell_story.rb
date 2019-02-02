class ActionTellStory

    include Action

    attr_accessor :active_story

    def initialize q = nil

        super

        @name = "Tell Story"
        @docs = "Output a tweet-sized sentence from a current or new story"
        # @active_story = get_active_story || new_story

    end

    ##
    # The general sequence of telling stories will be thus:
    # 1. If there is an active scene, tell the next part
    # 2. Else, if generate the next scene in the arc, if there is an active arc
    # 3. Else, generate the next arc if there is an active story
    # 4. Else, generate a new story with an existing character, or chance to create new character
    # 5. If creating a new character, put them in an existing setting, with a chance of creating a new setting, with an every decreasing chance of creating a new parent setting. Example: we are creating a new character and decide to place him in a 'city' type setting. Roll to create a new city. If creating a new city, roll to create a new country at a much decreased chance. If we create a new country, roll to create a new continent at a much further decreased chance. If creating a new continent, chance to create a completely new world.
    def act q = nil

        load_folder("#{@host.path}/objects/*")

        current_arc = @active_story.get_current_arc || @active_story.new_arc
        current_scene = current_arc.get_current_scene || current_arc.new_scene

        current_scene.describe

    end

    def get_active_story

        # TODO return a story instance from a memory of stories
        
    end
    
end