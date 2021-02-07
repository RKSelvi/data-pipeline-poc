CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$(DataLakeEncryptionMasterKey)';
GO

CREATE DATABASE SCOPED CREDENTIAL DataLakeScopedCredential 
WITH
IDENTITY = '$(DataLakeAccessId)',
-- datalake access key
SECRET = '$(DataLakeAccessKey)';
