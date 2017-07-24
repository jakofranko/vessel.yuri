require 'glossa'
require_relative './_toolkit'

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
# TODO: Handle editing entities after they have been saved to memory
# TODO: Save and load languages
class Entity
    ATTRS = [
        :id,
        :name,
        :language,
        :parent,
        :type,
        :adjective,
        :adverb,
        :verb,
        :adjectives,
        :adverbs,
        :verbs,
        :child_types,
        :child_relates,
        :child_attributes,
        :children,
        :preposition
    ]
    attr_accessor(*ATTRS)

    def initialize options

        ##
        # Validate the options
        if options.nil? || !options.is_a?(Hash)
            raise "Please specify an options hash"
        elsif options[:name] == false && options[:name_self] == false
            raise "An entity must either be given a name, or name itself"
        elsif options[:name_self] == true && (options[:language] === false || options[:language].nil?)
            raise "If an entity is naming itself, then it must have a language instance."
        end

        ##
        # These class attributes must be defined at the subclass level
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
        end

        @id          = options[:id]          ? options[:id]                          : nil
        @name        = options[:name_self]   ? options[:language].make_name(@type)   : options[:name]
        @preposition = options[:preposition] ? options[:preposition]                 : ""
        @language    = options[:language]
        @parent      = options[:parent]
        @children    = []

        # If the entity does not have an ID, add it to memory, set the new ID, and generate new children
        if @id.nil?
            @adjective = @adjectives ? choose(@adjectives) : ""
            @verb      = @verbs      ? choose(@verbs)      : ""
            @adverb    = @adverbs    ? choose(@adverbs)    : ""

            # Add the entity to the memory file
            @id = $entities.add(self)

            # Now that the entity is saved, we can safely generate new children
            generate_children

        # Otherwise, this entity is being initialized from memory, so load children?
        else
            @adjective = options[:adjective] ? options[:adjective] : ""
            @verb      = options[:verb]      ? options[:verb]      : ""
            @adverb    = options[:adverb]    ? options[:adverb]    : ""
        end

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
    # This function will create a random number of children
    # that is less than the max number of children. Their names will be
    # what their type is, and will inherit the language of it's parent.
    # Optionally, a name can be created for the child if the parent has
    # a language defined.
    # Optionally, a child can have a new language generated for itself
    def generate_children
        num_children = rand(@child_max)
        num_children.times do
            # Pick a child type, options and preposition
            child_type = choose(@child_types.keys)
            self.add_child(child_type)
        end
    end

    def add_child type

        raise "#{type} is not a valid child for #{self.type}" if !@child_types[type]

        child_options = @child_types[type]
        preposition = choose(@child_prepositions[type])

        # Given the child_type's options, set the name
        child_name = nil
        if child_options[:name] == false || child_options[:name_self] == true
            child_name = "#{type}"
        else
            child_name = @language.make_name(type)
        end

        if Kernel.const_defined? type
            entity = Object.const_get(type)
            options = {
                :name => child_name,
                :name_self => child_options[:name_self],
                :preposition => preposition,
                :parent => self
            }

            if child_options[:inherit_language]
                options[:language] = @language
            else
                options[:language] = Glossa::Language.new(true)
            end

            child = entity.new(options)
        else
            child = child_name
            child.preposition = preposition
        end

        @children.push(child)
    end

    def describe
        sentence = ""

        article = (@adjective && !@adjective.empty?) ? @adjective.article : @type.article
        adj = (@adjective && !@adjective.empty?) ? @adjective : ""
        if @name != @type
            sentence << "#{@name}, #{article} #{adj} #{@type.downcase}"
        elsif
            sentence << "#{article.capitalize} #{adj} #{@type.downcase}"
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
            if c.is_a? String
                # Since this is likely a generic name like 'Forest', we can add an article
                child_name = c.with_article.downcase
                to_be = c.article.empty? ? "are" : "is"
            else 
                child_name = c.describe
                to_be = "is"
            end

            sentence << " " + c.preposition % @name + " #{to_be} #{child_name}."
        end

        # Filter out all multiple periods and spaces from nested children
        sentence.gsub(/\.{2,}/, '.').gsub(/\s{2,}/, ' ')
    end

end