function htmlEncode ( html )
{
    html = $.trim(html);
    return html.replace(/[&"'\<\>]/g, function(c)
    {
          switch (c)
          {
              case "&":
                return "&amp;";
              case "'":
                return "&#39;";
              case '"':
                return "&quot;";
              case "<":
                return "&lt;";
              default:
                return "&gt;";
          }
    });
};
window.loadingError = function(err){
    if(err){
        document.getElementById("errorSection").style.display = 'block';
        document.getElementById("errorMessage").innerHTML = htmlEncode(err);
    }
}
