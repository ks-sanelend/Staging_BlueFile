
-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load company>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_company]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_company

	INSERT INTO st_company
	(companyUuid, legalEntityUuid, name, status,loadDate)
	SELECT uuid ,CASE
				 WHEN (legalEntityUuid IS NULL) THEN
						'-1'
				 ELSE
						legalEntityUuid
				 END AS legalEntityUuid, name, status, GETDATE()
	FROM company
--===================================================================
--Delete companyInstance from company 
--===================================================================
	DELETE company
	FROM company a
	INNER JOIN st_company b
	ON a.uuid = b.companyUuid
--===============================================================
--Overwrite existing company records
--==============================================================
	DELETE [Warehouse_BlueFileData].[Dimension].[company]
	FROM [Warehouse_BlueFileData].[Dimension].[company] a
	INNER JOIN st_company b
	ON a.companyUuid = b.companyUuid
--===================================================================
--Insert new companyUser records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[company]
	(companyUuid, legalEntityUuid, name, status, refreshDate)
	SELECT companyUuid, legalEntityUuid, name, status, GETDATE()
	FROM st_company
END
