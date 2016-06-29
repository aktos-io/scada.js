(function($){
    $(function(){
      $.ajax({
          url: 'components.html',
          dataType: "text",
          success: function(data){
              $("#components").html(data);
          }
      })
    });
})(jQuery)
