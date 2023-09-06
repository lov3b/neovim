function isNightTime()
  local hour = tonumber(os.date("%H"));
  return hour >= 20 or hour <= 6;
end
