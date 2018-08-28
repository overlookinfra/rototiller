# acceptance test rakefile tools
module RakefileTools
  def create_rakefile_on(sut, rakefile_contents)
    # using blocks for step in here causes beaker to not un-indent log
    path_to_rakefile = ""
    step "Copy rake file to SUT" do
      # bit hackish.  find name of calling file (from the stack) minus the extension
      test_name = File.basename(caller(1..1).first.split(":")[0], ".*")
      path_to_rakefile = "/tmp/Rakefile_#{test_name}_#{random_string}"

      create_remote_file(sut, path_to_rakefile,
                         rototiller_rakefile_header + rakefile_contents)
    end
    path_to_rakefile
  end

  def create_rakefile_task_segment(segment_configs)
    segment = ""
    segment_configs.each do |this_segment|
      add_type = add_env_vars(this_segment)
      if this_segment[:block_syntax]
        segment << create_block_segment(this_segment, add_type)
      else
        segment << create_hash_segment(this_segment, add_type)
      end
    end
    segment
  end

  def rototiller_rakefile_header
    "require 'rototiller'\n"
  end

  private

  # @api private
  def add_env_vars(this_segment)
    if this_segment[:type] == :env
      add_env_env(this_segment)
      "add_env"
    elsif this_segment[:type] == :option
      add_option_env(this_segment)
      "add_flag"
    elsif this_segment[:type] == :switch
      add_switch_env(this_segment)
      "add_flag"
    end
  end

  # @api private
  def add_env_env(this_segment)
    return unless this_segment[:exists]
    sut.add_env_var(this_segment[:name],
                    "#{this_segment[:name]}: env present value")
  end

  # @api private
  def add_option_env(this_segment)
    return unless this_segment[:exists]
    sut.add_env_var(this_segment[:override_env],
                    "#{this_segment[:override_env]}: env present value")
  end

  # @api private
  def add_switch_env(this_segment)
    return unless this_segment[:override_env]
    sut.add_env_var(this_segment[:override_env],
                    this_segment[:env_value])
  end

  # @api private
  def create_block_segment(this_segment, add_type)
    segment = "t.#{add_type} do |this_segment|\n"
    remove_reserved_keys(this_segment).each do |k, v|
      segment += "  this_segment.#{k} = '#{v}'\n"
    end
    segment += "end\n"
  end

  # @api private
  def create_hash_segment(this_segment, add_type)
    segment = "  t.#{add_type}({"
    remove_reserved_keys(this_segment).each do |k, v|
      segment += ":#{k} => '#{v}',"
    end
    segment += "})\n"
  end

  # thing to build a rototiller task body
  #   abstraction to make writing tests for block vs hash easy
  class RototillerBodyBuilder
    def initialize(hash_representation)
      @body = ""
      hash_representation.each do |k, v|
        @body << add_method(k, v).to_s
      end
      to_s
    end

    def add_method(method, value)
      block = ""
      if list_of_allowed_methods.include?(method.to_s) # can take a block
        analyzed = analyze(value)
        if analyzed.keep_as_hash
          block << add_method_with_hash_signature(method, value)
        else
          block << add_method_with_block_signature(method, value)
        end
      else
        block << set_param(method, value)
      end
      block
    end

    def to_s
      @body.to_s
    end


    # use as a call back to look inside nested hashes
    AnalyzedHash = Struct.new(:keep_as_hash, :hash)

    def analyze(hash)
      if hash.keys.include?(:keep_as_hash)
        hash.delete(:keep_as_hash)
        AnalyzedHash.new(true, hash)
      else
        AnalyzedHash.new(false, hash)
      end
    end

    private

    # @api private
    def list_of_allowed_methods
      %w[add_command add_option add_env add_argument add_switch]
    end

    # @api private
    def set_param(param, value)
      if value
        "x.#{param} = '#{value}'\n"
      elsif value.nil?
        "x.#{param} = nil\n"
      else
        "x.#{param} = #{value}\n"
      end
    end

    # @api private
    def add_method_with_hash_signature(method, hash)
      "x.#{method}(#{hash})\n"
    end

    # @api private
    def add_method_with_block_signature(method, value)
      block = "x.#{method} do |x|\n"
      key_array = value.keys
      key_array_length = key_array.length
      key_array.each_with_index do |v, i|
        block << add_method(v, value[v]).to_s
        block << "end\n" if i == (key_array_length - 1)
      end
      block
    end
  end
end
