require "erb"
require "foreman/export"

class Foreman::Export::Initscript < Foreman::Export::Base

  def export

    #super
    error("Must specify a location") unless location
    FileUtils.mkdir_p(location) rescue error("Could not create: #{location}")
    FileUtils.mkdir_p(log) rescue error("Could not create: #{log}")
#    begin
#      FileUtils.chown(user, nil, log)
#    rescue Exception => e
#      error("Could not chown #{log} to #{user} - #{e.message}")
#    end

    name = "initscript/master.erb"
    name_without_first = name.split("/")[1..-1].join("/")
    matchers = []
    matchers << File.join(options[:template], name_without_first) if options[:template]
    matchers << File.expand_path("~/.foreman/templates/#{name}")
    matchers << File.expand_path("../../../../data/export/#{name}", __FILE__)
    path = File.read(matchers.detect { |m| File.exists?(m) })
    compiled = ERB.new(path).result(binding)

    if location == "-"
      puts compiled
    else
      write_file "#{app}", compiled
      FileUtils.chmod(755, "#{app}")
    end
#    path = export_template name
#    write_template "initscript/master.erb", "#{app}", binding
  end

  def app_path
    options[:app_path] || engine.root
  end

end

