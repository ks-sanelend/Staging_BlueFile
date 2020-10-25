


-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load taskTypes>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_taskTypes]

AS
BEGIN
	
	SET NOCOUNT ON;
--//////////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_taskTypes

	INSERT INTO st_taskTypes
	(taskTypeUuid, status, name, description, applicationKey, daysToExpiry, photoRequired, loadDate)
	SELECT	Uuid,status,name,
			CASE
			WHEN [description] IS NULL THEN
				''
			ELSE
			 [description]
			END,applicationKey,daysToExpiry,photoRequired,GETDATE()
	FROM taskTypes
--===================================================================
--Delete tasktypeInstance from taskTypes 
--===================================================================
	DELETE taskTypes
	FROM taskTypes a
	INNER JOIN st_taskTypes b
	ON a.uuid = b.taskTypeUuid
--===================================================================
--Overwrite existing taskTypes records
--===================================================================
	DELETE [Warehouse_BlueFileData].[Dimension].[taskTypes]
	FROM [Warehouse_BlueFileData].[Dimension].[taskTypes] a
	INNER JOIN st_taskTypes b
	ON a.taskTypeUuid = b.taskTypeUuid
--===================================================================
--Insert new taskTypes records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[taskTypes]
	(taskTypeUuid, status, name, description, applicationKey, daysToExpiry, photoRequired, refreshDate)
	SELECT taskTypeUuid, status, name, description, applicationKey, daysToExpiry, photoRequired, GETDATE()
	FROM st_taskTypes
--===================================================================
--Insert image product category 
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[productCategory] 
	(taskTypeUuid,productCategory,refreshDate)
	SELECT a.taskTypeUuid,TRIM(SUBSTRING(a.name,CHARINDEX(':',a.name)+1,LEN(a.name))) productCategory, GETDATE()
	FROM [Warehouse_BlueFileData].[Dimension].[taskTypes] a
	LEFt JOIN [Warehouse_BlueFileData].[Dimension].[productCategory] b
	ON a.taskTypeUuid = b.taskTypeUuid
	WHERE a.name  like '%Take Photo:%'
	AND b.taskTypeUuid IS NULL 
--===================================================================
--Update product category 
--===================================================================
	UPDATE [Warehouse_BlueFileData].[Dimension].[productCategory] 
	SET productCategory = TRIM(SUBSTRING(b.name,CHARINDEX(':',b.name)+1,LEN(b.name))) 
	FROM [Warehouse_BlueFileData].[Dimension].[productCategory] a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[taskTypes] b
	ON a.taskTypeUuid = b.taskTypeUuid
	WHERE b.name  like '%Take Photo:%'

END
