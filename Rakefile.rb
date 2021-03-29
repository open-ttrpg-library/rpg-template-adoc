=begin
Adapted from https://gist.github.com/mojavelinux/8b27b77fc2ad5745173c93b5a7163a12
=end

MASTER_FILENAME='index.adoc'
BUILD_DIR='build'
autoload :FileUtils, 'fileutils'

desc 'Build the HTML5 format'
task :html do
  out_dir = File.join BUILD_DIR, 'html'
  ((FileList.new '**/*.{jpg,png,svg}').exclude %(#{BUILD_DIR}/**/*)).each do |img_path|
    target_dir = File.join out_dir, (File.dirname img_path)
    FileUtils.mkdir_p target_dir
    FileUtils.cp img_path, target_dir
  end
  require 'asciidoctor'
  Asciidoctor.convert_file MASTER_FILENAME,
    safe: :unsafe,
    to_dir: out_dir,
    mkdirs: true
end

desc 'Build the PDF format'
task :pdf do
  require 'asciidoctor-pdf'
  Asciidoctor.convert_file MASTER_FILENAME,
    safe: :unsafe,
    backend: 'pdf',
    to_dir: BUILD_DIR,
    mkdirs: true
end

# TIP invoke using epub[ebook-validate] to validate
desc 'Build the EPUB3 format'
task :epub, [:attrs] do |_, args|
  require 'asciidoctor-epub3'
  Asciidoctor.convert_file MASTER_FILENAME,
    safe: :unsafe,
    backend: 'epub3',
    attributes: [args[:attrs]].compact * ' ',
    to_dir: BUILD_DIR,
    mkdirs: true
end

desc 'Build all formats'
task default: [:html, :epub, :pdf]

desc 'Clean the build directory'
task :clean do
  ['index.pdf', 'index.epub', 'html'].each do |name|
    path = File.join BUILD_DIR, name
    FileUtils.remove_entry_secure path if File.exist? path
  end
end
