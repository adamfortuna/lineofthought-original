$(function() {
  $("#sorting .change_sorting").click(function() {
    $('#sorting .options').toggle();
    if($(this).hasClass("active")) {
      $(this).removeClass("active");
    } else {
      $(this).addClass("active");
    }
    return false;
  });
});

function reset_new_using_form() {
  $('#new_using')[0].reset();
  $("#using_tool_id, #using_site_id").val("");
  $("#using_tool_name, #using_site_title").css({ "background": "url(/images/placeholder.jpg) no-repeat 4px 4px"});
  $('#using_tool_url, #using_site_url').removeAttr("disabled");
  $('li.tool_name_autocomplete .inline-hints').hide().hide();
}

var cache = {}, lastXhr;
function using_tool_autocomplete(autocomplete_path, scope) {
  scope = scope || "#using_";
  
	$(scope+ "_tool_name").autocomplete({
		minLength: 1,
		source: function(request, response) {
			var term = request.term;
			if (term in cache) {
				response(cache[term]);
				return;
			}

      $(scope+ "_tool_name").css({ "background": "url(/images/indicator.gif) no-repeat 4px 4px"});
      $("li.tool_name_autocomplete label").addClass("loading");
			lastXhr = $.getJSON(autocomplete_path, request, function(data, status, xhr) {
				cache[term] = data;
				if (xhr === lastXhr) {
					response(data);
				}
			});
		},
		focus: function(event, ui) {
			$(scope+ "_tool_name").val(ui.item.name);
			return false;
		},
		select: function(event, ui) {
			$(scope + "_tool_name").val(ui.item.name).css({ "background": "url("+ui.item.icon+") no-repeat 4px 4px"});
			$(scope + "_tool_id").val(ui.item.id);
			$("li.tool_name_autocomplete .inline-hints").html(ui.item.categories).show();
			$(scope + "_tool_url").addClass("found").val(ui.item.url).attr("disabled", "disabled");
			return false;
		}
	});
	
	$.ui.autocomplete.prototype._response = function(content) {
	  $(scope + "_tool_name").css({ "background": "url(/images/placeholder.jpg) no-repeat 4px 4px"});
		if ( !this.options.disabled && content && content.length ) {
			content = this._normalize( content );
			this._suggest( content );
			this._trigger("open");
		} else {
		  $(scope + "_tool_id").val("");
		  $(scope + "_tool_url").removeAttr("disabled").val("");
			this.close();
		}
		this.pending--;
		if ( !this.pending ) {
			this.element.removeClass( "ui-autocomplete-loading" );
		}
	};
	
	$.ui.autocomplete.prototype._renderItem = function( ul, item ) {
	  var icon = "";
	  $(scope + "_tool_name").css({ "background": "url(/images/placeholder.jpg) no-repeat 4px 4px"});
	  if(item.icon != "" && item.icon != null) { 
	    icon = "<img src='"+item.icon+"' />";
	  } else { 
	    icon = "<img src='/images/placeholder.jpg' />";
	  }
		return $("<li></li>")
			.data("item.autocomplete", item)
			.append("<a>" + icon + item.name + "<br>" + item.url + "</a>")
			.appendTo(ul);
	};

	$("#reset_button").click(function(e) {
    reset_new_using_form();
    e.preventDefault();
    return false;
  });
}

function using_site_autocomplete(autocomplete_path, scope) {
  scope = scope || "#using_";
  
	$(scope+ "_site_title").autocomplete({
		minLength: 1,
		source: function(request, response) {
			var term = request.term;
			if (term in cache) {
				response(cache[term]);
				return;
			}

      $(scope+ "_site_title").css({ "background": "url(/images/indicator.gif) no-repeat 4px 4px"});
      $("li.site_title_autocomplete label").addClass("loading");
			lastXhr = $.getJSON(autocomplete_path, request, function(data, status, xhr) {
				cache[term] = data;
				if (xhr === lastXhr) {
					response(data);
				}
			});
		},
		focus: function(event, ui) {
			$(scope+ "_site_title").val(ui.item.title);
			return false;
		},
		select: function(event, ui) {
			$(scope + "_site_title").val(ui.item.title).css({ "background": "url("+ui.item.icon+") no-repeat 4px 4px"});
			$(scope + "_site_id").val(ui.item.id);
			$(scope + "_site_url").addClass("found").val(ui.item.url).attr("disabled", "disabled");
			return false;
		}
	});
	
	$.ui.autocomplete.prototype._response = function(content) {
	  $(scope + "_site_title").css({ "background": "url(/images/placeholder.jpg) no-repeat 4px 4px"});
		if ( !this.options.disabled && content && content.length ) {
			content = this._normalize( content );
			this._suggest( content );
			this._trigger("open");
		} else {
		  $(scope + "_site_id").val("");
		  $(scope + "_site_url").removeAttr("disabled").val("");
			this.close();
		}
		this.pending--;
		if ( !this.pending ) {
			this.element.removeClass( "ui-autocomplete-loading" );
		}
	};
	
	$.ui.autocomplete.prototype._renderItem = function( ul, item ) {
	  var icon = "";
	  $(scope + "_site_title").css({ "background": "url(/images/placeholder.jpg) no-repeat 4px 4px"});
	  if(item.icon != "" && item.icon != null) { 
	    icon = "<img src='"+item.icon+"' />";
	  } else { 
	    icon = "<img src='/images/placeholder.jpg' />";
	  }
		return $("<li></li>")
			.data("item.autocomplete", item)
			.append("<a>" + icon + item.title + "<br>" + item.url + "</a>")
			.appendTo(ul);
	};

	$("#reset_button").click(function(e) {
    reset_new_using_form();
    e.preventDefault();
    return false;
  });
}

function edit_in_place() {
  $('.edit-in-place-edit').live("click", function() {
    $(this).parents('.edit-in-place').addClass('editing');
    return false;
  });
  $('.edit-in-place-cancel, .edit-in-place-cancel a').live("click", function() {
    $(this).parents('.edit-in-place').removeClass('editing');
    $(this).parents('.edit-in-place').find(".edit-in-place-edit").show();
    return false;
  }); 
}