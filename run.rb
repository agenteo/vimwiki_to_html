require 'uri'

def vimwiki_link_matcher(text=nil)
  any_text = '.+'
  text ||=  any_text
  /\[\[(#{text})\]\]/
end

vimwiki_directory = ENV['VIMWIKI_DIRECTORY'] || 'vimwiki'
vimwiki_valid_markdown_directory = ENV['VIMWIKI_MARKDOWN_DIRECTORY'] || '_vimwiki_valid_markdown'
vimwiki_html_directory = ENV['VIMWIKI_HTML_DIRECTORY'] || '_vimwiki_html_directory'

puts "Searching #{vimwiki_directory}..."

puts ">> Copying your wiki files..."
Dir.glob("#{vimwiki_directory}/*.md") do |vimwiki_file|
  system('mkdir', '-p', vimwiki_valid_markdown_directory)
  filename = File.basename(vimwiki_file)
  new_vimwiki_file = URI.escape(filename)
  system('cp', vimwiki_file, vimwiki_valid_markdown_directory + '/' + new_vimwiki_file)
  puts "!! Copied #{vimwiki_file} to valid URI #{vimwiki_valid_markdown_directory + '/' + new_vimwiki_file} file."
end

puts ">> Converting links from vimwiki to markdown..."
Dir.glob("#{vimwiki_valid_markdown_directory}/*.md") do |markdown_file|
  text = File.read(markdown_file)
  vimwiki_links_to_convert = text.scan(vimwiki_link_matcher).flatten
  puts "#{vimwiki_links_to_convert.count} links to convert..."
  puts vimwiki_links_to_convert.inspect
  vimwiki_links_to_convert.each do |link_name|
    link_path = URI.escape(link_name)
    new_link = "[#{link_name}](/#{link_path})"
    text.gsub! vimwiki_link_matcher(link_name), new_link
  end
  text.gsub! /^  /, ""
  text.gsub! /\t/, ""
  File.open(markdown_file, "w") {|file| file.puts text }
  puts "!! Converted links in #{markdown_file}."
end

puts ">> Converting files from markdown to html"
Dir.glob("#{vimwiki_valid_markdown_directory}/*.md") do |markdown_file|
  filename = File.basename(markdown_file, '.md') + '.html'
  system('mkdir', '-p', vimwiki_html_directory)
  system("pandoc -f markdown -t html #{markdown_file} > #{vimwiki_html_directory}/#{filename}")
  puts "!! Converted #{markdown_file} to #{filename}.html"
end

#system("rm -R #{vimwiki_valid_markdown_directory}")
puts "8-) all done!"
