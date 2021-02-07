-- drop external table azureMetrics;
CREATE EXTERNAL TABLE [dbo].[azureMetrics]
( 	[name] varchar(100)
)
WITH
 (
    LOCATION='/AzureMetrics/' ,
    DATA_SOURCE = StorageParquetLogFiles ,
    FILE_FORMAT = AS_PARQUET   
) ; 
GO
