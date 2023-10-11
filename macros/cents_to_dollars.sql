{% macro cents_to_dollars(column_name, decimal_places=2) -%}
    ROUND(1.0 * {{ column_name }} / 100, {{ decimal_places }})
{%- endmacro %}
