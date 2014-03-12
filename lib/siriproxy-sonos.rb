# -*- encoding: utf-8 -*-
require 'cora'
require 'siri_objects'
require 'pp'

class SiriProxy::Plugin::Sonos < SiriProxy::Plugin

  def initialize(config)

    @ip = config['sonos_web_ip']
    @port = config['sonos_web_port']

    @sonos1 = config['sonos_room1']
    @sonos2 = config['sonos_room2']
    @sonos3 = config['sonos_room3']
    @sonos4 = config['sonos_room4']
    @sonos5 = config['sonos_room5']
    @sonos6 = config['sonos_room6']

  end

  def doesEqualVar(zone)
    if(doesEqualVar(zone) ||
      zone==@sonos2 ||
      zone==@sonos3 ||
      zone==@sonos4 ||
      zone==@sonos5 ||
      zone==@sonos6)
      return true
    else
      return false
    end
  end

  listen_for /sonos list/i do
    say "
    You can say: 
    \r\n  sonos + 
    \r\n    • list
    \r\n    • ZONE play
    \r\n    • ZONE pause
    \r\n    • ZONE stop
    \r\n    • is ZONE muted
    \r\n    • ZONE check volume
    \r\n    • volumes
    \r\n    • ZONE volume up
    \r\n    • ZONE volume down
    \r\n    • ZONE mute <on/off>
    \r\n    • ZONE shuffle <on/off>
    \r\n    • ZONE repeat all <on/off>
    \r\n    • ZONE status
    \r\n    • <status/statuses>
    \r\n    • ZONE what song is this
    \r\n    • ZONE next
    \r\n    • ZONE previous
    \r\n    • ZONE rewind
    \r\n    • ZONE edit queue
    \r\n    • ZONE clear queue
    \r\n    • set volume
    \r\n    • ZONE set volume
    "
  end

  listen_for /sonos (.*) play/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Play"))
      say "Playing"
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) pause/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Pause"))
      say "Paused"
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) stop/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Stop"))
      say "Stopped"
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos is (.*) muted/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetMute"))
      if(sonos==true)
        say "Sonos '#{zone}' is muted."
      else
        say "Sonos '#{zone}' is not muted."
      end
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) check volume/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetVolume"))
      numb = sonos.split("<PRE>")[1].split("</PRE>")[0]
      say "Sonos '#{zone}' volume is #{numb}."
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos volumes/i do
    sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetVolume"))
    sonos2 = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{@sonos2}&do=GetVolume"))
    numb = sonos.split("<PRE>")[1].split("</PRE>")[0]
    numb2 = sonos2.split("<PRE>")[1].split("</PRE>")[0]
    say "• #{zone}'s volume is: #{numb} \r\n• #{@sonos2}'s volume is: #{numb2}", spoken: "• #{zone}'s volume is: #{numb}, \r\n• #{@sonos2}'s volume is: #{numb2}"

    request_completed
  end

  listen_for /sonos (.*) volume up/i do |zone|
    if(doesEqualVar(zone))
      number = ask "How much would you like me to increase the volume by?"
      for current_numb in 1..number.to_i do
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=VolumeUp"))
      end
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetVolume"))
      numb = sonos.split("<PRE>")[1].split("</PRE>")[0]
      say "Sonos '#{zone}' volume increased by #{number}. The new volume is: #{numb}"
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) volume down/i do |zone|
    if(doesEqualVar(zone))
      number = ask "How much would you like me to decrease the volume by?"
      for current_numb in 1..number.to_i do
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=VolumeDown"))
      end
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetVolume"))
      numb = sonos.split("<PRE>")[1].split("</PRE>")[0]
      say "Sonos '#{zone}' volume decreased by #{number}. The new volume is: #{numb}"
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) mute (.*)/i do |zone, toggle|
    if(doesEqualVar(zone))
      if(toggle=="on")
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Mute&Mute=true"))
        say "Mute has been enabled for '#{zone}'."
      elsif(toggle=="off")
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Mute&Mute=false"))
        say "Mute has been disabled for '#{zone}'."
      else
        say "That is not an option. Please say 'on' or 'off'"
      end
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) shuffle (.*)/i do |zone, toggle|
    if(doesEqualVar(zone))
      if(toggle=="on")
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=SetPlayMode&PlayMode=SHUFFLE"))
        say "Shuffle has been enabled for '#{zone}'."
      elsif(toggle=="off")
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=SetPlayMode&PlayMode=SHUFFLE"))
        say "Shuffle has been disabled for '#{zone}'."
      else
        say "That is not an option. Please say 'on' or 'off'"
      end
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) repeat all (.*)/i do |zone, toggle|
    if(doesEqualVar(zone))
      if(toggle=="on")
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=SetPlayMode&PlayMode=REPEAT_ALL"))
        say "Repeat All has been enabled for '#{zone}'."
      elsif(toggle=="off")
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=SetPlayMode&PlayMode=REPEAT_ALL"))
        say "Repeat All has been disabled for '#{zone}'."
      else
        say "That is not an option. Please say 'on' or 'off'"
      end
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) status/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetTransportInfo"))
      numb = sonos.split("<PRE>")[1].split("</PRE>")[0]
      status = ""
      if(numb.to_i==1)
        status = "PLAYING"
      elsif(numb.to_i==2)
        status = "PAUSED"
      elsif(numb.to_i==3)
        status = "STOPPED"
      else
        status = "OFF"
      end
      say "The status of '#{zone}' is: #{status}"
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (status|statuses)/i do
    say "Checking Statuses. Please Wait..."
    sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetTransportInfo"))
    numb = sonos.split("<PRE>")[1].split("</PRE>")[0]
    status = ""
    if(numb.to_i==1)
      status = "PLAYING"
    elsif(numb.to_i==2)
      status = "PAUSED"
    elsif(numb.to_i==3)
      status = "STOPPED"
    else
      status = "OFF"
    end

    sonos2 = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{@sonos2}&do=GetTransportInfo"))
    numb2 = sonos2.split("<PRE>")[1].split("</PRE>")[0]
    status2 = ""
    if(numb2.to_i==1)
      status2 = "PLAYING"
    elsif(numb2.to_i==2)
      status2 = "PAUSED"
    elsif(numb2.to_i==3)
      status2 = "STOPPED"
    else
      status2 = "OFF"
    end

    say "• '#{zone}' is: #{status} \r\n• '#{@sonos2}' is: #{status2}", spoken: "• '#{zone}' is: #{status}, \r\n• '#{@sonos2}' is: #{status2}"

    request_completed
  end

  listen_for /sonos (.*) what song is this/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetPositionInfo"))
      artist = sonos.split("[artist] => ")[1].split("[title]")[0].strip
      song = sonos.split("[title] => ")[1].split("[album]")[0].strip
      if(artist==""||song=="")
        say "
        I cannot tell what song is playing.
        If you are sure that this sonos system is playing a song, then it is probably connected to another sonos.
        "
      else
        say "This song is called: #{song}, and is written by: #{artist}."
      end
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) next/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetPositionInfo"))
      sonos2 = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Next"))
      artist = sonos.split("[artist] => ")[1].split("[title]")[0].strip
      song = sonos.split("[title] => ")[1].split("[album]")[0].strip
      say "'#{zone}' is now playing the next song in the queue."
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) previous/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetPositionInfo"))
      sonos2 = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Previous"))
      artist = sonos.split("[artist] => ")[1].split("[title]")[0].strip
      song = sonos.split("[title] => ")[1].split("[album]")[0].strip
      say "'#{zone}' is now playing the previous song in the queue."
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) rewind/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Rewind"))
      say "I have rewinded the current song."
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) edit (queue|Q)/i do |zone|
    if(doesEqualVar(zone))
      response = ask "Would you like to remove the current track from the queue?"
      if(response=~ /yeah/i || response=~ /yes/i || response=~ /yup/i)
        sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=GetPositionInfo"))
        song = sonos.split("[title] => ")[1].split("[album]")[0].strip
        track = sonos.split("[track] => ")[1].split("[position]")[0].strip
        sonos2 = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Remove&track=#{track}"))
        say "I have removed #{song} from your queue."
      else
        say "You did not say yes, so I will not do anything."
      end
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos (.*) clear (queue|Q)/i do |zone|
    if(doesEqualVar(zone))
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=ClearQueue"))
      say "I have cleared your queue."
    else
      say "That is not a sonos system."
    end

    request_completed
  end

  listen_for /sonos set volume/i do
    vol = ask "What do you want me to set the main volume to?"
    volume = vol.to_i
    if(volume>=100)
      volume = 100
    elsif(volume<=0)
      volume = 0
    end
    sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Volume&Volume=#{volume}"))
    sonos2 = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{@sonos2}&do=Volume&Volume=#{volume}"))
    say "I have set the main volume to #{volume}."

    request_completed
  end

  listen_for /sonos (.*) set volume/i do |zone|
    if(doesEqualVar(zone))
      vol = ask "What do you want to set the volume to?"
      volume = vol.to_i
      sonos = Net::HTTP.get(URI.parse("http://#{@ip}:#{@port}/sonos/index.php?zone=#{zone}&do=Volume&Volume=#{volume}"))
      say "I have set the volume for '#{zone}' to #{volume}."
    else
      say "That is not a sonos system."
    end

    request_completed
  end

end
