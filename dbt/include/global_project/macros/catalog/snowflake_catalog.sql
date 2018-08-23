
{% macro snowflake__get_catalog() -%}

    {%- call statement('catalog', fetch_result=True) -%}

    with tables as (

        select
            table_schema as "table_schema",
            table_name as "table_name",
            table_type as "table_type",

            -- note: this is the _role_ that owns the table
            table_owner as "table_owner",

            'Clustering Key' as "stats:clustering_key:label",
            clustering_key as "stats:clustering_key:value",
            'The key used to cluster this table' as "stats:clustering_key:description",
            (clustering_key is not null) as "stats:clustering_key:include",

            'Row Count' as "stats:row_count:label",
            row_count as "stats:row_count:value",
            'An approximate count of rows in this table' as "stats:row_count:description",
            (row_count is not null) as "stats:row_count:include",

            'Approximate Size' as "stats:bytes:label",
            bytes as "stats:bytes:value",
            'Approximate size of the table as reported by Snowflake' as "stats:bytes:description",
            (bytes is not null) as "stats:bytes:include"

        from information_schema.tables

    ),

    columns as (

        select

            table_schema as "table_schema",
            table_name as "table_name",
            null as "table_comment",

            column_name as "column_name",
            ordinal_position as "column_index",
            data_type as "column_type",
            null as "column_comment"

        from information_schema.columns

    )

    select *
    from tables
    join columns using ("table_schema", "table_name")
    where "table_schema" != 'INFORMATION_SCHEMA'
    order by "column_index"

  {%- endcall -%}

  {{ return(load_result('catalog').table) }}

{%- endmacro %}
