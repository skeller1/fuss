json.array!(@matches) do |match|
  json.extract! match, :match_date, :match_id, :home, :visitor, :goals_home, :goals_visitor
  json.url match_url(match, format: :json)
end
