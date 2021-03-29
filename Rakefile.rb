=begin
Adapted from https://gist.github.com/mojavelinux/8b27b77fc2ad5745173c93b5a7163a12

To use this build script, first install the bundler gem:
 $ gem install bundler
Then use the `bundle` command to install the dependencies into the project:
 $ rm -rf Gemfile.lock .bundle
   bundle config --local git.allow_insecure true
   bundle config --local build.nokogiri --use-system-libraries
   bundle --path=.bundle/gems
NOTE The gems are installed under the path .bundle/gems in the project.
Finally, run a named task using the `bundle exec rake` command:
 $ bundle exec rake pdf
You can get a list of tasks using the following command:
 $ bundle exec rake -T
=end
MASTER_FILENAME='master.adoc'
BUILD_DIR='build'
autoload :FileUtils, 'fileutils'

desc 'Build the HTML5 format'
task :html do
  # TODO move logic to images task
  ((FileList.new '**/*.{jpg,png,svg}').exclude %(#{BUILD_DIR}/**/*)).each do |img_path|
    target_dir = File.join BUILD_DIR, (File.dirname img_path)
    FileUtils.mkdir_p target_dir
    FileUtils.cp img_path, target_dir
  end
  require 'asciidoctor'
  Asciidoctor.convert_file MASTER_FILENAME,
    safe: :unsafe,
    to_dir: BUILD_DIR,
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

desc 'Build the MOBI format'
task :mobi do
  require 'asciidoctor-epub3'
  Asciidoctor.convert_file MASTER_FILENAME,
    safe: :unsafe,
    backend: 'epub3',
    attributes: 'ebook-format=kf8',
    to_dir: BUILD_DIR,
    mkdirs: true
  # NOTE remove the temporary -kf8.epub file so we don't get confused
  File.unlink %(#{BUILD_DIR}/#{File.basename MASTER_FILENAME, '.*'}-kf8.epub)
end
task kf8: :mobi

desc 'Build the EPUB3 and MOBI formats'
task ebook: [:epub, :mobi]

desc 'Build all formats'
task default: [:html, :ebook, :pdf]

desc 'Clean the build directory'
task :clean do
  FileUtils.remove_entry_secure BUILD_DIR if File.exist? BUILD_DIR
end

