CREATE PROC [dbo].[AzureMetrics]
AS
BEGIN
	SELECT [tablename]
      ,[name]
      ,[type]
      ,[items]
  FROM [dbo].[azureMetrics]
END
