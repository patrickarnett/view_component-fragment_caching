class ComponentFile
  def initialize(path)
    @path = Rails.root.join(path).to_s
    load_version 1
  end

  def load_version(version)
    @version = version
    source = File.read versioned_path
    File.write path, source
  end

  def reset
    load_version 1
  end

  private

  attr_reader :original_source, :path, :version

  def versioned_path
    path_parts = path.split '.'
    path_parts.unshift "#{path_parts.shift}_v#{version}"
    path_parts.join '.'
  end
end
