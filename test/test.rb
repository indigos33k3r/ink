require 'colorator'

has_failed = false

def test(file, dir)
  if diff = diff_file(file, dir)
    puts "Failed #{file}".red
    puts diff
    has_failed = true
  else
    puts "Passed #{file}".green
  end
end

def build(config='')
  config = ['_config.yml'] << config
  `rm -rf site && bundle exec jekyll build --config #{config.join(',')}`
end

def diff_file(file, dir='expected')
  if File.exist?(Dir.glob("site/#{file}").first)
    diff = `diff #{dir}/#{file} site/#{file}`
    if diff.size > 0
      diff
    else
      false
    end
  else
    "File: site/#{file}: No such file or directory."
  end
end

build

def test_tags(dir)
  tags = %w{content_for footer head include include_plugin include_theme include_theme_override scripts}
  tags.each { |file| test("tag_tests/#{file}.html", dir) }
end

def test_layouts(dir)
  layouts = %w{local plugin_layout theme theme_override}
  layouts.each { |file| test("layout_tests/#{file}.html", dir) }
end

def test_stylesheets(dir, concat_css=true)
  if concat_css
    stylesheets = %w{all-* print-*}
    stylesheets.each { |file| test("stylesheets/#{file}.css", dir) }
  else
    local_stylesheets = %w{site test}
    local_stylesheets.each { |file| test("stylesheets/#{file}.css", dir) }

    plugin_stylesheets = %w{plugin-media-test plugin-test}
    plugin_stylesheets.each { |file| test("awesome-sauce/stylesheets/#{file}.css", dir) }

    theme_stylesheets = %w{theme-media-test theme-test theme-test2}
    theme_stylesheets.each { |file| test("theme/stylesheets/#{file}.css", dir) }
  end
end

test_tags('expected')
test_layouts('expected')
test_stylesheets('concat_css')

build '_concat_css_false.yml'
test_stylesheets('concat_css_false', false)

build '_sass_compact.yml'
test_stylesheets('sass_compact')

build '_sass_expanded.yml'
test_stylesheets('sass_expanded')

abort if has_failed
