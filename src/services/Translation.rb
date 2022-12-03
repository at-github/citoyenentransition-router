class Translation
  def initialize(translations)
    @translations = translations
    STDOUT.puts translations
  end

  def translate(term)
    translated = @translations.key(term)

    return term if !translated
    translated
  end

  def untranslate(term)
    STDOUT.puts term
    return @translations[term] ? @translations[term] : term
  end

  def translate_slug(path)
    # page
    result = /^\/([a-z]+)\/.*$/.match(path)
    # folder
    result = /^\/([a-z]+)$/.match(path) if !result

    return path if !result

    slug, = result.captures
    slugTranslated = @translations.key(slug)

    return path if !slugTranslated

    path.gsub(slug, slugTranslated)
  end
end
