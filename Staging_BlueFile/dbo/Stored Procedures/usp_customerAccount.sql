
-- ===================================================
-- Author:		<Sanele Ndlela>
-- Create date: <2020-07-13>
-- Description:	<Load customerAccount>
-- ==================================================
CREATE PROCEDURE [dbo].[usp_customerAccount]
AS
BEGIN
	SET NOCOUNT ON;
--///////////////////////////////////////////////////////////////////////
	TRUNCATE TABLE st_customerAccount

	INSERT INTO st_customerAccount
	(customerAccountUuid ,masterdataNumber, tradeChannelNodeUuid, customerLocationUuid,channelUuid,brandTypeUuid,description,status,type,loadDate)
	SELECT uuid ,CASE
				 WHEN (number IS NULL) THEN
					'-1'
				 ELSE
						number
				 END AS customerAccountNumber , 
				 CASE
				 WHEN (tradeChannelNodeUuid IS NULL) THEN
					'-1'
				 ELSE
						tradeChannelNodeUuid
				 END AS tradeChannelNodeUuid, 
				 CASE
				 WHEN (customerLocationUuid IS NULL) THEN
					'-1'
				 ELSE
						customerLocationUuid
				 END AS customerLocationUuid,
				 CASE 
				 WHEN (channelUuid IS NULL) THEN
					'-1'
				 ELSE
						channelUuid
				 END AS channelUuid,
				 CASE
				 WHEN (brandTypeUuid IS NULL) THEN
					'-1'
				 ELSE
						brandTypeUuid
				 END AS brandTypeUuid, description, status, type, GETDATE()
	FROM customerAccount
--===================================================================
--Delete customerAccountInstance from customerAccount 
--===================================================================
	DELETE customerAccount
	FROM customerAccount a
	INNER JOIN st_customerAccount b
	ON a.uuid = b.customerAccountUuid
--===============================================================
--Overwrite existing customerAccount records
--==============================================================
	DELETE [Warehouse_BlueFileData].[Dimension].[customerAccount]
	FROM [Warehouse_BlueFileData].[Dimension].[customerAccount] a
	INNER JOIN st_customerAccount b
	ON a.customerAccountUuid = b.customerAccountUuid
--===================================================================
--Insert new customerAccount records
--===================================================================
	INSERT INTO [Warehouse_BlueFileData].[Dimension].[customerAccount]
	(customerAccountUuid, masterdataNumber, tradeChannelNodeUuid, customerLocationUuid, channelUuid, brandTypeUuid, description, status, type, refreshDate)
	SELECT customerAccountUuid ,masterdataNumber, tradeChannelNodeUuid, customerLocationUuid, channelUuid, brandTypeUuid, description, status, type, GETDATE()
	FROM st_customerAccount
END
