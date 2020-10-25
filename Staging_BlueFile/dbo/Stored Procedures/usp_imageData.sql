


-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load imageData>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_imageData]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_imageData

	INSERT INTO st_imageData
	(taskInstanceUuid,domain,imageUuid,batch,reference,keyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,
	 customerLocationUuid,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,
	 keycompletedTime,taskTypeUuid,keyproductCategory,uri,loadDate)

	SELECT taskInstanceUuid,'',uuid,batch,reference,0,'',0,0,0,0,'','','','','','','',0,0,0,'',-1 AS productCategory, uri,GETDATE()
	FROM imageData
--===================================================================
--Delete Image record from imageData 
--===================================================================
	DELETE imageData
	FROM imageData a
	INNER JOIN st_imageData b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND a.uuid = b.imageUuid
--========================================================
--Update Uuid's based on the task header
--=========================================================
	UPDATE st_imageData
	SET domain = b.domain,
		keyCustomer = b.keyCustomer,
		appointmentTypeUuid = b.appointmentTypeUuid,
		keyscheduleType = b.keyscheduleType,
		keyappointmentDate = b.keyappointmentDate,
		keystartTime = b.keystartTime,
		keyendTime = b.keyendTime,
		companyUserUuid = b.companyUserUuid,
		customerLocationUuid = b.customerLocationUuid,
		customerAccountUuid = b.customerAccountUuid,
		tradeChannelUuid = b.tradeChannelUuid,
		principalUuid = b.principalUuid,
		serviceProviderUuid = b.serviceProviderUuid,
		salesAgencyCostCentreUuid = b.salesAgencyCostCentreUuid, 
		keytaskStatus = b.keytaskStatus ,
		keycompletedDate = b.keycompletedDate,
		keycompletedTime = b.keycompletedTime,
		taskTypeUuid = b.taskTypeUuid
	FROM st_imageData a 
	INNER JOIN Warehouse_BlueFileData.Fact.taskTracker b
	ON a.taskInstanceUuid = b.taskInstanceUuid
--===================================================================
--Update productCategory 
--===================================================================
	UPDATE st_imageData
	SET keyproductCategory = b.keyproductCategory
	FROM st_imageData a
	INNER JOIN [Warehouse_BlueFileData].[Dimension].[productCategory] b
    ON  a.taskTypeUuid =b.taskTypeUuid
--===============================================================
--Overwrite existing Image records
--==============================================================
	DELETE [Warehouse_BlueFileData].[Fact].[imageData]
	FROM [Warehouse_BlueFileData].[Fact].[imageData] a
	INNER JOIN st_imagedata b
	ON a.taskInstanceUuid = b.taskInstanceUuid
	AND a.imageUuid = b.imageUuid
--===================================================================
--Insert new ImageData records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Fact].[imageData]
	(taskInstanceUuid,domain,imageUuid,batch,reference,keyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,
	 customerLocationUuid,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,
	 keycompletedTime,taskTypeUuid,keyproductCategory,uri)
	 
	 SELECT taskInstanceUuid,domain,imageUuid,batch,reference,keyCustomer,appointmentTypeUuid,keyscheduleType,keyappointmentDate,keystartTime,keyendTime,companyUserUuid,
	 customerLocationUuid,customerAccountUuid,tradeChannelUuid,principalUuid,serviceProviderUuid,salesAgencyCostCentreUuid,keytaskStatus,keycompletedDate,
	 keycompletedTime,taskTypeUuid,keyproductCategory,uri
	FROM st_imageData
END
