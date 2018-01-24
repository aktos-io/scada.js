export vdiff = (left, right) ->
    left = encodeURIComponent JSON.stringify left
    right = encodeURIComponent JSON.stringify right
    return "http://benjamine.github.io/jsondiffpatch/demo/index.html?desc=left..right&left=#{left}&right=#{right}"
