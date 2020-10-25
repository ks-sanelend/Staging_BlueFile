




-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-08-07>
-- Description:	<Update Unknown Domains>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_updateDomain]

AS
BEGIN
	
	SET NOCOUNT ON;
--//////////////////////////////////////////////////////////////////////////
--==================================================================
--Map/Update Fact.taskTracker Domain
--==================================================================
	SELECT DISTINCT a.principalUuid,a.serviceProviderUuid, b.name AS Principal,c.name AS serviceProvider, d.Domain
	INTO #principalServiceProvider
	FROM [Warehouse_BlueFileData].[Fact].[taskTracker] a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[company]  b
	ON a.principalUuid = b.companyUuid
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[company] c
	ON a.serviceProviderUuid = c.companyUuid
	INNER JOIN [dbo].[umt_BF_PrincipalDomain] d
	ON b.name = d.Principal
	AND c.name = d.ServiceProvider
	WHERE a.domain = '-1'
--//////////////////////////////////////////////////////////////////////////////
	UPDATE [Warehouse_BlueFileData].[Fact].[taskTracker]
	SET Domain = b.Domain
	FROM [Warehouse_BlueFileData].[Fact].[taskTracker] a
	INNER JOIN  #principalServiceProvider b
	ON a.principalUuid = b.principalUuid
	AND a.serviceProviderUuid = b.serviceProviderUuid
--==================================================================
--Map/Update Fact.imageData Domain
--==================================================================
	/*UPDATE Warehouse_BlueFileData.[Fact].[imageData]
	SET domain = b.domain
	FROM  Warehouse_BlueFileData.[Fact].[imageData] a 
	INNER JOIN Warehouse_BlueFileData.Fact.taskTracker b
	ON a.taskInstanceUuid = b.taskInstanceUuid*/
END


