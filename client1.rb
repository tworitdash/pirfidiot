#The client which receives the data from the server to send it to the controller (For example arduino)

require_relative 'em-websocket-client'
require "serialport"
require "json"




EM.run do
    #conn = EventMachine::WebSocketClient.connect("ws://example.com:8000/")
    conn = EventMachine::WebSocketClient.connect("ws://192.168.43.26:8000/")
    #put the IP adress of the server machine in case of IP_address
    conn.callback do
        msg = {"type" => "connection", "id" => "0", "name" => "RFID Tag"}.to_json
        conn.send_msg msg
    end

    conn.errback do |e|
        puts "Got error: #{e}"
    end

    conn.stream do |msg|
         
        list_of_tags_authenticated = ["02000F0E94\r\n"] 
        port_file = "/dev/cu.usbmodem1421"
        #port_file is according to the path to your controller
        baud_rate = 9600
        data_bits = 8
        stop_bits = 1
        parity = SerialPort::NONE
        #serialport object
        ser = SerialPort.new(port_file , baud_rate , data_bits , stop_bits , parity)
        if msg.to_s != "connected"
            File.open("public/temp.json", 'w') do |f|
                f.write(msg)
            end
        end

        file = File.read("public/temp.json")

        id_hash = JSON.parse(file)
        id = id_hash['id']
        name = id_hash['name']

        list_of_tags_authenticated.each do |authenticated_tag_id|
            if id == authenticated_tag_id and name == "LockID"
                ser.write('b')
                puts "b is written to the card"
            else 
                puts "invalid card, Try again !"
            end
        end

        
	       #puts "received msg: #{msg}" #prints the tag ID (optional)
	
        
    end

    conn.disconnect do
        puts "disconnected!"
        EM::stop_event_loop
    end
end
