class String
    PLURAL_EXCEPTIONS = []

    # Given string x, find out if it is a x, an x, or are x
    def article
        if self.plural?
            return ""
        elsif /^[aeiouAEIOU]/ =~ self
            return "an"
        else
            return "a"
        end
    end

    def with_article
        if !self.article.empty?
            self.article + " " + self
        else
            self
        end
    end

    # Detect if a string is plural
    def plural?
        if /s$/ =~ self && PLURAL_EXCEPTIONS.include?(self) == false
            return true
        else
            return false
        end
    end

    # Special property for describing strings if they are the child of an entity
    def preposition=(val)
        @preposition = val.to_s
    end

    def preposition
        return @preposition
    end

end