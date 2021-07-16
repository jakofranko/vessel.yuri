class ActionStory

    include Action

    attr_accessor :active_story

    def initialize q = nil

        super

        @name = "Story"
        @docs = "Output a tweet-sized sentence from a current or new story"
        @active_story = nil

        $archives ||= Archives.new(@host)
        $current_story ||= CurrentStory.new("stories/current_story", @host.path)

        # Generated memories
        $stories ||= StoryMemory.new("stories/stories", @host.path)
        $story_arcs ||= StoryArcMemory.new("stories/story_arcs", @host.path)
        $story_arc_scenes ||= StoryArcSceneMemory.new("stories/story_arc_scenes", @host.path)

        # World Building memories
        $entities ||= EntityMemory.new("world_generation/entities", @host.path)
        $languages ||= LanguageMemory.new("world_generation/languages", @host.path)

        # Template memories
        $tags ||= Memory_Array.new("story_templates/tags", @host.path)
        $summaries ||= Memory_Array.new("story_templates/summaries", @host.path)
        $arcs ||= ArcMemory.new("story_templates/arcs", @host.path)
        $scenes ||= SceneMemory.new("story_templates/scenes", @host.path)
        $story_entities ||= StoryEntityMemory.new("stories/story_entities", @host.path)
        $item_names ||= ItemNameMemory.new("story_templates/item_names", @host.path)

    end

    ##
    # The general sequence of telling stories will be thus:
    # 1. If there is an active scene, tell the next part
    # 2. Else, if there is an active arc, generate the next scene in the arc
    # 3. Else, if there is an active story, generate the next arc
    # 4. Else, generate a new story with an existing character, or chance to create new character
    # 5. If creating a new character, put them in an existing setting, with a chance of creating a new setting, with an every decreasing chance of creating a new parent setting. Example: we are creating a new character and decide to place him in a 'city' type setting. Roll to create a new city. If creating a new city, roll to create a new country at a much decreased chance. If we create a new country, roll to create a new continent at a much further decreased chance. If creating a new continent, chance to create a completely new world.
    def act q = nil

        load_folder("#{@host.path}/objects/*")

        puts @active_story.inspect

        # Only set this the first time. Once it's in memory, we'll use that.
        @active_story ||= get_active_story || new_story


        # If just starting the server, there will be no current arcs or scenes
        # in memory, so we need to load them from our data store, and then set
        # them. Then, once Nataniev is running and subsequent calls to the `act`
        # method are called, we can manage things in memory while making updates
        # to the data store. PS, I like the idea of calling them "tablets" ? In
        # my new reskinned version of Nataniev that is.
        # current_arc needs to be called before current_scene because current_arc
        # will handle loading the current_scenes attribute which is what current_scene
        # references when checking to see what is current.
        current_story = $current_story.to_h
        current_arc = @active_story.get_current_arc
        current_scene = @active_story.get_current_scene

        if current_story["CURRENT_STORY"]["LAST_SCENE"] && current_story["CURRENT_STORY"]["LAST_SCENE"]["TEXT"] == current_scene.describe then
            @active_story.current_scene = nil
            current_scene = @active_story.get_current_scene
        end

        # This will allow plain text to be substituted if a scene doesn't exist
        scene_text = current_scene.respond_to?(:describe) ? current_scene.describe : current_scene.to_s

        # Update the current story memory with the new
        # values as set by the current_arc and current_scene functions
        update_current_story(scene_text)

        # Now that the scene text has been captured, nil it out so that
        # get_current_scene can cycle in a new one the next time it's called.



        puts scene_text
    end

    def get_active_story

        story = $current_story.to_h["CURRENT_STORY"]
        if story == "NULL" then
            return nil
        else
            return $stories.get(story["ID"])
        end

    end

    def new_story

        # Create new story
        story = Story.new

        # Save story in a new memory
        story_id = $stories.add(story.world.ID, story.summary)
        story.id = story_id

        # Loop through all of the entities that have been generated
        # from the tags in the summaries, arcs and scenes, and save them.
        story.tag_map.each do |tag, entity|
            if entity.ID.nil? then
                entity_id = $entities.add(entity)
                entity.ID = entity_id
                $story_entities.add(entity, {:story_id => story_id})
            else
                # TODO: will only happen once stories can use existing story_entities
                # Only need to update the character entry since we are using an existing entity
                $story_entities.update(entity.id, { story_id: story_id})
            end
        end

        # Save Arcs
        story.arcs.each_index do |i|
            arc = story.arcs[i]
            story_arc_id = $story_arcs.add(arc, story_id, i)

            # When the arcs were generated in story initialization,
            # the generated arcs retained their template IDs. They must
            # now be set to reflect their "rendered" story_arc ID so that
            # they can be properly fetched when getting the current arc.
            arc["ID"] = story_arc_id
        end

        # Save Scenes
        if story.arc_scenes.length > 0 then
            story.arc_scenes.each {|arc_template_id, scenes|
                scene_arc = $story_arcs.get_by_template_id(arc_template_id, story_id).first
                scenes.each {|scene|
                    $story_arc_scenes.add(scene_arc["ID"], scene.time, scene.action, scene.setting, scene.order)
                }
            }
        end

        # Now that the arc IDs have been updated, get and set the current arc
        story.get_current_arc

        # Set the current story to the newly created story
        current_story = {}
        current_story["ID"] = story.id
        current_story["WORLD_ID"] = story.world.ID
        current_story["SUMMARY"] = story.summary
        current_story["CURRENT_ARC"] = story.current_arc["ID"]
        $current_story.render["CURRENT_STORY"] = current_story
        $current_story.save

        story

    end

    def update_current_story scene_text

        story = $current_story.render["CURRENT_STORY"]

        if story == "NULL" then story = {} end
        if story["ID"].nil? then story["ID"] = @active_story.id end
        if story["WORLD_ID"].nil? then story["WORLD_ID"] = @active_story.world.ID end
        if story["SUMMARY"].nil? then story["SUMMARY"] = @active_story.summary end
        if story["CURRENT_ARC"].nil? then story["CURRENT_ARC"] = @active_story.current_arc["ID"] end
        if story["LAST_SCENE"].nil? then story["LAST_SCENE"] = {} end

        # If an arc has no scenes created for it yet, then it could just be the arc text
        if @active_story.current_scene && active_story.current_scene.kind_of?(String) == false then
            story["LAST_SCENE"]["ID"] = @active_story.current_scene.id
        else
            story["LAST_SCENE"].delete("ID")
        end
        story["LAST_SCENE"]["TEXT"] = scene_text

        $current_story.save

    end
end
