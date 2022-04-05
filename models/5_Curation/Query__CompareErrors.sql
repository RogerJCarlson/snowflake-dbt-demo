--Query__CompareErrors

SELECT
    DISTINCT QA_LOG.RUN_DATE
    , QA_LOG.STANDARD_DATA_TABLE
    , QA_LOG.METRIC_FIELD
    , QA_LOG.QA_METRIC
    , QA_LOG.ERROR_TYPE
    , QA_LOG_DBT.Error_Type as DBT_Error_Type
    , QA_LOG.QA_ERRORS
    , QA_LOG_DBT.QA_Errors as DBT_QA_Errors
    , QA_LOG_DBT.QA_Errors - QA_LOG.QA_ERRORS AS errordiff
    , QA_LOG.TOTAL_RECORDS
    , QA_LOG_DBT.Total_Records as DBT_Total_Records
    , QA_LOG_DBT.Total_Records - QA_LOG.TOTAL_RECORDS AS totaldiff
FROM
    QA_LOG
INNER JOIN QA_LOG_DBT ON
    (QA_LOG.METRIC_FIELD = upper(QA_LOG_DBT.Metric_field))
    AND (QA_LOG.QA_METRIC = upper(QA_LOG_DBT.QA_Metric))
    AND (QA_LOG.STANDARD_DATA_TABLE = upper(QA_LOG_DBT.Standard_Data_Table))
    AND ((QA_LOG.ERROR_TYPE = upper(QA_LOG_DBT.Error_Type)) or (QA_LOG.ERROR_TYPE is null and QA_LOG_DBT.Error_Type is not null) or (QA_LOG.ERROR_TYPE is not null and QA_LOG_DBT.Error_Type is null))
WHERE
    (
        ((QA_LOG.ERROR_TYPE) IS NOT NULL)
        OR ((QA_LOG_DBT.Error_Type) IS NOT NULL)
        )