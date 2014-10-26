def attribute *names, &block
    names.each do |name|
      attribute *name.map{|k,v|[k,v]} and next if name.kind_of? Hash
      name,v = name
      class_eval "def #{name};"+
            "@#{name}=(defined?(@#{name}) ? @#{name} : #{name}_init_);
end"
      class_eval "def #{name}?; !(self.#{name}.nil?); end"
      class_eval "def #{name}=(v); @#{name}=v; end"
      private; define_method("#{name}_init_", block || proc {v})
    end
  end
  

  Meta_value = {}

def attribute(name, &block)
   (name.is_a?(Hash) ? name : {name => nil}).each do |key, value|
     define_method(key.to_sym) do
       if Meta_value[[self, key]].nil?
         Meta_value[[self, key]] = (block_given? ? instance_eval(&block)
: value)
       else
         Meta_value[[self, key]]
       end
     end
     define_method((key + "=").to_sym) {|val| Meta_value[[self, key]] =
val}
     define_method((key + "?").to_sym) {not Meta_value[[self,
key]].nil?}
   end
end

def attribute(a, &b)
    b or return (Hash===a ? a : {a=>nil}).each{|k,v| attribute(k){v}}
    define_method(a){(x=eval("@#{a}")) ? x[0] : instance_eval(&b)}
    define_method("#{a}?"){!send(a).nil?}
    define_method("#{a}="){|v| instance_variable_set("@#{a}", [v])}
  end