module Check_MK
  module Config
    class Config < ::Hash
      def to_s
        map do |key, config|
          key.to_s + (config.is_a?(Array) ? " += " : " = ") + config.to_s
        end.join("\n\n")
      end
    end

    class MKInteger < ::Integer
      def to_s
        super(self)
      end
    end

    class MKString < ::String
      def initialize(str)
        super("\"#{str}\"")
      end
    end

    class MKArray < ::Array
      def to_s
        "[" + join(",\n") + "]"
      end
    end

    class MKList < ::Hash
      def to_s
        "{" + map {|k, v| "#{k} : #{v}"}.join(",\n") + "}"
      end
    end

    class MKTuple < ::Array
      def to_s
        "(" + join(",") + ")"
      end
    end

    def self.all_hosts(hosts = [])
      Array(hosts.map { |e| String(e) })
    end

    def self.ip_addresses(hosts = {})
      Config['ip_addresses' => MKList[hosts.map {|e, v| [MKString.new(e), MKString.new(v)]}]]
    end

    def self.is_a_number?(obj)
      true if Integer(obj) rescue false
    end

    def self.criteria(criteria)
      if criteria.is_a?Array
        "[" + criteria.map { |e| "\"e\"" }.join(',') + "], ALL_HOSTS"
      else
        "\"#{criteria}\""
      end
    end

    def codify(obj)
      is_a_number?(obj) ? obj : "\"obj\""
    end

    def self.check_parameters(params)
      if params and !params.empty?
        ", (" + params.map { |param| is_a_number?(param) ? param : "\"param\"" }.join(",") + ")"
      else
        ""
      end
    end

    def self.check(params={})
      if params[:check] and params[:criteria] and params[:name]
        MKTuple.new(
          params[:tags] ? MKTupleMKArray.new() : MKTuple.new(params[:criteria]),
          MKString.new(params[:check]),
          MKString.new(params[:name]),
          MKTuple.new(params[:params])
        )
        # "( #{criteria(params[:criteria])}, \"#{params[:check]}\", \"#{params[:name]}\" #{check_parameters(params[:params])} )"
      end
    end
  end
end