#!/usr/bin/env ruby


require 'pp'
require 'uri'
require 'json'
require 'openssl'
require 'net/http'
require 'io/console'

#####################################################################################
##################################### CONFIG ########################################
#####################################################################################

               ###########################################################
               #################### API CONFIG ###########################
               ###########################################################

BASE_URL       = "https://www.bitmex.com"                                # Base URL.
API_PATH       = "/api/v1"                                               # Path for API.
BASE_API       = "#{BASE_URL}#{API_PATH}"                                # Base API URL.
BINSIZE        = "binSize=1h"                                            # Candle interval (1m, 5m, 1h, or 1d).
PARTIAL        = "partial=false"                                         # If true, returns current (in-progress) candle.
SYMBOL         = "symbol=XBTUSD"                                         # Currency pair to pull data for.
COUNT          = "count=36"                                              # Number of candles to return.
REVERSE        = "reverse=true"                                          # Sends newest results first.
ARGS           = "#{BINSIZE}&#{PARTIAL}&#{SYMBOL}&#{COUNT}&#{REVERSE}"   # Concatenate Arguments.
CANDLE_API     = "#{BASE_API}/trade/bucketed?#{ARGS}"                    # API Call for Candle Data.
ROUND          = 6                                                       # Decimals to round currency ammount.
DEBUG          = true                                                    # Toggle debug output.
TEST           = false                                                   # Toggle test mode.
ERROR          = "2> /dev/null"                                          # Blackhole error output.
CURL           = "/usr/bin/curl"                                         # Path to curl, going to use Net::HTTP but getting strange errors.

               ###########################################################
               ################# INDICATOR CONFIG ########################
               ###########################################################

SMA            = true                                                    # Enables SMA.
SMA_WEIGHT     = 1.0                                                     # Weight Score.
SMA_PERIOD     = 20                                                      # Number of Periods to Calculate.

#####################################################################################
################################### END CONFIG ######################################
#####################################################################################

def get_timestamp()
  # INPUTS:  None
  # OUTPUTS: STRING, "normal time ::: epoch time"
  time  = Time.now.to_s
  epoch = Time.now.to_f.round(4)
  return("#{time} | #{epoch}")
end

def debug(text)
  # INPUTS:  STRING, "Text to be put in debug message"
  # OUTPUTS: STDOUT, "Prints timestamp ::: debug text"
  if(DEBUG)
    time = get_timestamp
    puts "#{time} | #{text}"
  end
end

def test()
  if(TEST)
    puts("==================")
    puts("Entering Test Mode")
    puts("==================")
    puts("\n\n\n")
#########################################################
##################### TEST CODE START ###################
#########################################################
    pp get_candles()
#########################################################
###################### TEST CODE END ####################
#########################################################
    puts("=================")
    puts("Exiting Test Mode")
    puts("=================")
    exit()
  else
    return()
  end
end

def get_candles()
  #url          = URI.parse(CANDLE_API)
  #debug("Preparing to send GET request to #{CANDLE_API}")
  #req          = Net::HTTP::Get.new(url.path, 'Content-Type' => 'application/json')
  #http         = Net::HTTP.new(url.host, url.port)
  #http.use_ssl = true
  #res          = http.request(req)
  #return(JSON.parse(res.read_body))

  curl_cmd = "curl -X GET --header 'Accept: application/json' '#{CANDLE_API}' #{ERROR}"
  debug("Preparing to send GET request to #{CANDLE_API}")
  debug("Preparing to run command: #{curl_cmd}")
  output   = `#{curl_cmd}`
  return(JSON.parse(output))
end

def sma(data)
#  data.each do |candle|
#    close = candle["close"]
#  end

  total = 0.0
  i     = 0
  while i < (SMA_PERIOD)
    close = data[i]["close"].to_f
    total = total + close
    i    += 1
  end
  sma = total / SMA_PERIOD
  debug("SMA = #{sma}")
  sma_score = "" #Enter code to score sma.
  return(sma_score)
end

def main()
  test()
  data = get_candles()
  if(SMA)
    sma_score = sma(data)
  end
  exit()
end

main()
