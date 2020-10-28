function onInit()
end

function isEmpty(s)
  return s == nil or s == '';
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

function getIntersecting(set1, set2)
  local aIntersecting = {};
  for i = 1, #set1 do
    if contains(set2, set1[i]) then
      table.insert(aIntersecting, set1[i]);
    end
  end
  return aIntersecting; 
end

function intersects(compareSet, actualSet)
	for i = 1, #actualSet do
		if contains(compareSet, actualSet[i]) then
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
  if not s then return {}; end;
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
      local sTrimmed = StringManager.trim((string.gsub(f, '""', '"')))
      table.insert(t, sTrimmed)
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, ',', fieldstart)
      local sTrimmed = StringManager.trim(string.sub(s, fieldstart, nexti-1))
      table.insert(t, sTrimmed)
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

function reduce(tt, reduceFn)
  local acc;
  for k, v in ipairs(tt) do
    if 1 == k then
      acc = v;
    else
      acc = reduceFn(acc, v);
    end
  end
  return acc;

end

function sum(tt)
  if not tt or #tt == 0 then
    return 0;
  end
  local nSum = reduce(tt, function(a, b) return a + b; end);
  return nSum;
end

function average(tt)
  if not tt or #tt == 0 then
    return 0;
  end

  return sum(tt) / #tt;
end

