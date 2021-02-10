-- drop external table azureMetrics;
CREATE EXTERNAL TABLE [dbo].[azureMetrics]
( 	[tablename] VARCHAR(100),
    [name]      VARCHAR(50),
    [type]      VARCHAR(50),
    [items]     VARCHAR2(4000)
)
WITH
 (
    LOCATION='/AzureMetrics/' ,
    DATA_SOURCE = StorageParquetLogFiles ,
    FILE_FORMAT = AS_PARQUET   
) ; 
GO
