#  CacheChu created by rociiu.yu@gmail.com
# 
# 
# Sample:
#
#     class User < ActiveRecord::Base
#       
#       def some_complex_cal(param_a, param_b)
#         
#       end
#       
#       include CacheChu
#       cache_chu :some_complex_cal
#       
#     end
#

module CacheChu
  
  class CacheChuArgumentError < ArgumentError; end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def cache_chu(*methods_to_cache)
      
      methods_to_cache.each do |_method_to_cache|
        
        _methodname_with_cache    = "#{_method_to_cache}_with_cache"
        _methodname_without_cahce = "#{_method_to_cache}_without_cache"
        
        define_method _methodname_with_cache.to_sym do |*params|
          cache_key = "#{self.class.to_s.downcase}_#{self.id}_#{_method_to_cache}_#{params.join('_')}"
          
          if cached_result = Rails.cache.read(cache_key)
            cached_result
          else
            if params.size == 0
              result_to_cache = self.send(_methodname_without_cahce.to_sym)
            else
              result_to_cache = self.send(_methodname_without_cahce.to_sym, *params)              
            end
            Rails.cache.write(cache_key, result_to_cache)
            result_to_cache
          end
          
        end
        
        alias_method_chain _method_to_cache.to_sym, :cache
        
      end
      
    end
    
  end

end