# Sass::Plugin.options[:property_syntax] = :old
Sass::Plugin.remove_template_location("./public/stylesheets/generated")
Sass::Plugin.add_template_location("./app/stylesheets")
Sass::Plugin.options[:always_update] = true