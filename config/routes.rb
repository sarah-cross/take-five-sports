Rails.application.routes.draw do
  root "sports#mlb"

  get '/sports', to: redirect('/sports/mlb')

  # Define routes for each sport
  get "sports/mls", to: "sports#mls", as: "mls"
  get "sports/nfl", to: "sports#nfl", as: "nfl"
  get "sports/nba", to: "sports#nba", as: "nba"
  get "sports/mlb", to: "sports#mlb", as: "mlb"
  get "sports/nhl", to: "sports#nhl", as: "nhl"
end
