function onInit()
end

function contains(set, item)
	for i = 1, #set do
		if set[i] == item then
			return true;
		end
	end
	return false;
end

function addIfUnique(set, item)
    if not contains(set, item) then
        table.insert(set, item);
    end
end

function intersects(compareSet, actualSet)
	for i = 1, #actualSet do
		if containsExact(compareSet, actualSet[i]) then
			return true;
		end
	end
	return false
end

function escapeCSV (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

function fromCSV (s)
  s = s .. ','        -- ending comma
  local t = {}        -- table to collect fields
  local fieldstart = 1
  repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
      local a, c
      local i  = fieldstart
      repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
      until c ~= '"'    -- quote not followed by quote?
      if not i then error('unmatched "') end
      local f = string.sub(s, fieldstart+1, i-1)
      table.insert(t, (string.gsub(f, '""', '"')))
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, ',', fieldstart)
      table.insert(t, string.sub(s, fieldstart, nexti-1))
      fieldstart = nexti + 1
    end
  until fieldstart > string.len(s)
  return t
end

function toCSV (tt)
    if not (tt) then return ""; end
    local s = ""
    for _,p in ipairs(tt) do  
    s = s .. "," .. escapeCSV(p)
    end
    return string.sub(s, 2)      -- remove first comma
end
