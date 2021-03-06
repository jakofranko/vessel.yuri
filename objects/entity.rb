require 'glossa'
require_relative './_toolkit'

##
# Entities are the parent class for all elements of a story: places, regions, people, things, etc.
# An entity is defined by its own adjectives, and the type of children it can have.
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

    ATTRS ||= [
        :ID,
        :NAME,
        :TYPE,
        :ADJV,
        :ADVB,
        :VERB,
        :CMAX,
        :CTPS,
        :PREP,
        :LANG,
        :LANG_ID,
        :PRNT,
        :CHLD,
    ]
    attr_accessor(*ATTRS)

    ##
    # The attributes param should reflect EITHER 1) the standard entity template found in all of the
    # entity_types files, or 2) all data found in a row in the `entities` memory.
    # The options param should contain config options only used when creating a truly new entity.
    def initialize attributes, options = {}

        validate(attributes, options)

        # TODO: cleanup unused instance variables
        @ID   = attributes["ID"] ? attributes["ID"] : nil
        @P_ID = attributes["P_ID"]
        @LANG_ID = attributes["LANG_ID"] || options[:language_id]
        @TYPE = attributes["TYPE"]
        @CMAX = attributes["CMAX"].to_i
        @CTPS = attributes["CTPS"]
        @CPRP = attributes["CPRP"]
        @NAME = options[:name_self] ? options[:language].make_name(@TYPE) : options[:name]
        @PREP = options[:prep] ? options[:prep] : ""

        @LANG = (@LANG_ID && !options[:language]) ? $languages.get(@LANG_ID) : options[:language]
        @PRNT = options[:parent]
        @CHLD = []

        # If the entity does not have an ID, this is a new entity
        # and its children will also need to be generated
        if @ID.nil?
            @ADJV = attributes["ADJV"] && attributes["ADJV"].length ? choose(attributes["ADJV"]) : ""
            @VERB = attributes["VERB"] && attributes["VERB"].length ? choose(attributes["VERB"]) : ""
            @ADVB = attributes["ADVB"] && attributes["ADVB"].length ? choose(attributes["ADVB"]) : ""

            generate_children

        # Otherwise, this entity is being initialized from memory, so load children
        else
            @ADJV = options[:ADJV] ? options[:ADJV] : ""
            @VERB = options[:VERB] ? options[:VERB] : ""
            @ADVB = options[:ADVB] ? options[:ADVB] : ""
        end

    end

    ##
    # This function will create a random number of children
    # that is less than the max number of children. Their names will be
    # what their type is, and will inherit the language of it's parent.
    # Optionally, a name can be created for the child if the parent has
    # a language defined.
    # Optionally, a child can have a new language generated for itself
    def generate_children

        return unless @CMAX && @CMAX > 0

        num_children = rand(@CMAX)
        num_children.times do
            # Pick a child type, options and preposition
            type = choose(@CTPS.keys)
            options = @CTPS[type]
            options[:prep] = choose(@CPRP[type])
            options[:parent] = self
            options[:language] = @LANG

            if options[:name] == false || options[:name_self] == true
                options[:name] = "#{type}"
            else
                options[:name] = @LANG.make_name(type)
            end

            child = $archives.create(type.downcase.to_sym, options)
            @CHLD.push(child)
        end

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

        @CHLD.each do |c|
            sentence << " " + c.PREP % @NAME + " is #{c.describe}."
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
        elsif options[:name] == false && options[:name_self] == false
            raise "An entity must either be given a name, or name itself"
        elsif options[:name_self] == true && (options[:language] === false || options[:language].nil?)
            raise "If an entity is naming itself, then it must have a language instance."
        end

        ##
        # These attributes must be defined in the entity_type memory
        if type["TYPE"].nil?
            raise "Please specify the entity's type"
        end

        ##
        # If the entity has children, make sure their descriptors are set
        if !type["CMAX"].nil? && type["CMAX"].to_i > 0
            if type["CTPS"].nil?
                raise "Please specify the types of children this Entity can have"
            elsif type["CPRP"].nil?
                raise "Please specify a hash of prepositions like: {:type => ['Next to \%s', 'Beneath \%s']}\n\n
                Note: actually include the \%s's; the entity's name will be substituted there"
            end
        end

    end

end
