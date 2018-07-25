# Returns an array of used variable names in the template 
export get-vars = (template) ->
  search = (tpl, vars=[]) !->
    for k, v of tpl
      if typeof v is \object
        if v.t is 2
          #console.log "got variable", v.r
          vars.push v.r
        # search recursively
        search v, vars
    return vars
  return search template
