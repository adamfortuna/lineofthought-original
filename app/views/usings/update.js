$("#using_<%= @using.id %> div.edit-in-place-show p").html("<%= @using.description %>");
$("#using_<%= @using.id %>").removeClass("editing");