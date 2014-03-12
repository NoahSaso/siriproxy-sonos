<?php

//Logging
date_default_timezone_set('America/Los_Angeles');
$inhalt = date("d.m.Y - H:i:s") . ' ' . $_SERVER['REQUEST_URI'] . "\r\n";
$handle = fopen ('log.txt', 'a');
fwrite ($handle, $inhalt);
fclose ($handle);


include("PHPSonos.inc.php");

$zones = array('inside' => '192.168.11.155',
              'outside' => '192.168.11.204',
              'porch' => '192.168.X.XXX',
              'dining' => '192.168.X.XXX',
              'master' => '192.168.X.XXX',
              'living' => '192.168.X.XXX');
               
$playmodes = array('REPEAT_ALL', 'SHUFFLE', 'NORMAL');

if(array_key_exists($_GET['zone'], $zones))
{ 
  $zone = $_GET['zone'];
  $sonos = new PHPSonos($zones[$zone]);
  
  switch($_GET['do'])
  {
    case 'GetMediaInfo':
      echo '<PRE>';
      print_r($sonos->GetMediaInfo());
      echo '</PRE>';
      break;
      
    case 'GetPositionInfo':
      echo '<PRE>';
      print_r($sonos->GetPositionInfo());
      echo '</PRE>';
      break;      
      
    case 'GetTransportSettings':
      echo '<PRE>';
      print_r($sonos->GetTransportSettings());
      echo '</PRE>';
      break;   
      
    case 'GetTransportInfo':
      //1 = PLAYING
      //2 = PAUSED_PLAYBACK
      //3 = STOPPED
    
      echo '<PRE>';
      print_r($sonos->GetTransportInfo());
      echo '</PRE>';
      break;        

    case 'GetVolume':
      echo '<PRE>';
      print_r($sonos->GetVolume());
      echo '</PRE>';
      break;
                
    case 'Mute';
      if($_GET['Mute'] == 'false')
      {
        $sonos->SetMute(false);
        echo '<PRE>';
        print_r("Mute is Off");
        echo '</PRE>';
      }
      else if($_GET['Mute'] == 'true')
      {
        $sonos->SetMute(true);
        echo '<PRE>';
        print_r("Mute is On");
        echo '</PRE>';
      }
      else
      {
        die('wrong Mute');
      }       
      break;
          
    case 'Next';
      $sonos->Next();
      break;
      
    case 'nextRadio':
      nextRadio();
      break;  
          
    case 'Pause';
      $sonos->Pause();
      break;
      
    case 'Play';
      $sonos->Play();
      break;
      
    case 'Stop';
      $sonos->Stop();
      break;      
      
    case 'TogglePlayStop':
      if($sonos->GetTransportInfo() == 1)
      {
        $sonos->Stop();
      }
      else
      {
        $sonos->Play();
      }
      break;  
      
    case 'SetPlayMode';
      if(in_array($_GET['PlayMode'], $playmodes))
      {
        $sonos->SetPlayMode($_GET['PlayMode']);
      }
      else
      {
        die('wrong PlayMode');
      }    
      break;           
                      
    case 'Previous';
      $sonos->Previous();
      break;  
                
    case 'Rewind':
      $sonos->Rewind();
      break;       
           
    case 'Remove':
      if(is_numeric($_GET['track']))
      {
        $sonos->RemoveFromQueue($_GET['track']);
      } 
      break;   
    case 'SetVolume':
    
      if(is_numeric($_GET['Volume']) && $_GET['Volume'] >= 0 && $_GET['Volume'] <= 100)
      {
        $sonos->SetVolume($_GET['Volume']);
      }
      else
      {
        die('wrong Volume');
      }
      break;  
      
    case 'VolumeUp': 
      $volume = $sonos->GetVolume();
      if($volume < 100)
      {
       $volume += 1;
       $sonos->SetVolume($volume);
      }      
      break;
      
    case 'VolumeDown':
      $volume = $sonos->GetVolume();
      if($volume > 0)
      {
       $volume -= 1;
       $sonos->SetVolume($volume);
      }
      break;      

    case 'sendMessage':
      if(is_numeric($_GET['MesageId']) && is_numeric($_GET['Volume']))
      {
        sendMessage($_GET['MesageId'], $_GET['Volume']);
      }
      break;

    case 'ClearQueue':
      $sonos->ClearQueue();
      break;

    case 'AddToQueue':
      $sonos->AddToQueue($_GET['file']);
      break;

    case 'GetMute':
      $sonos->GetMute();
      break;

    //Grundfunktionen  
    //Neue MP3 abspielen
    //$sonos->ClearQueue(); //Playlist löschen
    //$sonos->AddToQueue("x-file-cifs://ipsserver/Public/test.mp3"); //Datei hinzufügen
    //$sonos->SetQueue("x-rincon-queue:RINCON_"."HIER DIE MAC DES PLAYERS ZB: FFEEDDCCBBAA"."01400#0"); //Playlist auswählen (Nötig, wenn Radio vorher ausgewählt war)
    //$sonos->Play();
    //$sonos->SetTrack(1); //1-n
    //$sonos->RemoveFromQueue(1); //1-n  
    
    default:
      die('wrong Command');
  }
}
else
{
  die('false Zone'); 
}


