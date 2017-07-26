require 'glossa'
require_relative '../../../memory.rb'
require_relative './_toolkit'

# TODO: Refactor Memory_Hash save method to support more depth for hashes
class LanguageMemory < Memory_Hash

    def add language

        if !language.is_a? Glossa::Language then return end

        # Have the language name itself (and make sure that this name doesn't already exist)
        name = language.make_name("language")
        while self.render[name]
            name = language.make_name("language")
        end

        # Loop through instance variables and put them in a Hash that can be saved via Memory_Hash
        lang_hash = {}
        language.instance_variables.each do |variable|
            lang_hash[variable.to_s[1, variable.length - 1]] = language.instance_variable_get variable
        end
        lang_hash["id"] = self.get_num_languages

        self.render[name] = lang_hash
        self.save

        # Return the new id
        lang_hash["id"]

    end

    def get_num_languages
        count = 0

        self.render.each do
            count += 1
        end

        count
    end

    def save

        # Add notes
        content = @note.join("\n")+"\n\n"

        # Create lines
        @render.sort.reverse.each do |key,values|
            content += stringify_hash(key, values, 0)
            content += "\n"
        end

        overwrite(content)

    end

    def stringify_hash key, values, depth
        spacer = " " * (depth * 2)
        content += spacer + "#{key}"
        if values.kind_of?(Array)
            values.each do |val|
                content += "\n" + spacer + "  #{val}\n"
            end
        elsif values.kind_of?(String)
            content += " : #{values}\n"
        elsif values.kind_of?(Hash)
            values.each do |k, v|
                content += stringify_hash(k, v, depth + 1)
            end
        end
    end

    # def get id

    #     # TODO

    # end

    # def filter field, value, type

    #     # TODO

    # end


end