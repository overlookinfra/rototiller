module RakefileTools
  def create_rakefile_on(sut, rakefile_contents)
    # using blocks for step in here causes beaker to not un-indent log
    path_to_rakefile = ""
    step "Copy rake file to SUT" do
      # bit hackish.  find name of calling file (from the stack) minus the extension
      test_name = File.basename(caller[0].split(":")[0], ".*")
      path_to_rakefile = "/tmp/Rakefile_#{test_name}_#{random_string}"

      create_remote_file(sut, path_to_rakefile, rototiller_rakefile_header + rakefile_contents)
    end
    path_to_rakefile
  end

  def create_rakefile_task_segment(segment_configs)
    segment = ""
    segment_configs.each do |this_segment|
      if this_segment[:type] == :env
        sut.add_env_var(this_segment[:name], "#{this_segment[:name]}: env present value") if this_segment[:exists]
        add_type = "add_env"
      elsif this_segment[:type] == :option
        sut.add_env_var(this_segment[:override_env], "#{this_segment[:override_env]}: env present value") if this_segment[:exists]
        add_type = "add_flag"
      elsif this_segment[:type] == :switch
        sut.add_env_var(this_segment[:override_env], this_segment[:env_value]) if this_segment[:override_env]
        add_type = "add_flag"
      end
      if this_segment[:block_syntax]
        segment += "t.#{add_type} do |this_segment|\n"
        remove_reserved_keys(this_segment).each do |k, v|
          segment += "  this_segment.#{k} = '#{v}'\n"
        end
        segment += "end\n"
      else
        segment += "  t.#{add_type}({"
        remove_reserved_keys(this_segment).each do |k, v|
          segment += ":#{k} => '#{v}',"
        end
        segment += "})\n"
      end
    end
    segment
  end

  def rototiller_rakefile_header
    "require 'rototiller'\n"
  end

  class RototillerBodyBuilder
    def initialize(hash_representation)
      @body = ""
      hash_representation.each do |k, v|
        @body << add_method(k, v)
      end
      to_s
    end

    def add_method(method, value)
      add_methods = %w[add_command add_option add_env add_argument add_switch]
      block = ""

      if add_methods.include?(method.to_s)
        # can take a block
        analyzed = analyze(value)
        if analyzed.keep_as_hash
          block << add_method_with_hash_signature(method, value)
        else
          block << "x.#{method} do |x|\n"
          key_array = value.keys
          key_array_length = key_array.length
          key_array.each_with_index do |v, i|
            block << add_method(v, value[v])
            block << "end\n" if i == (key_array_length - 1)
          end
        end
      else
        block << set_param(method, value)
      end

      block
    end

    def to_s
      @body.to_s
    end

    def add_method_with_hash_signature(method, hash)
      "x.#{method}(#{hash})\n"
    end

    def set_param(param, value)
      if value
        "x.#{param} = '#{value}'\n"
      else
        if value.nil?
          "x.#{param} = nil\n"
        else
          "x.#{param} = #{value}\n"
        end
      end
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
  end
end
