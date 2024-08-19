class SportsController < ApplicationController

  def mlb
    require 'net/http'
    require 'json'

    # Set up the URL
    @highlights_url = "https://sport-highlights-api.p.rapidapi.com/baseball/highlights?leagueName=MLB&season=2024"
    @highlights_uri = URI.parse(@highlights_url)  # Parse the URL to create the URI

    # Set up the HTTP request
    http = Net::HTTP.new(@highlights_uri.host, @highlights_uri.port)
    http.use_ssl = true

    # Create the request with headers
    request = Net::HTTP::Get.new(@highlights_uri)
    request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043' 
    request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the request
    @highlights_response = http.request(request)
    @highlights = JSON.parse(@highlights_response.body)

    # Select only the verified highlight videos from MLB channel
    filtered_videos = @highlights["data"]
                        .select { |video| video["type"] == "VERIFIED" && video["channel"] == "MLB" }

    # Group by match ID and allow up to 1 videos per match
    grouped_videos = filtered_videos.group_by { |video| video["match"]["id"] }
    @highlight_videos = grouped_videos.flat_map { |_, videos| videos.first(1) }

    


    # Get NL standings
    @nl_standings_url = "https://sport-highlights-api.p.rapidapi.com/baseball/standings?abbreviation=NL&year=2024&leagueType=MLB"
    @nl_standings_uri = URI.parse(@nl_standings_url)

    # Set up the HTTP request
    http = Net::HTTP.new(@nl_standings_uri.host, @nl_standings_uri.port)
    http.use_ssl = true

    # Create the request with headers
    nl_request = Net::HTTP::Get.new(@nl_standings_uri)
    nl_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'
    nl_request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the request and parse the response
    @nl_standings_response = http.request(nl_request)
    @nl_standings_data = JSON.parse(@nl_standings_response.body)

    # Get AL standings
    @al_standings_url = "https://sport-highlights-api.p.rapidapi.com/baseball/standings?abbreviation=AL&year=2024&leagueType=MLB"
    @al_standings_uri = URI.parse(@al_standings_url)

    # Set up the HTTP request
    http = Net::HTTP.new(@al_standings_uri.host, @al_standings_uri.port)
    http.use_ssl = true

    # Create the request with headers
    al_request = Net::HTTP::Get.new(@al_standings_uri)
    al_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'
    al_request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the request and parse the response
    @al_standings_response = http.request(al_request)
    @al_standings_data = JSON.parse(@al_standings_response.body)



    @team_logos = {}

    # Combine AL and NL standings
    [@al_standings_data, @nl_standings_data].each do |standings_data|
      standings_data['data'].each do |division|
        division['data'].each do |team|
          @team_logos[team['name'].downcase] = team['logo']
        end
      end
    end


    # Get MLB news
    @news_url = "https://tank01-mlb-live-in-game-real-time-statistics.p.rapidapi.com/getMLBNews?topNews=true"
    @news_uri = URI.parse(@news_url)
    http = Net::HTTP.new(@news_uri.host, @news_uri.port)
    http.use_ssl = true

    # Create the request with headers
    news_request = Net::HTTP::Get.new(@news_uri)
    news_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043' 
    news_request["x-rapidapi-host"] = 'tank01-mlb-live-in-game-real-time-statistics.p.rapidapi.com'


    # Execute the request
    @news_response = http.request(news_request)
    @news = JSON.parse(@news_response.body)


  end


  
   def mls
    require 'net/http'
    require 'json'

    # Set up the URL
    @highlights_url = "https://sport-highlights-api.p.rapidapi.com/football/highlights?leagueName=Major%20League%20Soccer"
    @highlights_uri = URI.parse(@highlights_url)  # Parse the URL to create the URI

    # Set up the HTTP request
    http = Net::HTTP.new(@highlights_uri.host, @highlights_uri.port)
    http.use_ssl = true

    # Create the request with headers
    request = Net::HTTP::Get.new(@highlights_uri)
    request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'  
    request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the request
    @highlights_response = http.request(request)
    @highlights = JSON.parse(@highlights_response.body)

    # Select only the verified highlight videos and most recent 10
    @highlight_videos = @highlights["data"]
                     .select { |video| video["type"] == "VERIFIED" }


    # Get MLS standings
    @standings_url = "https://api-football-v1.p.rapidapi.com/v3/standings?league=253&season=2024"
    @standings_uri = URI.parse(@standings_url)  # Parse the URL to create the URI

    # Set up the MLS standings HTTP request
    http = Net::HTTP.new(@standings_uri.host, @standings_uri.port)
    http.use_ssl = true

    # Create the MLS standings request with headers
    standings_request = Net::HTTP::Get.new(@standings_uri)
    standings_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'  
    standings_request["x-rapidapi-host"] = 'api-football-v1.p.rapidapi.com'

    # Execute the MLS standings request
    @standings_response = http.request(standings_request)
    @standings_data = JSON.parse(@standings_response.body)

    # Organize standings into conferences 
    @eastern_conference_standings = []
    @western_conference_standings = []

    @standings_data['response'].each do |league|
      league['league']['standings'].each do |teams|
        teams.each do |team|
          if team['group'] == "Eastern Conference"
            @eastern_conference_standings << team
          elsif team['group'] == "Western Conference"
            @western_conference_standings << team
          end
        end
      end
    end

    # Get MLS news
    @news_url = "https://espn13.p.rapidapi.com/v1/soccer/league/news?league=usa.1"
    @news_uri = URI.parse(@news_url)
    http = Net::HTTP.new(@news_uri.host, @news_uri.port)
    http.use_ssl = true

    # Create the request with headers
    news_request = Net::HTTP::Get.new(@news_uri)
    news_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043' 
    news_request["x-rapidapi-host"] = 'espn13.p.rapidapi.com'


    # Execute the request
    @news_response = http.request(news_request)
    @news = JSON.parse(@news_response.body)

  end



  def nfl
    require 'net/http'
    require 'json'

    # Set up the URL
    @highlights_url = "https://sport-highlights-api.p.rapidapi.com/american-football/highlights?leagueName=NFL&season=2024"
    @highlights_uri = URI.parse(@highlights_url)  # Parse the URL to create the URI

    # Set up the HTTP request
    http = Net::HTTP.new(@highlights_uri.host, @highlights_uri.port)
    http.use_ssl = true

    # Create the request with headers
    request = Net::HTTP::Get.new(@highlights_uri)
    request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043' 
    request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the request
    @highlights_response = http.request(request)
    @highlights = JSON.parse(@highlights_response.body)

    # Filter out videos where channel is "NFL" and source is "youtube"
    filtered_videos = @highlights["data"]
                        .select { |video| video["type"] == "VERIFIED" }
                        .reject { |video| video["channel"] == "NFL" && video["source"] == "youtube" }

    # Group by match ID and allow up to 2 videos per match
    grouped_videos = filtered_videos.group_by { |video| video["match"]["id"] }
    limited_videos = grouped_videos.flat_map { |_, videos| videos.first(2) }

    # Sort by date and limit to 10 videos
    @highlight_videos = limited_videos.sort_by { |video| video["match"]["date"] }.reverse.first(10)
  

    # Get NFL standings
    @standings_url = "https://api-american-football.p.rapidapi.com/standings?league=1&season=2023"
    @standings_uri = URI.parse(@standings_url)

    standings_http = Net::HTTP.new(@standings_uri.host, @standings_uri.port)
    standings_http.use_ssl = true

    standings_request = Net::HTTP::Get.new(@standings_uri)
    standings_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'
    standings_request["x-rapidapi-host"] = 'api-american-football.p.rapidapi.com'
    
    @standings_response = http.request(standings_request)
    @standings_data = JSON.parse(@standings_response.body)

    # Initialize hash for AFC and NFC teams
    @afc_teams = {}
    @nfc_teams = {}

    # Group teams by conference and division
    @standings_data['response'].each do |team_data|
      conference = team_data['conference']
      division = team_data['division']
      team = team_data['team']
      
      if conference == 'American Football Conference'
        @afc_teams[division] ||= []
        @afc_teams[division] << team_data
      else
        @nfc_teams[division] ||= []
        @nfc_teams[division] << team_data
      end
    end

    @team_logos = {}

    @standings_data['response'].each do |team_info|
      team_name_parts = team_info['team']['name'].downcase.split
      team_name_key = team_name_parts.last # Use the last word as the key, e.g., "bills" from "Buffalo Bills"
      @team_logos[team_name_key] = team_info['team']['logo']
    end
  


    # Get NFL news
    @news_url = "https://tank01-nfl-live-in-game-real-time-statistics-nfl.p.rapidapi.com/getNFLNews?topNews=true"
    @news_uri = URI.parse(@news_url)
    http = Net::HTTP.new(@news_uri.host, @news_uri.port)
    http.use_ssl = true

    # Create the request with headers
    news_request = Net::HTTP::Get.new(@news_uri)
    news_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043' 
    news_request["x-rapidapi-host"] = 'tank01-nfl-live-in-game-real-time-statistics-nfl.p.rapidapi.com'


    # Execute the request
    @news_response = http.request(news_request)
    @news = JSON.parse(@news_response.body)





  end

  def nba
    require 'net/http'
    require 'json'

    # Set up the URL
    @highlights_url = "https://sport-highlights-api.p.rapidapi.com/basketball/highlights?leagueName=NBA"
    @highlights_uri = URI.parse(@highlights_url)  # Parse the URL to create the URI

    # Set up the HTTP request
    http = Net::HTTP.new(@highlights_uri.host, @highlights_uri.port)
    http.use_ssl = true

    # Create the request with headers
    request = Net::HTTP::Get.new(@highlights_uri)
    request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'  
    request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the request
    @highlights_response = http.request(request)
    @highlights = JSON.parse(@highlights_response.body)

    # Select only the verified highlight videos
    @highlight_videos = @highlights["data"]
                        .select { |video| video["type"] == "VERIFIED" }
                     



    # Fetch NBA standings data
    @standings_url = "https://sport-highlights-api.p.rapidapi.com/basketball/standings?leagueId=10996&season=2023"
    @standings_uri = URI.parse(@standings_url)

    standings_http = Net::HTTP.new(@standings_uri.host, @standings_uri.port)
    standings_http.use_ssl = true

    standings_request = Net::HTTP::Get.new(@standings_uri)
    standings_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'
    standings_request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'
    
    @standings_response = http.request(standings_request)
    @standings_data = JSON.parse(@standings_response.body)


    # Separate standings into conferences and divisions
    @western_conference = {
      'Northwest' => @standings_data['groups'].find { |group| group['name'] == 'Northwest' }['standings'],
      'Pacific' => @standings_data['groups'].find { |group| group['name'] == 'Pacific' }['standings'],
      'Southwest' => @standings_data['groups'].find { |group| group['name'] == 'Southwest' }['standings']
    }

    @eastern_conference = {
      'Atlantic' => @standings_data['groups'].find { |group| group['name'] == 'Atlantic' }['standings'],
      'Central' => @standings_data['groups'].find { |group| group['name'] == 'Central' }['standings'],
      'Southeast' => @standings_data['groups'].find { |group| group['name'] == 'Southeast' }['standings']
    }

    # Extract logos to use for news articles
    @team_logos = {}

    # Iterate through western conference divisions
    @western_conference.each_value do |division|
      division.each do |team|
        team_name = team['team']['name'].downcase
        # Extract the last word from the team name and store it in the hash
        @team_logos[team_name.split.last] = team['team']['logo']
      end
    end

    # Iterate through eastern conference divisions
    @eastern_conference.each_value do |division|
      division.each do |team|
        team_name = team['team']['name'].downcase
        # Extract the last word from the team name and store it in the hash
        @team_logos[team_name.split.last] = team['team']['logo']
      end
    end


    # Get NBA news
    @news_url = "https://tank01-fantasy-stats.p.rapidapi.com/getNBANews?topNews=true"
    @news_uri = URI.parse(@news_url)
    http = Net::HTTP.new(@news_uri.host, @news_uri.port)
    http.use_ssl = true

    # Create the request with headers
    news_request = Net::HTTP::Get.new(@news_uri)
    news_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043' 
    news_request["x-rapidapi-host"] = 'tank01-fantasy-stats.p.rapidapi.com'


    # Execute the request
    @news_response = http.request(news_request)
    @news = JSON.parse(@news_response.body)
    


  end



  def nhl
    require 'net/http'
    require 'json'

    # Set up the NHL highlights URL
    @highlights_url = "https://sport-highlights-api.p.rapidapi.com/hockey/highlights?&leagueName=NHL"
    @highlights_uri = URI.parse(@highlights_url)  # Parse the URL to create the URI

    # Set up the NHL highlihghts HTTP request
    http = Net::HTTP.new(@highlights_uri.host, @highlights_uri.port)
    http.use_ssl = true

    # Create the NHL highlights request with headers
    request = Net::HTTP::Get.new(@highlights_uri)
    request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'  
    request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the NHL highights request
    @highlights_response = http.request(request)
    @highlights = JSON.parse(@highlights_response.body)

    # Select only the verified highlight videos
    filtered_videos = @highlights["data"]
                        .select { |video| video["type"] == "VERIFIED" }

    # Group by match ID and allow up to 3 videos per match
    grouped_videos = filtered_videos.group_by { |video| video["match"]["id"] }
    @highlight_videos = grouped_videos.flat_map { |_, videos| videos.first(3) }


    # Get NHL standings
    @standings_url = "https://sport-highlights-api.p.rapidapi.com/hockey/standings?season=2023&leagueId=49291"
    @standings_uri = URI.parse(@standings_url)  # Parse the URL to create the URI

    # Set up the NHL standings HTTP request
    http = Net::HTTP.new(@standings_uri.host, @standings_uri.port)
    http.use_ssl = true

    # Create the NHL standings request with headers
    standings_request = Net::HTTP::Get.new(@standings_uri)
    standings_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'  
    standings_request["x-rapidapi-host"] = 'sport-highlights-api.p.rapidapi.com'

    # Execute the NHL standings request
    @standings_response = http.request(standings_request)
    @standings_data = JSON.parse(@standings_response.body)

    # Separate NHL standings into conferences and divisions
    @western_conference = {
      'Central' => @standings_data['groups'].find { |group| group['name'] == 'Central' }['standings'],
      'Pacific' => @standings_data['groups'].find { |group| group['name'] == 'Pacific' }['standings']
    }

    @eastern_conference = {
      'Atlantic' => @standings_data['groups'].find { |group| group['name'] == 'Atlantic' }['standings'],
      'Metropolitan' => @standings_data['groups'].find { |group| group['name'] == 'Metropolitan' }['standings']
    }

    # Extract NHL logos to use for news stories
    @team_logos = {}

    @standings_data['groups'].each do |group|
      group['standings'].each do |team|
        team_name_parts = team['team']['name'].split(' ')
        simple_name = team_name_parts.last.downcase  # Extract the last word
        @team_logos[simple_name] = team['team']['logo']
      end
    end


    # Get NHL news
    @news_url = "https://tank01-nhl-live-in-game-real-time-statistics-nhl.p.rapidapi.com/getNHLNews?topNews=true"
    @news_uri = URI.parse(@news_url)
    http = Net::HTTP.new(@news_uri.host, @news_uri.port)
    http.use_ssl = true

    # Create the NHL news request with headers
    news_request = Net::HTTP::Get.new(@news_uri)
    news_request["x-rapidapi-key"] = '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043' 
    news_request["x-rapidapi-host"] = 'tank01-nhl-live-in-game-real-time-statistics-nhl.p.rapidapi.com'


    # Execute the NHL news request
    @news_response = http.request(news_request)
    @news = JSON.parse(@news_response.body)




  end
end