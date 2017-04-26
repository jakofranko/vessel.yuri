require 'glossa'

##
# Entities are the parent class for all elements of a story: places, regions, people, things, etc.
# An entity is defined by mainly by its own adjectives, and the type of children it can have. 
# An Entity's primary purpose is to describe itself and its children, and contains the logic for 
# procedurally generating its own children. Each child in turn is also an entity. Example:
#
# A Region is an sub-class of Entity. A region can have children of type 'forest', 'river', 'city',
# 'mountains', 'hills', 'desert'. Every one of these types can relate to the parent like 'to/in 
# the south', 'to/in the north' etc. Each one of the children can have different attributes depending
# on type. Forests can be 'sparse', 'verdant', 'coniferous', 'brooding' etc. Hills can be 'rolling', 
# 'squat', 'towering', 'bare' etc.
#
# TODO: child adjectives (like prepositions)
class Entity

    attr_accessor :name, :type, :adjective, :adverb, :verb, :adjectives, :adverbs, :verbs, :child_types, :child_relates, :child_attributes, :children

    def initialize name, name_self = false, language = Glossa::Language.new(true)

        ##
        # @child_types should be a hash, with the keys of the hash being the child types, and the value
        # of each type being a hash with the following options (with bool vals): :name, :inherit_language, :name_self 
        if @child_types.nil?
            raise "Please specify the types of children this Entity can have (@child_types)"
        elsif @child_prepositions.nil?
            raise "Please specify a hash of prepositions like: {:type => ['Next to \%s', 'Beneath \%s']} (@child_prepositions)\n\n
            Note: actually include the \%s's; the entity's name will be substituted there"
        elsif @child_max.nil?
            raise "Please specify a maximum number of children this entity can have (@child_max)"
        elsif @type.nil?
            raise "Please specify the entity's type (@type)"
        elsif name_self == true && language === false
            raise "If an entity is naming itself, then you must give it a language"
        end     
                
        @name = name_self ? language.make_name(@type) : name
        @adjective = @adjectives ? choose(@adjectives) : false
        @verb = @verbs ? choose(@verbs) : false
        @adverb = @adverbs ? choose(@adverbs) : false
        @language = language
        @children = generate_children
    end

    ##
    # Takes an array and picks a semi-random element, with the first
    # elements weighted more frequently the the last elements by using
    # the power of a given exponent.
    def choose(list, exponent = 2)
        list_index = ((rand ** exponent) * list.length).floor

        list[list_index]
    end

    ##
    # By default, this function will create a random number of children
    # that is less than the max number of children. Their names will be
    # what their type is, and will inherit the language of it's parent.
    # Optionally, a name can be created for the child if the parent has
    # a language defined.
    # Optionally, a child can have a new language generated for itself
    def generate_children new_name = false, inherit_language = true
        children = []
        num_children = rand(@child_max)
        num_children.times do
            # Pick a child type, options and preposition
            child_type = choose(@child_types.keys)
            child_options = @child_types[child_type]
            preposition = choose(@child_prepositions[child_type])

            # Given the child_type's options, set the name
            child_name = nil
            if child_options[:name]
                child_name = @language.make_name(child_type)
            else
                child_name = "#{child_type}"
            end

            if Kernel.const_defined? child_type
                entity = Object.const_get(child_type)
                params = []
                params.push(child_name)
                params.push(child_options[:name_self])
                params.push(@language) if child_options[:inherit_language]

                child = entity.new(*params)
            else
                child = child_name
            end
            children.push({:preposition => preposition, :child => child})
        end

        children
    end

    def describe
        sentence = ""

        if @adjective && !@adjective.empty?
            article = /^[aeiouAEIOU]/ =~ @adjective ? 'an' : 'a'
            if @name != @type
                sentence << "#{@name}, #{article} #{@adjective} #{@type}"
            elsif
                sentence << "#{article.capitalize} #{@adjective} #{@name}"
            end
        else
            sentence << "#{@name}"
        end

        if @verb && !@verb.empty?
            if @adverb && !@adverb.empty?
                sentence << ", #{@adverb} #{@verb}"
            else
                sentence << ", #{@verb}"
            end
        end

        sentence << "."

        @children.each do |c|
            child_name = (c[:child].is_a? String) ? c[:child] : c.name
            sentence << " " + c[:preposition] % @name + " is #{child_name}."
        end

        sentence
    end

end