json.array!(@teams) do |team|
  json.extract! team, :url, :name
  json.url team_url(team, format: :json)
end
