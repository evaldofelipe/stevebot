# Description:
#   Get clients dev info
#
# Commands:
#   steve info <client name>

module.exports = (robot) ->
  robot.hear /(info) (.*)/i, (msg) ->
    cliente = msg.match[2]

    robot.http("https://docs.google.com/spreadsheets/REMAINING_URL_HERE/pub?output=csv")
    .get() (err, res, body) ->
      if err
        res.send "Encountered an error :( #{err}"
        return

      clienteUrl = ""
      arr = CSVToArray(body, ",")
      response = ""
      i = 0
      found = false

      while i < arr.length
        currentline = arr[i]
        if currentline[0] == cliente
          clienteUrl = currentline[1]
          found = true
        i++

      if !found
        response = "Client not found :("
        msg.send response
        return
      else
        robot.http(clienteUrl)
        .get() (err, res, body) ->
          if err
            res.send "Encountered an error :( #{err}"
            return

          response = ""
          j = 0

          arr = CSVToArray(body, ",")

          while j < arr.length
            currentline = arr[j]
            if currentline[0]
              if currentline[1]
                response += "*" + currentline[0] + ":* " + currentline[1] + "\n"
              else
                response += "*" + currentline[0] + "*" + "\n"
            else
              response += "\n"
            j++

          msg.send response
          return

CSVToArray = (strData, strDelimiter) ->
  # Check to see if the delimiter is defined. If not,
  # then default to comma.
  strDelimiter = strDelimiter or ','
  # Create a regular expression to parse the CSV values.
  objPattern = new RegExp('(\\' + strDelimiter + '|\\r?\\n|\\r|^)' + '(?:"([^"]*(?:""[^"]*)*)"|' + '([^"\\' + strDelimiter + '\\r\\n]*))', 'gi')
  # Create an array to hold our data. Give the array
  # a default empty first row.
  arrData = [ [] ]
  # Create an array to hold our individual pattern
  # matching groups.
  arrMatches = null
  # Keep looping over the regular expression matches
  # until we can no longer find a match.
  while arrMatches = objPattern.exec(strData)
    # Get the delimiter that was found.
    strMatchedDelimiter = arrMatches[1]
    # Check to see if the given delimiter has a length
    # (is not the start of string) and if it matches
    # field delimiter. If id does not, then we know
    # that this delimiter is a row delimiter.
    if strMatchedDelimiter.length and strMatchedDelimiter != strDelimiter
      # Since we have reached a new row of data,
      # add an empty row to our data array.
      arrData.push []
    strMatchedValue = undefined
    # Now that we have our delimiter out of the way,
    # let's check to see which kind of value we
    # captured (quoted or unquoted).
    if arrMatches[2]
      # We found a quoted value. When we capture
      # this value, unescape any double quotes.
      strMatchedValue = arrMatches[2].replace(new RegExp('""', 'g'), '"')
    else
      # We found a non-quoted value.
      strMatchedValue = arrMatches[3]
    # Now that we have our value string, let's add
    # it to the data array.
    arrData[arrData.length - 1].push strMatchedValue
  # Return the parsed data.
  arrData
