class Tlog::Translator
  def initialize(language)
    @language = language
  end

  def hi
    @language == "spanish" ? "hola mundo" : "hello world"
  end
end