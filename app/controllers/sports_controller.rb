require 'net/http'
require 'json'

class SportsController < ApplicationController

  def api_key
    ENV['RAPIDAPI_KEY'] || '735c9c799cmsh835db47dc1659d0p11670ajsn00e85e682043'
  end


  def fetch_api_data(uri, headers)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    headers.each { |key, value| request[key] = value }

    response = http.request(request)
    JSON.parse(response.body)
  end


  ###################################################
  ################ MLB METHODS ######################
  ###################################################

  def mlb
    season = Time.now.year

    @highlight_videos = get_mlb_highlights(season)
    @standings_data = get_mlb_standings(season)
    @team_logos = @standings_data[:team_logos]
    @news = fetch_mlb_news

  end


  def get_mlb_highlights(season)
    highlights = fetch_mlb_highlights(season)
    
    if highlights.empty?
      previous_year = season - 1
      highlights = fetch_mlb_highlights(previous_year)
    end

    highlights
  end

  def fetch_mlb_highlights(season)
    highlights_url = "https://sport-highlights-api.p.rapidapi.com/baseball/highlights?leagueName=MLB&season=#{season}"
    highlights_uri = URI.parse(highlights_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    highlights_data = fetch_api_data(highlights_uri, headers)
    
    # Return an array of verified videos from MLB channel or an empty array if no videos found
    filtered_videos = highlights_data["data"]&.select { |video| video["type"] == "VERIFIED" && video["channel"] == "MLB" } || []

    # Group by match ID and allow up to 1 video per match
    grouped_videos = filtered_videos.group_by { |video| video["match"]["id"] }
    grouped_videos.flat_map { |_, videos| videos.first(1) }
  end


  def get_mlb_standings(season)
    standings_data = fetch_mlb_standings(season)

    if standings_data[:team_logos].empty?
      previous_year = season - 1
      standings_data = fetch_mlb_standings(previous_year)
    end

    standings_data
  end

  def fetch_mlb_standings(season)
    @al_standings_data = fetch_standings_for_league("AL", season)
    @nl_standings_data = fetch_standings_for_league("NL", season)

    group_mlb_standings(@al_standings_data, @nl_standings_data)
  end

  def group_mlb_standings(al_standings_data, nl_standings_data)
    team_logos = {}
    standings = { al: {}, nl: {} }

    [{ league: :al, data: @al_standings_data }, { league: :nl, data: @nl_standings_data }].each do |league_data|
      if league_data[:data].present? && league_data[:data]['data'].present?
        league_data[:data]['data'].each do |division|
          division_name = division['divisionName'] || "Unknown Division"
          standings[league_data[:league]][division_name] = division['data']

          division['data'].each do |team|
            team_logos[team['name'].downcase] = team['logo']
          end
        end
      end
    end

    { standings: standings, team_logos: team_logos }
  end


  def fetch_standings_for_league(league, season)
    standings_url = "https://sport-highlights-api.p.rapidapi.com/baseball/standings?abbreviation=#{league}&year=#{season}&leagueType=MLB"
    standings_uri = URI.parse(standings_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    fetch_api_data(standings_uri, headers)
  end

  def fetch_mlb_news
    news_url = "https://tank01-mlb-live-in-game-real-time-statistics.p.rapidapi.com/getMLBNews?topNews=true"
    news_uri = URI.parse(news_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'tank01-mlb-live-in-game-real-time-statistics.p.rapidapi.com'
    }

    fetch_api_data(news_uri, headers)
  end


  ###################################################
  ################ MLB METHODS ######################
  ###################################################
  
  def mls
    season = Time.now.year

    @highlight_videos = fetch_mls_highlights
    @standings_data = get_mls_standings(season)
    @eastern_conference_standings = @standings_data[:eastern_conference]
    @western_conference_standings = @standings_data[:western_conference]
    @news = fetch_mls_news
  end

  def fetch_mls_highlights
    highlights_url = "https://sport-highlights-api.p.rapidapi.com/football/highlights?leagueName=Major%20League%20Soccer"
    highlights_uri = URI.parse(highlights_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    highlights_data = fetch_api_data(highlights_uri, headers)
    
    highlights_data["data"]&.select { |video| video["type"] == "VERIFIED" } || []
  end


  def get_mls_standings(season)
    standings_data = fetch_mls_standings(season)

    if standings_data[:eastern_conference].empty? && standings_data[:western_conference].empty?
      previous_year = season - 1
      standings_data = fetch_mls_standings(previous_year)
    end

    standings_data
  end

  def fetch_mls_standings(season)
    standings_url = "https://api-football-v1.p.rapidapi.com/v3/standings?league=253&season=#{season}"
    standings_uri = URI.parse(standings_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'api-football-v1.p.rapidapi.com'
    }

    standings_data = fetch_api_data(standings_uri, headers)
    organize_mls_standings(standings_data)
  end

  def organize_mls_standings(standings_data)
    eastern_conference = []
    western_conference = []

    standings_data['response'].each do |league|
      league['league']['standings'].each do |teams|
        teams.each do |team|
          if team['group'] == "Eastern Conference"
            eastern_conference << team
          elsif team['group'] == "Western Conference"
            western_conference << team
          end
        end
      end
    end

    { eastern_conference: eastern_conference, western_conference: western_conference }
  end


  def fetch_mls_news
    news_url = "https://espn13.p.rapidapi.com/v1/soccer/league/news?league=usa.1"
    news_uri = URI.parse(news_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'espn13.p.rapidapi.com'
    }

    fetch_api_data(news_uri, headers)
  end



  ###################################################
  ################ NFL METHODS ######################
  ###################################################

  def nfl
    require 'net/http'
    require 'json'
    season = Time.now.year

    @highlight_videos = get_nfl_highlights(season)
    @standings_data = get_nfl_standings(season)
    @afc_teams = @standings_data[:afc_teams]
    @nfc_teams = @standings_data[:nfc_teams]
    @team_logos = @standings_data[:team_logos]
    @news = fetch_nfl_news
  end

  def get_nfl_highlights(season) 
    highlights = fetch_nfl_highlights(season)
    
    if highlights.empty?
      previous_year = season - 1
      highlights = fetch_nfl_highlights(previous_year)
    end

    highlights
  end


  def fetch_nfl_highlights(season)
    highlights_url = "https://sport-highlights-api.p.rapidapi.com/american-football/highlights?leagueName=NFL&season=#{season}"
    highlights_uri = URI.parse(highlights_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    highlights_data = fetch_api_data(highlights_uri, headers)
    filter_and_group_highlights(highlights_data)
  end


  def filter_and_group_highlights(highlights_data)
    filtered_videos = highlights_data["data"]
                         .select { |video| video["type"] == "VERIFIED" }
                         .reject { |video| video["channel"] == "NFL" && video["source"] == "youtube" }

    grouped_videos = filtered_videos.group_by { |video| video["match"]["id"] }
    limited_videos = grouped_videos.flat_map { |_, videos| videos.first(2) }

    limited_videos.sort_by { |video| video["match"]["date"] }.reverse.first(10)
  end

  def get_nfl_standings(season)
    @standings_data = fetch_nfl_standings(season)

    # If the response is empty or no data for the current year, try the previous year
    if @standings_data[:afc_teams].empty? && @standings_data[:nfc_teams].empty?
      previous_year = season - 1
      @standings_data = fetch_nfl_standings(previous_year)
    end

    @standings_data
  end

  def fetch_nfl_standings(season)
    standings_url = "https://api-american-football.p.rapidapi.com/standings?league=1&season=#{season}"
    standings_uri = URI.parse(standings_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'api-american-football.p.rapidapi.com'
    }

    standings_data = fetch_api_data(standings_uri, headers)
    group_teams_by_conference_and_division(standings_data)
  end

  def group_teams_by_conference_and_division(standings_data)
    afc_teams = {}
    nfc_teams = {}
    team_logos = {}

    standings_data['response'].each do |team_data|
      conference = team_data['conference']
      division = team_data['division']
      team = team_data['team']

      if conference == 'American Football Conference'
        afc_teams[division] ||= []
        afc_teams[division] << team_data
      else
        nfc_teams[division] ||= []
        nfc_teams[division] << team_data
      end

      team_name_parts = team['name'].downcase.split
      team_name_key = team_name_parts.last
      team_logos[team_name_key] = team['logo']
    end

    { afc_teams: afc_teams, nfc_teams: nfc_teams, team_logos: team_logos }
  end

  def fetch_nfl_news
    news_url = "https://tank01-nfl-live-in-game-real-time-statistics-nfl.p.rapidapi.com/getNFLNews?topNews=true"
    news_uri = URI.parse(news_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'tank01-nfl-live-in-game-real-time-statistics-nfl.p.rapidapi.com'
    }

    fetch_api_data(news_uri, headers)
  end


  ###################################################
  ################ NBA METHODS ######################
  ###################################################

  def nba
    
    season = Time.now.year
    @highlight_videos = get_nba_highlights(season)
    @standings_data = get_nba_standings(season)
    @western_conference = @standings_data[:western_conference]
    @eastern_conference = @standings_data[:eastern_conference]
    @team_logos = @standings_data[:team_logos]
    @news = fetch_nba_news
  end

  def get_nba_highlights(season) 
    highlights = fetch_nba_highlights(season)
    
    if highlights.empty?
      previous_year = season - 1
      highlights = get_nba_highlights(previous_year)
    end

    highlights
  end

  def fetch_nba_highlights(season)
    highlights_url = "https://sport-highlights-api.p.rapidapi.com/basketball/highlights?leagueName=NBA&season=#{season}"
    highlights_uri = URI.parse(highlights_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    highlights_data = fetch_api_data(highlights_uri, headers)
    highlights_data["data"].select { |video| video["type"] == "VERIFIED" }
  end


  def get_nba_standings(season)
    standings_data = fetch_nba_standings(season)

    if standings_data[:western_conference].empty? && standings_data[:eastern_conference].empty?
      previous_year = season - 1
      standings_data = fetch_nba_standings(previous_year)
    end

    standings_data
  end

  def fetch_nba_standings(season)
    standings_url = "https://sport-highlights-api.p.rapidapi.com/basketball/standings?leagueId=10996&season=#{season}"
    standings_uri = URI.parse(standings_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    standings_data = fetch_api_data(standings_uri, headers)
    group_nba_standings(standings_data)
  end

  def group_nba_standings(standings_data)
    return { western_conference: {}, eastern_conference: {}, team_logos: {} } unless standings_data['groups']

    western_conference = {
      'Northwest' => standings_data['groups'].find { |group| group['name'] == 'Northwest' }&.fetch('standings', []),
      'Pacific' => standings_data['groups'].find { |group| group['name'] == 'Pacific' }&.fetch('standings', []),
      'Southwest' => standings_data['groups'].find { |group| group['name'] == 'Southwest' }&.fetch('standings', [])
    }

    eastern_conference = {
      'Atlantic' => standings_data['groups'].find { |group| group['name'] == 'Atlantic' }&.fetch('standings', []),
      'Central' => standings_data['groups'].find { |group| group['name'] == 'Central' }&.fetch('standings', []),
      'Southeast' => standings_data['groups'].find { |group| group['name'] == 'Southeast' }&.fetch('standings', [])
    }

    team_logos = {}
    [western_conference, eastern_conference].each do |conference|
      conference.each_value do |division|
        division.each do |team|
          team_name = team['team']['name'].downcase
          team_logos[team_name.split.last] = team['team']['logo']
        end
      end
    end

    { western_conference: western_conference, eastern_conference: eastern_conference, team_logos: team_logos }
  end


  def fetch_nba_news
    news_url = "https://tank01-fantasy-stats.p.rapidapi.com/getNBANews?topNews=true"
    news_uri = URI.parse(news_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'tank01-fantasy-stats.p.rapidapi.com'
    }

    fetch_api_data(news_uri, headers)
  end


  ###################################################
  ################ NHL METHODS ######################
  ###################################################


  def nhl
    season = Time.now.year

    @highlight_videos = get_nhl_highlights(season)
    @standings_data = get_nhl_standings(season)
    @western_conference = @standings_data[:western_conference]
    @eastern_conference = @standings_data[:eastern_conference]
    @team_logos = @standings_data[:team_logos]
    @news = fetch_nhl_news
  end


  def get_nhl_highlights(season)
    highlights = fetch_nhl_highlights(season)
    
    if highlights.empty?
      previous_year = season - 1
      highlights = fetch_nhl_highlights(previous_year)
    end

    highlights
  end

  def fetch_nhl_highlights(season)
    highlights_url = "https://sport-highlights-api.p.rapidapi.com/hockey/highlights?leagueName=NHL&season=#{season}"
    highlights_uri = URI.parse(highlights_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    highlights_data = fetch_api_data(highlights_uri, headers)
    
    # Return an array of verified videos or an empty array if no videos found
    filtered_videos = highlights_data["data"]&.select { |video| video["type"] == "VERIFIED" } || []

    # Group by match ID and allow up to 3 videos per match
    grouped_videos = filtered_videos.group_by { |video| video["match"]["id"] }
    grouped_videos.flat_map { |_, videos| videos.first(3) }
  end


  def get_nhl_standings(season)
    standings_data = fetch_nhl_standings(season)

    if standings_data[:western_conference].empty? && standings_data[:eastern_conference].empty?
      previous_year = season - 1
      standings_data = fetch_nhl_standings(previous_year)
    end

    standings_data
  end

  def fetch_nhl_standings(season)
    standings_url = "https://sport-highlights-api.p.rapidapi.com/hockey/standings?season=#{season}&leagueId=49291"
    standings_uri = URI.parse(standings_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'sport-highlights-api.p.rapidapi.com'
    }

    standings_data = fetch_api_data(standings_uri, headers)
    group_nhl_standings(standings_data)
  end

  def group_nhl_standings(standings_data)
    return { western_conference: {}, eastern_conference: {}, team_logos: {} } unless standings_data['groups']

    western_conference = {
      'Central' => standings_data['groups'].find { |group| group['name'] == 'Central' }&.fetch('standings', []),
      'Pacific' => standings_data['groups'].find { |group| group['name'] == 'Pacific' }&.fetch('standings', [])
    }

    eastern_conference = {
      'Atlantic' => standings_data['groups'].find { |group| group['name'] == 'Atlantic' }&.fetch('standings', []),
      'Metropolitan' => standings_data['groups'].find { |group| group['name'] == 'Metropolitan' }&.fetch('standings', [])
    }

    team_logos = {}
    [western_conference, eastern_conference].each do |conference|
      conference.each_value do |division|
        division.each do |team|
          team_name = team['team']['name'].downcase
          team_logos[team_name.split.last] = team['team']['logo']
        end
      end
    end

    { western_conference: western_conference, eastern_conference: eastern_conference, team_logos: team_logos }
  end


  def fetch_nhl_news
    news_url = "https://tank01-nhl-live-in-game-real-time-statistics-nhl.p.rapidapi.com/getNHLNews?topNews=true"
    news_uri = URI.parse(news_url)
    headers = {
      "x-rapidapi-key" => api_key,
      "x-rapidapi-host" => 'tank01-nhl-live-in-game-real-time-statistics-nhl.p.rapidapi.com'
    }

    fetch_api_data(news_uri, headers)
  end

end



