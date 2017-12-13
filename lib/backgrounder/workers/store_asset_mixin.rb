# encoding: utf-8
module CarrierWave
  module Workers

    module StoreAssetMixin
      include CarrierWave::Workers::Base

      def self.included(base)
        base.extend CarrierWave::Workers::ClassMethods
      end

      attr_reader :cache_paths, :tmp_directories

      def perform(*args)
        record = super(*args)

        if record && record.send(:"#{column}_tmp")
          store_directories(record)
          record.send :"process_#{column}_upload=", true
          record.send :"#{column}_tmp=", nil
          record.send :"#{column}_processing=", false if record.respond_to?(:"#{column}_processing")
          if record.respond_to?("#{column}_urls")
            files = cache_paths.map do |cache_path|
              File.open(cache_path)
            end
            record.send :"#{column}=", files
          else
            File.open(cache_paths[0]) { |f| record.send :"#{column}=", f }
          end
          if record.save!
            FileUtils.rm_r(tmp_directories, :force => true)
          end
        else
          when_not_ready
        end
      end

      private

      def store_directories(record)
        asset_tmp = record.send(:"#{column}_tmp")
        uploader = record.class.uploaders[:"#{column}"]
        cache_directory  = File.expand_path(uploader.cache_dir, uploader.root.call)
        @cache_paths     = asset_tmp.map { |a| File.join(cache_directory, a) }
        @tmp_directories = asset_tmp.map { |a| File.join(cache_directory, a.split("/").first) }
      end

    end # StoreAssetMixin

  end # Workers
end # Backgrounder
