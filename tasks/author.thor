require "erb"

class Author < Thor
  include Thor::Actions

  desc "create [NAME] [PAGE]", "Create a new author"
  def create(name, page)
    puts "Generating an author page for: #{name} in /authors/#{page}.html"

    md = ERB.new(File.read('./tasks/templates/author.erb')).result(binding)

    file = "authors/#{page}.html"

    exists = File.exists?(file)
    overwrite = yes? "Do you want to overwrite #{file}?" if exists

    if !exists || overwrite
      File.open(file, 'w') {|f| f.write(md)}
      `$EDITOR #{file}`
    else
      puts "Not going to overwrite #{file}. Move it, or try a different page."
    end
  end
end
