gem 'activerecord'
require 'active_record'

module Gloo
  module ActiveRecord
    def self.included(base)
      base.extend ClassMethods
    end
    
    class Proxy
      def initialize(klass)
        @klass = klass
      end
      
      # Create a one-to-one relationship between this class and
      # an ActiveRecord model. This should only be done if this
      # class contains a foreign key attribute referencing the.
      # model in question. Options supported:
      #
      # [:class_name]
      #    Specify the class name of the association. Use it only if that 
      #    name can‘t be inferred from the association name. So has_one 
      #    <tt>:author</tt> will by default be linked to the Author class, 
      #    but if the real class name is Person, you‘ll have to specify it 
      #    with this option.
      # [:conditions]
      #    Specify the conditions that the associated object must meet in 
      #    order to be included as a <tt>WHERE</tt> SQL fragment, such as 
      #    <tt>authorized = 1</tt>.
      # [:include]
      #    Specify second-order associations that should be eager loaded 
      #    when this object is loaded.
      # [:select]
      #    Select specific fields to return in the <tt>SELECT</tt> statement.
      # [:foreign_key]
      #    The method on this class that will yield a valid primary key for
      #    the associated ActiveRecord model.
      # [:primary_key]
      #    The column in the database to which this association is keyed.
      def belongs_to(association_id, options = {})
        @klass._activerecord_belongs_to association_id, options
      end
      
      def method_missing(name, *args)
        @klass.send("_activerecord_#{name}", *args)
      end
    end
    
    module ClassMethods
      @@_activerecord_proxies = {}
      
      def gloo(to, &block)
        case to
          when :active_record
            @proxy = Gloo::ActiveRecord::Proxy.new(self).instance_eval(&block)
          else
            super if respond_to?(:super)
        end
      end
      
      def _activerecord_proxies
        @@_activerecord_proxies
      end
      
      def _activerecord_belongs_to(association_id, options = {})
        association_id = association_id.to_s

        opts = {
          :class_name => association_id.classify,
          :foreign_key => "#{association_id}_id",
          :primary_key => "id"
        }.merge(options)

        proxy = opts[:class_name].classify.constantize

        proxy = proxy.where(opts[:conditions]) if opts[:conditions]
        proxy = proxy.includes(*opts[:include]) if opts[:include]
        proxy = proxy.select(opts[:select]) if opts[:select]

        (_activerecord_proxies[:belongs_to] ||= {})[association_id] = proxy
        
        class_eval <<-RUBY
          def #{association_id}
            return nil unless self.send(#{opts[:foreign_key].inspect})
            self.class._activerecord_proxies[:belongs_to][#{association_id.inspect}].where(#{opts[:primary_key].inspect} => self.#{opts[:foreign_key]}).first
          end

          def #{association_id}=(associate)
            self.#{opts[:foreign_key]} = associate.#{opts[:primary_key]}
          end
          
          def create_#{association_id}(attributes = {})
            self.#{association_id} = #{opts[:class_name]}.create(attributes)
          end
        RUBY
      end
      
      def _activerecord_has_many(association_id, options = {}, &extension)
        association_id = association_id.to_s.underscore

        opts = {
          :class_name => association_id.singularize.classify,
          :foreign_key => "#{self.name.underscore.singularize}_id",
          :primary_key => "id"
        }.merge(options)
        
        proxy = opts[:class_name].classify.constantize

        proxy = proxy.where(opts[:conditions]) if opts[:conditions]
        proxy = proxy.includes(*opts[:include]) if opts[:include]
        proxy = proxy.select(opts[:select]) if opts[:select]

        (_activerecord_proxies[:has_many] ||= {})[association_id] = proxy
        
        class_eval <<-RUBY
          def #{association_id}
            self.class._activerecord_proxies[:has_many][#{association_id.inspect}].where(#{opts[:foreign_key].inspect} => self.#{opts[:primary_key]}).all
          end

          def #{association_id}=(associates)
            associates.each{|a| a.update_attributes(#{opts[:foreign_key].inspect} => self.#{opts[:primary_key]})}
          end
          
          def #{association_id.singularize}(attributes = {})
            self.#{association_id} = #{opts[:class_name]}.create(attributes).where()
          end
          
          def #{association_id.singularize}_ids
            self.#{association_id}.select(:id).all.collect{|a| a.id}
          end
          
          def #{association_id.singularize}_ids=(new_ids)
            self.class._activerecord_proxies[:has_many][#{association_id.inspect}].where(:id => new_ids).update_all(#{opts[:foreign_key].inspect} => self.#{opts[:primary_key]})
          end
        RUBY
      end
    end
  end
end