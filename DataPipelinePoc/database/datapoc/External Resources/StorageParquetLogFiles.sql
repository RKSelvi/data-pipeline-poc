CREATE EXTERNAL DATA SOURCE [StorageParquetLogFiles] WITH
(
	TYPE = HADOOP,
	LOCATION = N'$(ParquetLogFileLocation)',	
	CREDENTIAL = [DataLakeScopedCredential]
)