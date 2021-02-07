-- drop external table azureMetrics;
CREATE EXTERNAL TABLE [dbo].[azureMetrics]
( 	[TenantId] varchar(100) ,
	[SourceSystem] varchar(50) ,
	[TimeGenerated] varchar(50) ,
	[ResourceId] varchar(400) ,
	[Resource] varchar(100) ,
	[ResourceGroup] varchar(100) ,
	[ResourceProvider] varchar(100) ,
	[SubscriptionId] varchar(100) ,
	[MetricName] varchar(100) ,	
	[Type] varchar(50) ,
	[_ResourceId] varchar(400)
)
WITH
 (
    LOCATION='/AzureMetrics/' ,
    DATA_SOURCE = StorageParquetLogFiles ,
    FILE_FORMAT = AS_PARQUET   
) ; 
GO
