require 'jekyll'
require 'jekyll-contentful-data-import'
require 'rich_text_renderer'
require 'down'
require 'fileutils'
require './_plugins/mappers/my_custom_renderer.rb'

namespace :contentful do
  ASSETS_IMAGES_DIR="./assets/images/contentful"
    

  desc "Import data from Contentful"
  task :content do
    Jekyll::Commands::Contentful.process([], {}, Jekyll.configuration['contentful'])
  end

  desc "Generate blog posts"
  task :process_posts do
  	require 'yaml'
    require 'fileutils'

    output_dir = "./_posts"
    FileUtils::mkdir_p(output_dir)
    renderer = RichTextRenderer::Renderer.new('embedded-entry-block' => AssetRenderer, 'embedded-asset-block' => AssetRenderer)

    POSTS_DIR='./_posts'
    FileUtils.rm_rf(POSTS_DIR)
    FileUtils.mkdir_p(POSTS_DIR)
  	Dir.glob('./_data/contentful/blogPosts/blogPost/*.yaml') do |file|
      post = YAML.load_file(file)
      publish_date = post['publish_date'] ? post['publish_date'].to_date : post['sys']['created_at'].to_date
      jekyll_filename = "#{publish_date}-#{slugify(post['title'])}.html"

      puts "Generating #{jekyll_filename} from #{file}"

      open("#{POSTS_DIR}/#{jekyll_filename}", 'w') do |f|
  	    f.puts "---"
        f.puts "layout: post"
        f.puts "title: \"#{post['title']}\""
        if (post['tags'] && !post['tags'].empty?) then
          f.puts "tags: #{post['tags']}"
        end
        if post['illustration'] then
          image_filename = post['illustration']['url'].split('/')[-1]
          f.puts "image: #{ASSETS_IMAGES_DIR}/#{image_filename}"
        end
        f.puts("sticky: " + (post['sticky'].nil? ? 'false' : post['sticky'].to_s))
        f.puts "---"
        f.puts renderer.render(post['body'])
  	  end
  	end
  end

  desc "Generate jekyll data from contentful assets"
  task :assets do 
    require 'contentful'
    require 'fileutils'

    client = Contentful::Client.new(
      space: ENV["CONTENTFUL_SPACE_ID"],
      access_token: ENV["CONTENTFUL_ACCESS_TOKEN"]
    )
    assets = client.assets
    FileUtils.mkdir_p(ASSETS_IMAGES_DIR)

    yaml = Array.new
    assets.each do | asset |
      puts "Processing image #{asset.fields[:file].file_name} (#{asset.fields[:title]})"
      image = Hash.new
      image['url'] = asset.url
      image['thumb_url'] = asset.url(format: 'jpg', fit: "thumb", width: 200, height: 200)
      image['title'] = asset.fields[:title]
      image['description'] = asset.fields[:description]
      yaml.push(image)
      tempfile = Down.download("https:#{asset.url}")
      FileUtils.mv(tempfile, "#{ASSETS_IMAGES_DIR}/#{tempfile.original_filename}")
    end

    output_dir = "./_data/contentful/blog/assets"
    FileUtils::mkdir_p(output_dir)

    # Write the array of images to a single yaml file
    open("#{output_dir}/assets.yaml", 'w') { |f|
      f.puts yaml.to_yaml
    }
  end

  desc "Generate blog post content, image content"
  task :all => ["contentful:content", "contentful:process_posts", "contentful:assets"]
end

def slugify str
  str.ljust(100)
    .strip
    .downcase
    .gsub(' ', '-')
    .gsub(/[^\w-]/, '')
    .gsub(' ', '-')
    .gsub('_', '-')
end