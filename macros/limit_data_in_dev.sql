{% macro limit_data_in_dev(column_name, dev_days_of_data=3) -%}
    {% if target.name == 'demo' -%} -- Use your current target name here. Usually, use 'dev' instead of 'prod' to limit data in dev.
    WHERE {{ column_name }} >= date_add(CAST(current_timestamp AS DATE), INTERVAL -{{ dev_days_of_data }} DAY) -- date_add() as BigQuery flavor        
    {%- endif %}
{%- endmacro %}