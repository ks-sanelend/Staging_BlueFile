-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load companyUser>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_companyUser]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_companyUser

	INSERT INTO st_companyUser
	(companyUserUuid ,status, contractedHours,effectiveFromDate,effectiveToDate,userUuid,companyUuid,accessLevels,username,firstName,lastName,emailAddress,
	identityNumber,passportNumber,admin,availableForSelection,reason,type,loadDate)
	SELECT uuid ,status,contractedHours, effectiveFromDate , effectiveToDate, 
				 CASE
				 WHEN (userUuid IS NULL) THEN
						'-1'
				 ELSE
						userUuid
				 END AS userUuid,
				 CASE 
				 WHEN (companyUuid IS NULL) THEN
						'-1'
				 ELSE
						companyUuid
				 END AS companyUuid, accessLevels, username,firstName,lastName,emailAddress,identityNumber,passportNumber,admin,availableForSelection,reason,type, GETDATE()
	FROM companyUser
--===================================================================
--Delete companyUserInstance from companyUser 
--===================================================================
	DELETE companyUser
	FROM companyUser a
	INNER JOIN st_companyUser b
	ON a.uuid = b.companyUserUuid
--===============================================================
--Overwrite existing companyUser records
--==============================================================
	DELETE [Warehouse_BlueFileData].[Dimension].[companyUser]
	FROM [Warehouse_BlueFileData].[Dimension].[companyUser] a
	INNER JOIN st_companyUser b
	ON a.companyUserUuid = b.companyUserUuid
--===================================================================
--Insert new companyUser records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[companyUser]
	(companyUserUuid ,status, contractedHours,effectiveFromDate,effectiveToDate,userUuid,companyUuid,accessLevels,username,firstName,lastName,emailAddress,
	identityNumber,passportNumber,admin,availableForSelection,reason,type, refreshDate)
	SELECT companyUserUuid ,status, contractedHours,effectiveFromDate,effectiveToDate,userUuid,companyUuid,accessLevels,username,firstName,lastName,emailAddress,
		   identityNumber,passportNumber,admin,availableForSelection,reason,type, GETDATE()
	FROM st_companyUser
END
