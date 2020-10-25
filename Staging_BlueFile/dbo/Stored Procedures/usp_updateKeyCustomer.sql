





-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-08-04>
-- Description:	<Update Unknown KeyCustomer>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_updateKeyCustomer]

AS
BEGIN
	
	SET NOCOUNT ON;
--//////////////////////////////////////////////////////////////////////////
--==================================================================
--update KeyCustomer where keycustomer is unknown for all completed
--task instance records
--=================================================================  
--Revisit this due to overheard on re-keying all the keycustomer to only re-key blank customer records
--drop table #talendno
	SELECT DISTINCT a.domain, a.TalendNo 
	INTO #talendno --Pulling duplicates, we need to find out
	FROM Warehouse.Dimension.Customers a
	INNER JOIN [Warehouse_BlueFileData].[Fact].[taskTracker] b
	ON a.Domain = b.Domain
	WHERE  a.TalendNo <> '' 
	AND a.IsCurrent = 'y'
--////////////////////////////////////////////////////////////////////
--drop table #ttca
	SELECT a.domain, a.taskinstanceuuid, a.customeraccountuuid,b.masterdataNumber
	INTO #ttca
	FROM [Warehouse_BlueFileData].[Fact].[taskTracker] a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[customerAccount] b 
	ON a.customeraccountuuid = b.customeraccountuuid
--////////////////////////////////////////////////////////////////////  
--drop table #customerNumber
	SELECT a.taskinstanceuuid, a.customeraccountuuid, a.masterdataNumber 
	INTO  #customerNumber
	FROM #ttca a
	INNER JOIN #talendno d
	ON a.masterdataNumber =d.TalendNo
	AND a.domain = d.domain
--//////////////////////////////////////////////////////////////////////	
	UPDATE [Warehouse_BlueFileData].[Fact].[taskTracker]
	SET KeyCustomer =c.KeyCustomer
	FROM [Warehouse_BlueFileData].[Fact].[taskTracker] a
	INNER JOIN #customerNumber b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	INNER JOIN [Warehouse].[Dimension].[Customers] c
	ON b.masterdataNumber = c.TalendNo
	AND a.domain =c.domain
	WHERE c.IsCurrent = 'y'
/*--==================================================================
--Map/Update Fact.imageData keyCustomer
--==================================================================
	UPDATE [Warehouse_BlueFileData].[Fact].[imageData]
	SET keyCustomer = b.keyCustomer
	FROM  [Warehouse_BlueFileData].[Fact].[imageData] a 
	INNER JOIN Warehouse_BlueFileData.Fact.taskTracker b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	
--///////////////////////////////////////////////////////////////////
	--Revisit when updating only blank customers 
	SELECT a.domain,a.taskinstanceuuid,a.keyCustomer,a.masterdataNumber,b.TalendNo
	FROM #ttca a
	LEFT JOIN #talendno b
	ON a.domain = b.domain
	AND a.masterdataNumber =b.TalendNo
	WHERE  b.TalendNo IS NULL

	SELECT a.taskinstanceuuid, a.masterdataNumber 
	INTO  #customerNumber
	FROM #ttca a
	INNER JOIN #talendno d
	ON a.masterdataNumber =d.TalendNo
	AND a.domain = d.domain
	
	SELECT a.domain,a.taskinstanceuuid,a.masterdataNumber,c.TalendNo,b.keyCustomer
	FROM #ttca a
	INNER JOIN Warehouse.Dimension.Customers b
	ON a.domain = b.domain
	AND a.masterdataNumber =b.TalendNo
	LEFT JOIN #talendno c
	ON a.domain = c.domain
	AND a.masterdataNumber =c.TalendNo
	WHERE  b.IsCurrent = 'y'
	AND c.TalendNo IS NULL */
END


