require 'glossa'
require_relative '../../../memory.rb'
require_relative './_toolkit'

# TODO: Support saving empty strings to memory_hash by passing in the string "BLANK" and convert "BLANK" to empty string ""
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
        content = ""
        spacer = " " * (depth * 2)
        if key == "" then key = "BLANK" end
        content += spacer + "#{key}"
        if values.kind_of?(Array)
            values.each do |val|
                content += "\n" + spacer + "  #{val}"
            end
        elsif values.kind_of?(String)
            content += " : #{values}"
        elsif values.kind_of?(Hash)
            values.each do |k, v|
                content += "\n" + stringify_hash(k, v, depth + 1)
            end
        end
        content
    end

    def make_build id

        if !@tree[id] then return end 
        parent = @lines[id].last.strip

        t = {}

        @tree[id].each do |id|
            child = @lines[id].last.strip
            value = make_build(id)
            if value != nil
                if !t.kind_of?(Hash) 
                    puts t.inspect
                    abort("NOT HASH")
                end
                t[child] = value 
              else
                if t.kind_of?(Hash)
                    if child.include?(" : ")
                        t[child.split(" : ").first.strip] = child.split(" : ").last.strip
                    # Check to see if the child ends like "foo :" and if it does, set it to an empty string
                    elsif child.include?(" :") && /\s\:$/ =~ child
                        t[child.split(" :").first.strip] = ""
                    # If child doesn't have a value (doesn't match the pattern " : "), 
                    # or an empty value (doesn't match the pattern " :")
                    # attempt to turn t into an array. Otherwise add it to the existing tree
                    elsif t.empty?
                        t = []
                        t.push(child)
                    else
                        t[child] = ""
                    end
                elsif t.kind_of?(Array)
                    t.push(child)
                end
            end
        end

        return t

    end

    # def get id

    #     # TODO

    # end

    # def filter field, value, type

    #     # TODO

    # end


end