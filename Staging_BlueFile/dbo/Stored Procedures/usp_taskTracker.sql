
-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-20>
-- Description:	<Load taskTracker>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_taskTracker]

AS
BEGIN
	
	SET NOCOUNT ON;
--//////////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_taskTracker

	INSERT INTO st_taskTracker
	(Domain, KeyCustomer,taskInstanceUuid,appointmentTypeUuid,scheduleType,KeyscheduleType,appointmentDate,KeyappointmentDate,startTime,KeystartTime,endTime,KeyendTime,
	UserUuid,companyUserUuid, customerLocationUuid,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,taskUuid,status,KeytaskStatus,
	 completedDateTime,KeycompletedDate, KeycompletedTime,externalSystemDataKey,taskTypeUuid,loadDate)
	SELECT	'-1' AS Domain,-1 AS KeyCustomer,taskInstanceUuid,
			CASE 
			WHEN appointmentTypeUuid IS NULL THEN
				'-1'
			ELSE
				appointmentTypeUuid
			END, scheduleType,-1 AS KeyscheduleType,date,-1 AS KeyappointmentDate,startTime,-1 AS KeystartTime,endTime,-1 AS KeyendTime,
			CASE
			WHEN UserUuid IS NULL THEN
				'-1'
			ELSE
				UserUuid
			END,
			CASE 
			WHEN companyUserUuid IS NULL THEN
				'-1'
			ELSE
				companyUserUuid
			END,
			CASE 
			WHEN customerLocationUuid IS NULL THEN
				'-1'
			ELSE
			customerLocationUuid
			END,
			CASE 
			WHEN customerAccountUuid IS NULL THEN
				'-1'
			ELSE
				customerAccountUuid
			END,
			CASE
			WHEN tradeChannelUuid IS NULL THEN
				'-1'
			ELSE 
				tradeChannelUuid
			END,
			CASE 
			WHEN principalUuid IS NULL THEN
				'-1'
			ELSE 
				principalUuid
			END,
			CASE
			WHEN serviceProviderUuid IS NULL THEN
				'-1'
			ELSE
				serviceProviderUuid
			END,
			CASE 
			WHEN salesAgencyCostCentreUuid IS NULL THEN
				'-1'
			ELSE
				salesAgencyCostCentreUuid
			END,
			CASE 
			WHEN taskUuid IS NULL THEN
				'-1'
			ELSE
				taskUuid
			END, status,-1 AS KeytaskStatus,completedDateTime,-1 AS KeycompletedDate,-1 AS KeycompletedTime,externalSystemDataKey,
			CASE
			WHEN taskTypeUuid IS NULL THEN
				'-1'
			ELSE
				taskTypeUuid
			END,GETDATE()
	FROM taskTracker
--==================================================================
--Insert new schedule Type task Status
--==================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.scheduleType
	SELECT a.scheduleType
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.scheduleType b
	ON a.scheduleType = b.scheduleType
	WHERE b.scheduleType IS NULL
--==================================================================
--Insert new  task Status
--==================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.taskStatus
	SELECT a.status
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.taskStatus b
	ON a.status = b.status
	WHERE b.status IS NULL
--==========================================================================================
--Insert new  appointmentTypes if they don't exists in the appointmentTypes dimension table
--==========================================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.appointmentTypes
	(appointmentTypeUuid,status,name,tasksRequired,refreshDate)
	SELECT a.appointmentTypeUuid,'unknown','unknown','unknown',GETDATE()
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.appointmentTypes b
	ON a.appointmentTypeUuid = b.appointmentTypeUuid
	WHERE b.appointmentTypeUuid IS NULL
--=========================================================================================
--Insert new companyUser if it doesn't exists in the companyUser dimension table
--=========================================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.companyUser
	(companyUserUuid,status,contractedHours,effectiveFromDate,effectiveToDate,userUuid,companyUuid,accessLevels,username,firstName,lastName,
	 emailAddress,identityNumber,passportNumber,admin,availableForSelection,reason,type,refreshDate)
	SELECT a.companyUserUuid,'unknown','-1','1900-01-01','9999-01-01','-1','-1','unknown','unknown','unknown','unknown','unknown','-1','unknown','unknown','unknown','unknown','unknown',GETDATE()
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.companyUser b
	ON a.companyUserUuid = b.companyUserUuid
	WHERE b.companyUserUuid IS NULL
--======================================================================================
--Insert new customerAccount if it doesn't exists in the customerAccount dimension table
--======================================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.customerAccount
	(customerAccountUuid,masterDataNumber,tradeChannelNodeUuid,customerLocationUuid,channelUuid,brandTypeUuid,description,status,type,refreshDate)
	SELECT a.customerAccountUuid,'-1','-1','-1','-1','-1','unknown','unknown','unknown',GETDATE()
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.customerAccount b
	ON a.customerAccountUuid = b.customerAccountUuid
	WHERE b.customerAccountUuid IS NULL
