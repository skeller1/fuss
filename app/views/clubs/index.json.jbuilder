json.array!(@clubs) do |club|
  json.extract! club, :url, :uid, :infos
  json.url club_url(club, format: :json)
end
