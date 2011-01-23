$(function() {
  $("#sorting .change_sorting").click(function() {
    $('#sorting .options').toggle();
    if($(this).hasClass("active")) {
      $(this).removeClass("active");
    } else {
      $(this).addClass("active");
    }
  });
  
  $("#s").focus(function(e) {
    toggleLabel(this, false);
  }).blur(function(e) {
    toggleLabel(this, true);
  });
});


function toggleLabel(element, show) {
  var label = $(element).parent().find("label");
  show && $(element).val() == '' ? $(label).show() : $(label).hide();
}