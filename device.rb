require 'mqtt'
require 'json'

class Device
  attr_reader :delta
  attr_accessor :local_state

  def initialize
    @mqtt_config = {
      host: "<CODE>-ats.iot.ap-northeast-1.amazonaws.com",
      port: 8883,
      ssl: true,
      cert_file: "bb122a5e/device.pem.crt",
      key_file: "bb122a5e/private.pem.key",
      ca_file: "bb122a5e/AmazonRootCA1.pem"
    }
    @thingName = "thing-1"
    @shadowName = "shadow-1"
    
    # classic shadow
    # @shadow_topic = "$aws/things/#{@thingName}/shadow"
    
    # named shadow
    @shadow_topic = "$aws/things/#{@thingName}/shadow/name/#{@shadowName}" 
    
    @message = { state: { reported: { mode: nil } } }
    @topics = [
      @shadow_topic + "/delete/accepted",
      @shadow_topic + "/delete/rejected",
      @shadow_topic + "/get/accepted",
      @shadow_topic + "/get/rejected",
      @shadow_topic + "/update/accepted",
      @shadow_topic + "/update/rejected",
      @shadow_topic + "/update/delta",
      @shadow_topic + "/update/documents"
    ]
  end

  def connect
    @client =  MQTT::Client.connect(**@mqtt_config)
  end

  def subscribe
    Thread.new do 
      @client.get(@topics) do |topic, message|
        puts topic
        puts JSON.pretty_generate(JSON.parse(message))
        if topic.end_with?("delta")
          @delta = JSON.parse(message, symbolize_names: true)
        end
      end
    end
  end

  def get
    @client.publish(@shadow_topic + "/get")
  end

  def sync
    @local_state = @delta[:state][:mode]
  end

  def report
    @message[:state][:reported][:mode] =  @local_state 
    @client.publish(@shadow_topic + "/update", @message.to_json)
  end

  def delete
    @client.publish(@shadow_topic + "/delete")
  end

end