--=========================================================================================
--Insert new customerLocation if it doesn't exists in the customerLocation dimension table
--=========================================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.customerLocation
	(customerLocationUuid,tradeEntityUuid,locationUuid,description,deliveryLocationUuid,status,type,refreshDate)
	SELECT a.customerLocationUuid,'-1','-1','unknown','-1','unknown','unknown',GETDATE()
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.customerLocation b
	ON a.customerLocationUuid = b.customerLocationUuid
	WHERE b.customerLocationUuid IS NULL
--====================================================================================================
--Insert new salesAgencyCostCentres if it doesn't exists in the salesAgencyCostCentre dimension table
--===================================================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.salesAgencyCostCentre
	(salesAgencyCostCentreUuid,code,name,description,companyUuid,startDate,endDate,status,currentCustodianFirstName,currentCustodianLastName,currentCustodianUuid ,detailedDescription
	,reason,omsMappingValidationMessage,custodianLinkEndDate,costCentreCustodianLinksUuid,companyUserUuid,costCentreCustodianLinksStatus,contractedHours,effectiveFromDate,effectiveToDate
	,userUuid,username,firstName,lastName,emailAddress,identityNumber,admin,availableForSelection,costCentreCustodianLinksReason,costCentreCustodianLinksStartDate,costCentreCustodianLinksEndDate
	,refreshDate)
	SELECT a.salesAgencyCostCentreUuid,'unknown','unknown','unknown','-1','1900-01-01','9999-01-01','unknown','unknown','unknown','-1','unknown','unknown','unknown','9999-01-01','-1','-1','unknown','-1',
			'1900-01-01','9999-01-01','-1','unknown','unknown','unknown','unknown','-1','unknown','unknown','unknown','1900-01-01','9999-01-01 '	,GETDATE()
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.salesAgencyCostCentre b
	ON a.salesAgencyCostCentreUuid = b.salesAgencyCostCentreUuid
	WHERE b.salesAgencyCostCentreUuid IS NULL
--===========================================================================
--Insert new taskTypes if it doesn't exists in the taskTypes dimension table
--===========================================================================
	INSERT INTO Warehouse_BlueFileData.Dimension.taskTypes
	(taskTypeUuid,status,name,description,applicationKey,daysToExpiry,photoRequired,refreshDate)
	SELECT a.taskTypeUuid,'unknown','unknown','unknown','unknown','-1','unknown',GETDATE()
	FROM st_taskTracker a
	LEFT JOIN Warehouse_BlueFileData.Dimension.taskTypes b
	ON a.taskTypeUuid = b.taskTypeUuid
	WHERE b.taskTypeUuid IS NULL
--==================================================================
--Map Domain
--==================================================================
	SELECT DISTINCT a.principalUuid,a.serviceProviderUuid, b.name AS Principal,c.name AS serviceProvider, d.Domain
	INTO #principalServiceProvider
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[company]  b
	ON a.principalUuid = b.companyUuid
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[company] c
	ON a.serviceProviderUuid = c.companyUuid
	INNER JOIN [dbo].[umt_BF_PrincipalDomain] d
	ON b.name = d.Principal
	AND c.name = d.ServiceProvider
--//////////////////////////////////////////////////////////////////////////////
	UPDATE st_taskTracker
	SET Domain = b.Domain
	FROM st_taskTracker a
	INNER JOIN  #principalServiceProvider b
	ON a.principalUuid = b.principalUuid
	AND a.serviceProviderUuid = b.serviceProviderUuid
--==================================================================
--Map KeyCustomer
--=================================================================  
	SELECT DISTINCT a.domain,a.TalendNo 
	INTO #talendno --Pulling duplicates, we need to find out
	FROM Warehouse.Dimension.Customers a
	INNER JOIN st_taskTracker b
	ON a.Domain = b.Domain
	WHERE  a.TalendNo <> '' 
	AND a.IsCurrent = 'y'
--//////////////////////////////////////////////////////////////////// drop table #customerNumber
	SELECT a.domain, a.taskinstanceuuid, a.customeraccountuuid, b.customeraccountuuid cAUuid, b.masterdataNumber
	INTO #ttca
	FROM [Warehouse_BlueFileData].[Fact].[taskTracker] a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[customerAccount] b 
	ON a.customeraccountuuid = b.customeraccountuuid
