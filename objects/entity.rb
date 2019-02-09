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
        :ID,
        :NAME,
        :language,
        :parent,
        :type,
        :ADJV,
        :ADVB,
        :VERB,
        :adjectives,
        :adverbs,
        :verbs,
        :CTPS,
        :child_relates,
        :child_attributes,
        :children,
        :PREP
    ]
    attr_accessor(*ATTRS)

    def initialize attributes, options

        validate(attributes, options)

        # TODO: finish convertin this over to the new entity_type memory system
        # TODO: cleanup unused instance variables
        @TYPE = attributes[:TYPE]
        # If the entity does not have an ID, this is a new entity
        # and its children will also need to be generated
        if @ID.nil?
            @ADJV = attributes.ADJV.length ? choose(attributes.ADJV) : ""
            @VERB = attributes.VERB.length ? choose(attributes.VERB) : ""
            @ADVB = attributes.ADVB.length ? choose(attributes.ADVB) : ""

            # Add the entity to the memory file
            @ID = $entities.add(self)

            # Now that the entity is saved, we can safely generate new children
            generate_children

        # Otherwise, this entity is being initialized from memory, so load children
        else
            @ADJV = options[:ADJV] ? options[:ADJV] : ""
            @VERB = options[:VERB] ? options[:VERB] : ""
            @ADVB = options[:ADVB] ? options[:ADVB] : ""
        end

        @ID = options[:ID] ? options[:ID] : nil
        @NAME = options[:name_self] ? options[:language].make_name(@TYPE) : options[:name]
        @PREP = options[:prep] ? options[:prep] : ""

        @language = options[:language]
        @parent   = options[:parent]
        @children = []

    end

    ##
    # This function will create a random number of children
    # that is less than the max number of children. Their names will be
    # what their type is, and will inherit the language of it's parent.
    # Optionally, a name can be created for the child if the parent has
    # a language defined.
    # Optionally, a child can have a new language generated for itself
    def generate_children
        num_children = rand(@CMAX)
        num_children.times do
            # Pick a child type, options and preposition
            type = choose(@CTPS.keys)
            options = @CTPS[type]
            options[:prep] = choose(@CPRP[type])
            options[:parent] = self

            if options[:name] == false || options[:name_self] == true
                options[:name] = "#{type}"
            else
                options[:name] = @language.make_name(type)
            end

            child = Archives.create(type, options)
            @children.push(child)
        end
    end

    # Deprecated
    def add_child type

        raise "#{type} is not a valid child for #{self.type}" if !@CTPS[type]

        child_options = @CTPS[type]
        preposition = choose(@CPRP[type])

        # Given the child_type's options, set the name
        child_name = nil
        if child_options[:NAME] == false || child_options[:name_self] == true
            child_name = "#{type}"
        else
            child_name = @language.make_name(type)
        end

        if Kernel.const_defined? type
            entity = Object.const_get(type)
            options = {
                :NAME => child_name,
                :name_self => child_options[:name_self],
                :PREP => preposition,
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
            child.PREP = preposition
        end

        @children.push(child)
    end

    def describe
        sentence = ""

        article = (@ADJV && !@ADJV.empty?) ? @ADJV.article : @TYPE.article
        adj = (@ADJV && !@ADJV.empty?) ? @ADJV : ""
        if @NAME != @TYPE
            sentence << "#{@NAME}, #{article} #{adj} #{@TYPE.downcase}"
        elsif
            sentence << "#{article.capitalize} #{adj} #{@TYPE.downcase}"
        end

        if @VERB && !@VERB.empty?
            if @ADVB && !@ADVB.empty?
                sentence << ", #{@ADVB} #{@verb}"
            else
                sentence << ", #{@VERB}"
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

            sentence << " " + c.preposition % @NAME + " #{to_be} #{child_name}."
        end

        # Filter out all multiple periods and spaces from nested children
        sentence.gsub(/\.{2,}/, '.').gsub(/\s{2,}/, ' ')
    end

    private

    def validate type, options

        ##
        # Validate the options
        if options.nil? || !options.is_a?(Hash)
            raise "Please specify an options hash"
        elsif options[:NAME] == false && options[:name_self] == false
            raise "An entity must either be given a name, or name itself"
        elsif options[:name_self] == true && (options[:language] === false || options[:language].nil?)
            raise "If an entity is naming itself, then it must have a language instance."
        end

        ##
        # These attributes must be defined in the entity_type memory
        if type["CTPS"].nil?
            raise "Please specify the types of children this Entity can have"
        elsif type["CPRP"].nil?
            raise "Please specify a hash of prepositions like: {:type => ['Next to \%s', 'Beneath \%s']}\n\n
            Note: actually include the \%s's; the entity's name will be substituted there"
        elsif type["CMAX"].nil?
            raise "Please specify a maximum number of children this entity can have"
        elsif type["TYPE"].nil?
            raise "Please specify the entity's type"
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

end
