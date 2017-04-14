class ActionTellStory

    include Action

    attr_accessor :active_story

    def initialize q = nil

        super

        @name = "Tell Story"
        @docs = "Output a tweet-sized sentence from a current or new story"
        @active_story = get_active_story || new_story

    end

    def act q = nil

        load_folder("#{@host.path}/objects/*")

        current_arc = @active_story.get_current_arc || @active_story.new_arc

        current_scene = current_arc.get_current_scene || current_arc.new_scene

        current_scene.describe

    end

    def get_active_story

    end

    def new_story 

    end
    
    def get_current_arc 

    end
    
    def new_arc 

    end
    
    def get_current_scene 

    end
    
    def new_scene 

    end
    
    def describe 

    end
    
end