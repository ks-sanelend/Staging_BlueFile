


-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load salesAgencyCostCentre>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_salesAgencyCostCentre]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_salesAgencyCostCentre

	INSERT INTO st_salesAgencyCostCentre
	(salesAgencyCostCentreUuid ,code, name, description,companyUuid, startDate, endDate, status, currentCustodianFirstName, currentCustodianLastName, currentCustodianUuid, detailedDescription, reason,omsMappingValidationMessage, custodianLinkEndDate, costCentreCustodianLinksUuid, companyUserUuid, costCentreCustodianLinksStatus, contractedHours,effectiveFromDate,
	  effectiveToDate, userUuid, username,firstName,lastName,emailAddress,identityNumber,admin,availableForSelection,costCentreCustodianLinksReason,
	  costCentreCustodianLinksStartDate,costCentreCustodianLinksEndDate,loadDate)
	SELECT salesAgencyCostCentreUuid ,code, name, description, 
				 CASE 
				 WHEN companyUuid IS NULL THEN
					'-1'
				 ELSE
					companyUuid
				 END,startDate, endDate, status, currentCustodianFirstName, currentCustodianLastName, 
				 CASE
				 WHEN (currentCustodianUuid IS NULL) THEN
						'-1'
				 ELSE
						currentCustodianUuid
				 END AS currentCustodianUuid, detailedDescription, reason,omsMappingValidationMessage, custodianLinkEndDate,
				 CASE 
				 WHEN (costCentreCustodianLinksUuid IS NULL) THEN
						'-1'
				 ELSE
						costCentreCustodianLinksUuid
				 END AS costCentreCustodianLinksUuid,
				 CASE 
				 WHEN (companyUserUuid IS NULL) THEN
						'-1'
				 ELSE
						companyUserUuid
				 END AS companyUserUuid, costCentreCustodianLinksStatus, contractedHours,effectiveFromDate,effectiveToDate,
				 CASE 
				 WHEN (userUuid IS NULL) THEN
						'-1'
				 ELSE
						userUuid
				 END AS userUuid,username,firstName,lastName,emailAddress,identityNumber,admin,availableForSelection,costCentreCustodianLinksReason,
						costCentreCustodianLinksStartDate,costCentreCustodianLinksEndDate , GETDATE()
	FROM salesAgencyCostCentre
--===================================================================
--Delete salesAgencyCostCentreInstance from salesAgencyCostCentre 
--===================================================================
	DELETE salesAgencyCostCentre
	FROM salesAgencyCostCentre a
	INNER JOIN st_salesAgencyCostCentre b
	ON a.salesAgencyCostCentreuuid = b.salesAgencyCostCentreUuid
--===============================================================
--Overwrite existing salesAgencyCostCentre records
--==============================================================
	DELETE [Warehouse_BlueFileData].[Dimension].[salesAgencyCostCentre]
	FROM [Warehouse_BlueFileData].[Dimension].[salesAgencyCostCentre] a
	INNER JOIN st_salesAgencyCostCentre b
	ON a.salesAgencyCostCentreUuid = b.salesAgencyCostCentreUuid
--===================================================================
--Insert new salesAgencyCostCentre records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[salesAgencyCostCentre]
	(salesAgencyCostCentreUuid ,code, name, description,companyUuid,startDate, endDate, status, currentCustodianFirstName, currentCustodianLastName, currentCustodianUuid, detailedDescription, reason,omsMappingValidationMessage, custodianLinkEndDate, costCentreCustodianLinksUuid, companyUserUuid, costCentreCustodianLinksStatus, contractedHours,effectiveFromDate,
	  effectiveToDate, userUuid, username,firstName,lastName,emailAddress,identityNumber,admin,availableForSelection,costCentreCustodianLinksReason,
	  costCentreCustodianLinksStartDate,costCentreCustodianLinksEndDate, refreshDate)
	SELECT salesAgencyCostCentreUuid ,code, name, description,companyUuid, startDate, endDate, status, currentCustodianFirstName, currentCustodianLastName, currentCustodianUuid, detailedDescription, reason,omsMappingValidationMessage, custodianLinkEndDate, costCentreCustodianLinksUuid, companyUserUuid, costCentreCustodianLinksStatus, contractedHours,effectiveFromDate,
	  effectiveToDate, userUuid, username,firstName,lastName,emailAddress,identityNumber,admin,availableForSelection,costCentreCustodianLinksReason,
	  costCentreCustodianLinksStartDate,costCentreCustodianLinksEndDate, GETDATE()
	FROM st_salesAgencyCostCentre
END
