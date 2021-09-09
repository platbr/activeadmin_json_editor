#-*- encoding: utf-8; tab-width: 2 -*-
require 'activeadmin'

module ActiveAdmin
  class ResourceDSL
    def json_editor
      before_save do |object, _args|
        object.class.columns_hash.select { |_key, attr| attr.type.in? [:json, :jsonb] }.keys.each do |key|
          next unless params[resource_request_name].key? key
          next unless object.attributes[key].is_a?(String)

          object.attributes = { key => JSON.parse(object.send(key)) }
        end
        object.nested_attributes_options.keys.each do |nested_key|
          nested_attributes_with_index = params[resource_request_name]["#{nested_key}_attributes"]
          next if nested_attributes_with_index.nil?

          nested_klass = nested_key.to_s.singularize.camelize.constantize
          nested_klass.columns_hash.select { |_key, attr| attr.type.in? [:json, :jsonb] }.keys.each do |key|
            nested_attributes_with_index.each do |_index, nested_attributes|
              next unless nested_attributes.key? key

              object.send(nested_key).each do |nested_object|
                next unless nested_object.attributes[key].is_a?(String)

                nested_object.attributes = { key => JSON.parse(nested_object.send(key)) }
              end
            end
          end
        end
      end
    end
  end
end