/*
CREATE TABLE IF NOT EXISTS `radiostation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `radio` varchar(128) NOT NULL,
  `url` varchar(256) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

INSERT INTO `radiostation` (`id`, `radio`, `url`) VALUES
(1, 'Radio7', 'players.creacast.com/creacast/radio7/playlist.m3u'),
(2, 'SWR3', 'mp3-live.swr3.de/swr3_m.m3u'),
(3, 'Donau3FM', 'server1.webradiostreaming.de:2640'),
(4, 'Bayern3', 'http://streams.br-online.de/bayern3_2.asx');

CREATE TABLE IF NOT EXISTS `settings` (
  `act_id` int(11) NOT NULL,
  UNIQUE KEY `act_id` (`act_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
*/
function nextRadio()
{
  global $sonos;
  
  mysql_connect("localhost", "XXXXXXX", "XXXXXXX") or die("Could not connect: " . mysql_error());
  mysql_select_db("sonos");
  
  $result = mysql_query("SELECT s.act_id, MAX(r.id) AS max_id FROM settings s, radiostation r");
  
  while ($row = mysql_fetch_array($result, MYSQL_NUM)) 
  {    
      $act_id = $row[0];
      $max_id = $row[1];
  }
  
  $result = mysql_query("SELECT radio, url FROM radiostation WHERE id = $act_id");
  
  while ($row = mysql_fetch_array($result, MYSQL_NUM)) 
  {   
      $radio = $row[0]; 
      $url   = $row[1];
  }

  if($act_id == $max_id)
  {
    $act_id = 1;
  }
  else
  {
    $act_id++; 
  }

  mysql_query("UPDATE settings SET act_id = $act_id");

  mysql_free_result($result);  
  
  $sonos->SetRadio($radio, "x-rincon-mp3radio://$url");
  $sonos->Play();
}


/**
 * Vordefinierte Nachricht abspielen
 * @param int $MessageId Nummer der abzuspielenden Nachricht
 * 1 = die Waschmaschine ist fertig         
 * 2 = der Trockner ist fertig    
 *
 * @param int $Volume lautstärke der abzuspielenden Nachricht
 *
 * weitere Sprachmeldungen erstellen: http://www2.research.att.com/~ttsweb/tts/demo.php     
 */
