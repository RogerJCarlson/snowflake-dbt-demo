select 'HNO_INFO', count(*) from EpicClarity.dbo.HNO_INFO
union all
select 'ZC_NOTE_TYPE_IP', count(*) from EpicClarity.dbo.ZC_NOTE_TYPE_IP
union all
select 'NOTE_ENC_INFO', count(*) from EpicClarity.dbo.NOTE_ENC_INFO
union all
select 'HNO_NOTE_TEXT', count(*) from EpicClarity.dbo.HNO_NOTE_TEXT


SELECT ETL_MODULE, count(*)
FROM [OMOP].note
GROUP BY ETL_MODULE
order by ETL_Module;
