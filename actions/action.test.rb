class ActionTest

  include Action

  def initialize q = nil

    super

    @name = "Test"
    @docs = "For testing output (currently for testing the tweet payload without actually sending it)"

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

  def act q = nil

    q = q == "" ? nil : q

    # puts "--- NEW WORLD ---"
    # language = Glossa::Language.new(true)
    # language_id = $languages.add(language)
    # world = $archives.create(:world, {:name_self => true, :language_id => language_id, :language => language})
    # puts world.describe
    # $entities.add(world, true)

    # puts "\n--- ENTITY FROM MEMORY ---"
    # entity = $entities.get(2)
    # puts entity.describe
    #
    # puts "\n--- ENTITY FROM MEMORY W/ CHILDREN ---"
    # continent = $entities.get(7, true) # with children
    # puts continent.describe

    # puts "---RENDER---"
    # puts $languages.render

    # puts "--- GOT LANG ---"
    # lang = $languages.get q
    # puts lang.make_name("strange")
    # $languages.save

    # $languages.update(q, lang)

    # character = Character.new({:language_id => q, :location_id => 13})
    # puts character.describe
    # $characters.add(character)

    # puts "\n--- ARCS ---"
    # puts $arcs.inspect
    #
    # puts "\n--- SCENES ---"
    # puts $scenes.inspect

    puts "\n--- NEW STORY ---"
    # Create a new story
    story = Story.new

    # Save story
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

    puts story.summary
    puts "\nThe story's arcs are:\n"

    # Save Arcs
    story.arcs.each_index do |i|
        arc = story.arcs[i]
        puts arc.text
        puts "and then"
        $story_arcs.add(arc, story_id, i)
    end

    puts "\nThe scenes in order of each arc are:\n"
    # Save Scenes
    if story.arc_scenes.length > 0 then
        story.arc_scenes.each {|arc_template_id, scenes|
            scene_arc = $story_arcs.get_by_template_id(arc_template_id, story_id).first
            scenes.each {|scene|
                $story_arc_scenes.add(scene_arc["ID"], scene.time, scene.action, scene.setting, scene.order)
                puts scene.describe
            }
        }
    else
        puts "no scenes"
    end


    return ""

  end

end
