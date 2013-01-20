module Fluent
    require 'net/http'
    require 'jsonpath'
    require 'aws-sdk'
    class CloudWatchYaOutput < TimeSlicedOutput

        METRIC_DATA_MAX_NUM = 20 
        Fluent::Plugin.register_output('cloudwatch_ya', self)
        config_param :aws_key_id,                  :string, :default => nil
        config_param :aws_sec_key,                 :string, :default => nil
        config_param :cloud_watch_endpoint,        :string, :default => 'monitoring.ap-northeast-1.amazonaws.com'
        config_param :namespace,                   :string

        def configure(conf)
            super
            instance_id = Net::HTTP.get('169.254.169.254', '/1.0/meta-data/instance-id')
            @metric_list = []
            conf.elements.select {|element|
                element.name == 'metric'
            }.each do |metric|
                dimensions_list = []
                if not metric['outcast_no_dimension_metric'] == 'yes' then
                    dimensions_list << []
                end
                metric.elements.select {|element|
                    element.name == 'dimensions'
                }.each do |dimensions|
                    dimension_list = []
                    dimensions.each do |dimension, value|
                        if    dimension.start_with?("dimension") then
                            name_and_value = value.split("=")
                            dimension_list << { 'name' => name_and_value[0], 'value' => name_and_value[1] }
                        elsif dimension == 'instance_id' and value == 'yes' then
                            dimension_list << { 'name' => 'InstanceId', 'value' => instance_id }
                        elsif dimension == 'fluent_tag' and value == 'yes' then
                            dimension_list << { 'name' => 'FluentTag', 'value' => nil }
                        end
                    end
                    dimensions_list << dimension_list
                end
                @metric_list << {
                    'metric_name'     => metric['metric_name'],
                    'value_key'       => metric['value_key'],
                    'unit'            => metric['unit'],
                    'dimensions_list' => dimensions_list
                }
            end
            $log.debug(@metric_list.inspect)
        end

        def format(tag, time, record)
            record["tag"]       =  tag
            record["timestamp"] =  Time.at(time).iso8601
            record.to_msgpack
        end
        
        def write(chunk)
            metric_data = []
            chunk.msgpack_each do |record|
                @metric_list.each do |metric|
                    value = JsonPath.new(metric['value_key']).first(record)
                    if not value.nil? then
                        metric['dimensions_list'].each do |dimensions|
                            dimensions.each do |dimension_list|
                                if dimension_list['name'] == 'FluentTag' then
                                    dimension_list['value'] = record['tag'];
                                end
                            end
                            metric_data << {
                                :metric_name => metric['metric_name'],
                                :timestamp   => record['timestamp'],
                                :value       => value,
                                :unit        => metric['unit'],
                                :dimensions  => dimensions
                            }
                        end
                    end
                end
            end
            AWS.config(
                :access_key_id        => @aws_key_id,
                :secret_access_key    => @aws_sec_key,
                :cloud_watch_endpoint => @cloud_watch_endpoint
            )
            cloud_watch = AWS::CloudWatch.new
            until metric_data.length <= 0 do
                $log.debug(metric_data.slice(0, METRIC_DATA_MAX_NUM).inspect)
                cloud_watch.put_metric_data(
                    :namespace   => @namespace,
                    :metric_data => metric_data.slice!(0, METRIC_DATA_MAX_NUM)
                )
            end
        end

    end
end
