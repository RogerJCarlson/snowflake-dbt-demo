{{ config(
pre_hook= "CREATE STAGE IF NOT EXISTS DBT_LOG_FILE FILE_FORMAT=(SKIP_BLANK_LINES=TRUE)"
) }}
/*
This demonstrates how you can include DDL to execute before your view or table is created.
Here I am creating an internal stage and this view will query the text files placed in it.
*/
select
metadata$filename as LOG_FILE,
metadata$file_row_number as ROW_NUM,
$1 as LOG_TEXT
from @DBT_LOG_FILE