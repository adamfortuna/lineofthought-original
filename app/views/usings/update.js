<% if @using.description.blank? %>
  $("#using_<%= @using.id %> p.about").show();
  $("#using_<%= @using.id %> p.edit-in-place-show").hide();
<% else %>
  $("#using_<%= @using.id %> p.edit-in-place-show").html("<%= @using.description %>").show();
  $("#using_<%= @using.id %> p.about").hide();
<% end %>
$("#using_<%= @using.id %>").removeClass("editing");