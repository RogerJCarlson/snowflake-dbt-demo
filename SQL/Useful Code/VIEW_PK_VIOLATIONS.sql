CREATE OR REPLACE PROCEDURE VIEW_PK_VIOLATIONS(
TABLE_NAME VARCHAR
)
RETURNS VARCHAR NOT NULL
LANGUAGE JAVASCRIPT
COMMENT = 'VIEW_PK_VIOLATIONS(TABLE_NAME)
Generates a temporary table with rows that violate the primary key on a table.
Parameters:
TABLE_NAME - Table to test for multiple rows with the same values in the PK'
AS
$$
// This will lookup the PK and capture the query ID for use in the next query
var primaryKeysSqlText = "SHOW PRIMARY KEYS IN TABLE " + TABLE_NAME;
var primaryKeysStatement = snowflake.createStatement( {sqlText: primaryKeysSqlText} );
primaryKeysStatement.execute();
if(0 == primaryKeysStatement.getRowCount())
return "Error: Primary Key not found on table " + TARGET_TABLE;
var primaryKeysQueryId = primaryKeysStatement.getQueryId();




// This SQL dynamically generates a validation DDL statement based on the metadata
// RESULT_SCAN retrieves the results of a previous query
var validationDDLSqlText =
`SELECT
'CREATE OR REPLACE TEMPORARY TABLE "'||"table_name"||'_PK_VIOLATIONS"
AS SELECT *
FROM "'||"database_name"||'"."'||"schema_name"||'"."'||"table_name"||'"
WHERE ('||LISTAGG('"'||"column_name"||'"', ', ')||') IN (
SELECT '||LISTAGG('"'||"column_name"||'"', ', ')||'
FROM "'||"database_name"||'"."'||"schema_name"||'"."'||"table_name"||'"
GROUP BY '||LISTAGG('"'||"column_name"||'"', ', ')||'
HAVING COUNT(*) > 1)' AS VIOLATION_DDL_STATEMENT
FROM TABLE(RESULT_SCAN('` + primaryKeysQueryId + `'))
GROUP BY "database_name", "schema_name","table_name"`;
var validationDDLStatement = snowflake.createStatement( {sqlText: validationDDLSqlText} );
var validationDDLResultSet = validationDDLStatement.execute();
validationDDLResultSet.next();



// Execute the validation DDL and return the message with the table name
var validationStatement = snowflake.createStatement( {sqlText: validationDDLResultSet.getColumnValue(1)} );
var validationResultSet = validationStatement.execute();
validationResultSet.next();
return validationResultSet.getColumnValue(1) + ' Query table to see primary key violations.';
$$;