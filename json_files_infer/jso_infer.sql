create or replace stage json_stg;

list @json_stg;

drop schema  study_sql
create or replace database json_db;
create or replace schema my_schema;
use database my_schema;
SELECT CURRENT_SCHEMA();
drop  file format  json_file_format;
-- creating a json file format
create or replace file format json_file_format 
    type = 'JSON'
    STRIP_OUTER_ARRAY = true;

create or replace stage json_stg;
    -- run infer schema and check the data type
select * from table(infer_schema(
    location => '@json_stg/' ,
    files => 'simple_emp_single_entity.json',
    file_format=>'json_file_format',
    ignore_case => true

));


create or replace file format json_file_format_outer_array_false 
    type = 'JSON'
    STRIP_OUTER_ARRAY = true;

    -- lets run it for emp_json_with_array.json
select * from table(infer_schema(
    location => '@json_stg/' ,
    files => 'emp_json_with_array.json',
    file_format=>'json_file_format_outer_array_false'
));



-- lets run it for emp_json_with_array.json
select * from table(infer_schema(
    location => '@json_stg' ,
    files => 'emp_json_with_dic.json',
    file_format=>'json_file_format'
));


-- lets run it for emp_json_with_newline.json
select * from table(infer_schema(
    location => '@json_stg/' ,
    files => 'emp_json_with_comma.json',
    file_format=>'json_file_format'
));



select * from table(infer_schema(
    location => '@json_stg/' ,
    files => 'emp_json_with_newline.json',
    file_format=>'json_file_format'
));


-- lets create a table using template keyword
create or replace transient table emp_01
using template (
                select array_agg(object_construct(*)) from table(
                    infer_schema(
                        location => '@json_stg/' ,
                        files => 'simple_emp_single_entity.json',
                        file_format=>'json_file_format'
                    )
                )
);


copy into emp_01 from (
select
    $1:active_status::BOOLEAN,
    $1:address::TEXT,
    $1:age::NUMBER(2, 0),
    $1:created_at::TIMESTAMP_NTZ,
    $1:date_of_birth::DATE,
    $1:date_of_joining::DATE,
    $1:designation::TEXT,
    $1:email::TEXT,
    $1:height_in_ft::NUMBER(3, 2),
    $1:job::TEXT,
    $1:name::TEXT,
    $1:phone_number::ARRAY,
    $1:programming_skill::OBJECT,
    $1:updated_at::TIMESTAMP_NTZ
from @json_stg/simple_emp_single_entity.json
(file_format => json_file_format) t)
on_error = 'Continue' ;



select * from emp_01