--////////////////////////////////////////////////////////////////////  
	SELECT a.taskinstanceuuid, a.customeraccountuuid, a.CAuuid, a.masterDataNumber, b.type, c.description 
	INTO  #customerNumber
	FROM #ttca a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[customerAccount] b 
	ON a.CAuuid = b.customerAccountUuid
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[customerLocation] c 
	ON b.customerlocationuuid = c.customerLocationUuid
	INNER JOIN #talendno d
	ON a.masterDataNumber = d.TalendNo
	AND a.domain = d.domain
	--WHERE a.number IN (SELECT talendno FROM #talendno)
--///////////////////////////////////////////////////////////////////
	UPDATE st_taskTracker
	SET KeyCustomer =c.KeyCustomer
	FROM st_taskTracker a
	INNER JOIN #customerNumber b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	INNER JOIN [Warehouse].[Dimension].[Customers] c
	ON b.masterDataNumber = c.TalendNo
	AND a.domain =c.domain
	WHERE c.IsCurrent = 'y'
--/////////////////////////////////////////////////////////////////
	UPDATE  st_taskTracker
	SET KeyCustomer = b.KeyCustomer
	FROM st_taskTracker a
	INNER JOIN Warehouse.Dimension.Customers b
	ON a.Domain = b.Domain
	WHERE b.Customer = ''
	AND a.KeyCustomer = -1
	AND b.IsCurrent = 'y'
--=================================================================
--Map KeyscheduleType
--==================================================================
	UPDATE st_taskTracker
	SET KeyscheduleType = b.KeyscheduleType
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[scheduleType] b
	ON a.scheduleType = b.scheduleType
--==================================================================
--Map KeyappointmentDate
--==================================================================
	UPDATE st_taskTracker
	SET KeyappointmentDate = b.KeyDate
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[date] b
	ON a.appointmentDate = b.dayDate
	--AND a.Domain = b.Domain
--==================================================================
--Map KeystartTime
--==================================================================
	UPDATE st_taskTracker
	SET KeystartTime = b.KeyTime
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[time] b
	ON a.startTime = b.FullTime
--==================================================================
--Map KeyendTime
--==================================================================
	UPDATE st_taskTracker
	SET KeyendTime = b.KeyTime
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[time] b
	ON a.endTime = b.FullTime
--==================================================================
--Map KeytaskStatus
--==================================================================
	UPDATE st_taskTracker
	SET KeytaskStatus = b.KeytaskStatus
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[taskStatus] b
	ON a.status = b.status
--==================================================================
--Map KeycompletedDate
--==================================================================
	UPDATE st_taskTracker
	SET KeycompletedDate = b.KeyDate
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[date] b
	ON CONVERT(DATETIME, SUBSTRING(CONVERT(VARCHAR, a.completedDateTime,103),1,10),103) = b.dayDate
	--AND a.Domain = b.Domain
	WHERE KeytaskStatus = 2
--==================================================================
--Map KeycompletedTime
--==================================================================
	UPDATE st_taskTracker
	SET KeycompletedTime = b.KeyTime
	FROM st_taskTracker a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[time] b
	ON convert(time(0),a.completedDateTime,14) = b.FullTime
	WHERE KeytaskStatus = 2
--================================================================
--Delete taskInstanceInstance from taskTracker 
--===============================================================
	DELETE taskTracker
	FROM taskTracker a
	INNER JOIN st_taskTracker b
	ON a.taskInstanceUuid = b.taskInstanceUuid
--==================================================================
--Overwrite existing taskTracker records
--==================================================================
	DELETE [Warehouse_BlueFileData].[Fact].[taskTracker]
	FROM [Warehouse_BlueFileData].[Fact].[taskTracker] a
	INNER JOIN st_taskTracker b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND  a.Domain = b.Domain
	WHERE a.KeytaskStatus <> 2
--===================================================================
--Insert new records into Fact.tasktracker
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Fact].[taskTracker]
	(Domain,KeyCustomer,taskInstanceUuid, appointmentTypeUuid,KeyscheduleType,KeyappointmentDate,KeystartTime,KeyendTime,UserUuid,companyUserUuid, customerLocationUuid,customerAccountUuid,
	 tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,taskUuid,KeytaskStatus,KeycompletedDate,KeycompletedTime,externalSystemDataKey,taskTypeUuid,refreshDate)

	SELECT a.Domain,a.KeyCustomer,a.taskInstanceUuid,a.appointmentTypeUuid,a.KeyscheduleType,a.KeyappointmentDate,a.KeystartTime,a.KeyendTime,a.UserUuid,a.companyUserUuid,
	 		a.customerLocationUuid,a.customerAccountUuid,a.tradeChannelUuid,a.principalUuid,a.serviceProviderUuid,a.salesAgencyCostCentreUuid,a.taskUuid,a.KeytaskStatus,a.KeycompletedDate,
			a.KeycompletedTime,a.externalSystemDataKey,a.taskTypeUuid,a.loadDate
	FROM st_taskTracker a
	LEFT JOIN (SELECT taskInstanceUuid,Domain FROM [Warehouse_BlueFileData].[Fact].[taskTracker] 
				WHERE KeytaskStatus = 2 ) b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND a.Domain = b.Domain
	WHERE b.taskInstanceUuid IS NULL
--===================================================================
--Remove all taskInstanceUuid with keytaskStatus 4 (DELETED)
--===================================================================
	DELETE [Warehouse_BlueFileData].[Fact].[taskTracker]
	FROM [Warehouse_BlueFileData].[Fact].[taskTracker]
	WHERE keytaskStatus = 4
END
