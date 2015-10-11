#run this code in any system with a USB RFID connected. Tested in Mac OSX and Raspberry Pi. 
#This client receives the data from the RFID reader and sends it to the server.


require_relative 'em-websocket-client'
require "serialport"
require "json"

#rfid object 
#9600 is the baud rate for the RFID reader and 
#"/dev/tty.usbserial-A90246LK" can be different fot your system. Make sure the port is assigned to the rfid reader.
rfid = SerialPort.new("/dev/tty.usbserial-A90246LK", 9600)
rfid.read_timeout = 1000

EM.run do
    #conn = EventMachine::WebSocketClient.connect("ws://web-tworit.rhcloud.com:8000/")
    #if you want to accept the data from the rfid tags through a local server then uncomment the following line and make the above a comment line.
    conn = EventMachine::WebSocketClient.connect("ws://192.168.43.26:8000/")
    conn.callback do
	msg = {"type" => "connection", "id" => "0", "name" => "RFID Tag"}.to_json
        conn.send_msg msg
       	#puts "connected !" 
    end

    conn.errback do |e|
        puts "Got error: #{e}"
    end

    conn.stream do |msg|
    	
    	#puts "received: #{msg}"
    	
    	tag = rfid.gets #receives data from reader. 
        rfid_msg = {
    		"type" => "tag",
    		"id" => tag,
    		"name" => "LockID"
    	}
	    
	
        #puts "waiting for a card"
	    #File.open("public/temp.json", "w") do |f|
		  #f.write(rfid_msg.to_json)
	    #end
        #file = File.read('public/temp.json')
        #data_hash = JSON.parse(file)
        #puts data_hash['id']          
        #puts tag #prints the tag ID
    	#puts tag.class #prints the tag data type
        #puts tag.inspect #prints the exact data being received 
        conn.send_msg rfid_msg.to_json #sends data to the websocket server
    end

     

    conn.disconnect do
        puts "disconnected!"
        EM::stop_event_loop
    end
end