function sendMessage($MessageId, $Volume)
{
  global $sonos, $zones, $zone;
  
  if(intval($MessageId))
  {
    //sichern der Einstellungen
    $save_MediaInfo = $sonos->GetMediaInfo();
    $save_PositionInfo = $sonos->GetPositionInfo();
    $save_Mute =$sonos->GetMute();
    $save_Vol = $sonos->GetVolume();
    $save_Status = $sonos->GetTransportInfo();
    $save_TransportSettings = $sonos->GetTransportSettings();
    
//    echo '<PRE>';
//    echo 'GetPositionInfo:';
//    print_r($save_PositionInfo);
//    echo '<br />GetMediaInfo:';
//    print_r ($save_MediaInfo);
//    echo '<br />GetMute:';
//    print_r ($save_Mute);
//    echo '<br />GetVolume:';
//    print_r ($save_Vol);
//    echo '<br />GetTransportInfo:';
//    print_r ($save_Status);
//    echo '<br />GetTransportSettings:';
//    print_r ($save_TransportSettings);    
    echo '</PRE>';
    
    // Es läuft eine Radiostation
    //Wenn Radio läuft, muss zuerst die Liste wieder aktiviert werden
    if ($save_MediaInfo["title"] !== "")
    {  
        $sonos->SetQueue("x-rincon-queue:" . getStatus($zones[$zone]) . "#0"); //Playliste aktivieren
    }
    else // Es läuft eine Musikliste
    {
        $message_pos = $save_MediaInfo['tracks'] + 1;        
    }
        
    $sonos->AddToQueue("x-file-cifs://srv01/Music/Sprachmeldungen/$MessageId.mp3");
   
    //Nochmal Infos einholen
    $PositionInfo = $sonos->GetPositionInfo();
    $MediaInfo = $sonos->GetMediaInfo();
    
    //Auf den neuen Track zeigen
    $sonos->SetTrack($MediaInfo["tracks"]);
    $sonos->SetMute(false);
    $sonos->SetVolume($Volume);
    $sonos->Play();   // Abspielen
    
    $abort = false;
    
    //wenn Meldung durch ist, Ursprungszustand wieder herstellen
    do
    {      
      $PositionInfo = $sonos->GetPositionInfo();
      
      //läuft Radio?
      $Radio = false;
      if (stripos($save_PositionInfo["URI"], "mp3radio") > 0)
      {
        $Radio = true; 
      }
      
      if(($Radio && intval($sonos->GetTransportinfo()) !== 1) ||
         (!$Radio && $PositionInfo['track'] != $message_pos))
      {
        // wurde zuletzt Radio gespielt?
        if ($Radio)
        {  
          $sonos->SetRadio($save_PositionInfo["URI"], $save_MediaInfo["title"]);
          $sonos->SetVolume($save_Vol);
          $sonos->SetMute($save_Mute);
          
          if ($save_Status === 1)
          {
             $sonos->Play();
          }
        }
        else
        {  
          // Vorher lief eine Musikliste

          $sonos->SetTrack($save_PositionInfo["track"]);
          $sonos->SetVolume($save_Vol);
          $sonos->SetMute($save_Mute);
          
          // An die alte Stelle springen
          $sonos->Seek(trim($save_PositionInfo["position"]));
            
          if ($save_Status === 1)
          {            
              $sonos->Play();
          }
          
          //wenn Repeat oder Shuffle aktiviert ist und die Musik nicht läuft, 
          //muss die Pause gesetzt werden, da sonst die Musik anläuft
          if($save_Status != 1 && ($save_TransportSettings['shuffle'] == 1 || $save_TransportSettings['repeat'] == 1))
          {
            $sonos->Pause();
          }          
        }
        $abort = true;
      }
      else
      {
        //es läuft was, kurz warten
        sleep(1);
      }
    }
    while($abort == false);
    
    //Message wieder aus Queue entfernen
    $sonos->RemoveFromQueue(intval($MediaInfo["tracks"]));
  }
} 

function getStatus($zoneplayerIp)
{
  $url = "http://" . $zoneplayerIp . ":1400/status/zp";
  $xml = simpleXML_load_file($url);  
  return $xml->ZPInfo->LocalUID;  
}

?>
