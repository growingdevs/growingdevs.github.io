require "erb"

class Post < Thor
  include Thor::Actions

  desc "create [TITLE]", "Create a new blog post"
  def create(title)
    puts "Generating blog post: #{title}"

    md = ERB.new(File.read('./tasks/templates/post.erb')).result(binding)

    file = "_posts/" + [short_date, title.downcase.gsub(/\W+/, '-')].join('-') + '.md'

    exists = File.exists?(file)
    overwrite = yes? "Do you want to overwrite #{file}?" if exists

    if !exists || overwrite
      File.open(file, 'w') {|f| f.write(md)}
      `$EDITOR #{file}`
    else
      puts "Not going to overwrite #{file}. Move it, or try a different title."
    end
  end

  no_tasks {
    def full_date
      DateTime.now.strftime('%F %T.%6N %:z')
    end

    def short_date
      DateTime.now.strftime('%F')
    end
  }
end
