# simple build file to be used locally by Sam
#
require 'pty'
require 'optparse'

images = {
  discourse: { name: 'base', tag: "omarabdul3ziz/discourse:base", extra_args: '-f slim.Dockerfile' },
  release: { name: 'base', tag: "omarabdul3ziz/discourse:release", extra_args: '-f release.Dockerfile' },
  discourse_test_build: { name: 'discourse_test', tag: "discourse/discourse_test:build", squash: false},
  discourse_dev: { name: 'discourse_dev', tag: "discourse/discourse_dev:build", squash: false },
  forum: { name: 'forum', tag: "omarabdul3ziz/forum:v2.1" },
}

def run(command)
  lines = []
  PTY.spawn(command) do |stdin, stdout, pid|
    begin
      stdin.each do |line|
        lines << line
        puts line
      end
    rescue Errno::EIO
      # we are done
    end
    Process.wait(pid)
  end

  raise "'#{command}' exited with status #{$?.exitstatus}" if $?.exitstatus != 0

  lines
end

def build(image)
  lines = run("cd #{image[:name]} && docker build . --tag #{image[:tag]} #{image[:squash] ? '--squash' : ''} #{image[:extra_args] ? image[:extra_args] : ''}")
  raise "Error building the image for #{image[:name]}: #{lines[-1]}" if lines[-1] =~ /successfully built/
end

def dev_deps()
  run("sed -e 's/\(db_name: discourse\)/\1_development/' ../templates/postgres.template.yml > discourse_dev/postgres.template.yml")
  run("cp ../templates/redis.template.yml discourse_dev/redis.template.yml")
end

if ARGV.length != 1
  puts <<~TEXT
    Usage:
    ruby auto_build.rb IMAGE

    Available images:
    #{images.keys.join(", ")}
  TEXT
  exit 1
else
  image = ARGV[0].to_sym

  if !images.include?(image)
    $stderr.puts "Image not found"
    exit 1
  end

  puts "Building #{images[image]}"
  dev_deps() if image == :discourse_dev

  build(images[image])
end
