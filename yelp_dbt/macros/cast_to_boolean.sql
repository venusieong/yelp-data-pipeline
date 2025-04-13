{% macro cast_to_boolean(field_name) %}
    case lower({{ field_name }})
        when 'true' then true
        when 'false' then false
        else null
    end
{% endmacro %}
