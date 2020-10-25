

-- =============================================
-- Author:		<Sanele Ndlela>
-- Create date: <30-06-2020>
-- Description:	<Get master data from RabbitMQ Queue>
--				<Insert the data to the data warehouse> 
-- =============================================
CREATE PROCEDURE [dbo].[usp_masterData_Queue]
	@masterData_Msg nvarchar (max), @routing_Key nvarchar (100)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @xml XML
	DECLARE @taskInstanceUuid VARCHAR (100)
	DECLARE @routingKey NVARCHAR (100)

	SET @routingKey = LOWER(@routing_Key)

	IF ( @routingKey <> 'analytics-event')
		BEGIN
--====================================================================================
--Validate rabbitmq message and check if its a valid xml and json string, if its not
--valid insert message into rabbitmqmessagelLog
--Get company from rabbitMQ message in xml format
--Call a function to convert xml to json 
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if task company uuid exists and if it does overwrite it 
--and insert new company data
--==================================================================================== 
			IF ( @routingKey = 'company')
				BEGIN
					BEGIN TRY
						SET @xml = CAST(@masterData_Msg AS XML)
						IF ISJSON(([dbo].[qfn_XmlToJson] (@xml))) = 0
							BEGIN
								INSERT INTO rabbitMQMessageLog
								SELECT @masterData_Msg,@routingKey,'Invalid JSON', GETDATE()
							END
					END TRY
					BEGIN CATCH
						INSERT INTO rabbitMQMessageLog
						SELECT @masterData_Msg,@routingKey,'Invalid XML', GETDATE()
					END CATCH
--////////////////////////////////////////////////////////////////////
					CREATE TABLE #Company
						([report] [nvarchar](max) NULL,
						[item] [nvarchar](max) NULL,
						[UserName] [varchar](100) NULL,
						[Source] [varchar](100) NULL,
						[TimeInMillis] [bigint] NULL,
						[OperationType] [varchar](100) NULL,
						[DataCluster] [varchar](100) NULL,
						[DataModel] [varchar](100) NULL,
						[Concept] [varchar](100) NULL,
						[Key] [varchar](100) NULL,
						[uuid] [varchar](100) NULL,
						[legalEntityUuid] [varchar](100) NULL,
						[name] [varchar](100) NULL,
						[status] [varchar](100) NULL)
					INSERT INTO #Company
					SELECT * FROM  OPENJSON ([dbo].[qfn_XmlToJson] (@xml))
								   WITH ( 									
										report nvarchar(max) '$.report' AS JSON,
										item nvarchar (max) '$.item' AS JSON
										)
									CROSS APPLY
									OPENJSON (report)
									WITH(
											UserName varchar (100) '$.UserName',
											Source varchar (100) '$.Source',
											TimeInMillis bigint '$.TimeInMillis',
											OperationType varchar (100) '$.OperationType',
											DataCluster varchar (100) '$.DataCluster',
											DataModel varchar (100) '$.DataModel',
											Concept varchar (100) '$.Concept',
											[Key] varchar (100) '$.Key'
										)
									CROSS APPLY
									OPENJSON (item)
									WITH(
											uuid varchar (100) '$.uuid',
											legalEntityUuid varchar (100) '$.legalEntityUuid',
											name varchar (100) '$.name',
											status varchar (100) '$.status'
										)
--///////////////////////////////////////////////////////////////////////////////////
					DELETE operationsLog
					FROM   operationsLog
					INNER JOIN #Company ON operationsLog.[key] = #Company.[Key]

					INSERT INTO operationsLog
					SELECT Source,TimeInMillis,Concept,OperationType,[Key],GETDATE()
					FROM #Company
--=///////////////////////////////////////////////////////////////////////////////////
					DELETE Company
					FROM   Company
					INNER JOIN #Company ON Company.Uuid = #Company.uuid

					INSERT INTO Company
					SELECT uuid,
					CASE 
					WHEN SUBSTRING(legalEntityUuid,1,1) = '[' AND SUBSTRING(legalEntityUuid,LEN(TRIM(legalEntityUuid)),1)   =']' THEN
						 SUBSTRING(legalEntityUuid,2,LEN(TRIM(legalEntityUuid))-2)
					ELSE 
						legalEntityUuid
					END,name,status,GETDATE()
					FROM #Company
					--clean up
					DROP TABLE #Company
				END 
--====================================================================================
--Validate rabbitmq message and check if its a valid xml and json string, if its not
--valid insert message into rabbitmqmessagelLog
--Get customer account from rabbitMQ message in xml format
--Call a function to convert xml to json 
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if task customer account uuid exists and if it does overwrite it 
--and insert new customer account data
--==================================================================================== 
		ELSE IF( @routingKey = 'customer-account')
				 BEGIN
					BEGIN TRY
						SET @xml = CAST(@masterData_Msg AS XML)
						IF ISJSON(([dbo].[qfn_XmlToJson] (@xml))) = 0
							BEGIN
								INSERT INTO rabbitMQMessageLog
								SELECT @masterData_Msg,@routingKey,'Invalid JSON', GETDATE()
							END
					END TRY
					BEGIN CATCH
						INSERT INTO rabbitMQMessageLog
						SELECT @masterData_Msg,@routingKey,'Invalid XML',GETDATE()
					END CATCH
--////////////////////////////////////////////////////////////////////////////////////////
				CREATE TABLE #customerAccount
						([report] [nvarchar](max) NULL,
						[item] [nvarchar](max) NULL,
						[UserName] [varchar](100) NULL,
						[Source] [varchar](100) NULL,
						[TimeInMillis] [bigint] NULL,
						[OperationType] [varchar](100) NULL,
						[DataCluster] [varchar](100) NULL,
						[DataModel] [varchar](100) NULL,
						[Concept] [varchar](100) NULL,
						[Key] [varchar](100) NULL,
						[uuid] [varchar](100) NULL,
						[number] [varchar](8) NULL,
						[tradeChannelNodeUuid] [varchar](100) NULL,
						[customerLocationUuid] [varchar](100) NULL,
						[channelUuid] [varchar](100) NULL,
						[brandTypeUuid] [varchar](100) NULL,
						[description] [varchar](100) NULL,
						[status] [varchar](100) NULL,
						[type] [varchar](100) NULL)

				INSERT INTO #customerAccount
				SELECT * FROM OPENJSON ([dbo].[qfn_XmlToJson] (@xml))
							  WITH ( 									
									report nvarchar(max) '$.report' AS JSON,
									item nvarchar (max) '$.item' AS JSON
									)
							 CROSS APPLY
							 OPENJSON (report)
							 WITH(
									UserName varchar (100) '$.UserName',
									Source varchar (100) '$.Source',
									TimeInMillis bigint '$.TimeInMillis',
									OperationType varchar (100) '$.OperationType',
									DataCluster varchar (100) '$.DataCluster',
									DataModel varchar (100) '$.DataModel',
									Concept varchar (100) '$.Concept',
									[Key] varchar (100) '$.Key'
								 )
							CROSS APPLY
							OPENJSON (item)
							WITH(
									uuid varchar (100) '$.uuid'
									,number varchar (8) '$.number'
									,tradeChannelNodeUuid varchar (100) '$.tradeChannelNodeUuid'
									,customerLocationUuid varchar (100) '$.customerLocationUuid'
									,channelUuid varchar (100) '$.channelUuid'
									,brandTypeUuid varchar (100) '$.brandTypeUuid'
									,description varchar (100) '$.description'
									,status varchar (100) '$.status'
									,type varchar (100) '$.type'
							  )
--/////////////////////////////////////////////////////////////////////////////////////
				DELETE operationsLog
				FROM   operationsLog
				INNER JOIN #customerAccount ON operationsLog.[key] = #customerAccount.[Key]

				INSERT INTO operationsLog
				SELECT Source,TimeInMillis,Concept,OperationType,[Key],GETDATE()
				FROM #customerAccount
--////////////////////////////////////////////////////////////////////////////////////////
				DELETE customerAccount
				FROM   customerAccount
				INNER JOIN #customerAccount ON customerAccount.Uuid = #customerAccount.uuid
				INSERT INTO customerAccount
				SELECT  uuid,number,
				CASE 
				WHEN SUBSTRING(tradeChannelNodeUuid,1,1) = '[' AND SUBSTRING(tradeChannelNodeUuid,LEN(TRIM(tradeChannelNodeUuid)),1)   =']' THEN
					 SUBSTRING(tradeChannelNodeUuid,2,LEN(TRIM(tradeChannelNodeUuid))-2)
				ELSE 
					tradeChannelNodeUuid
				END,
				CASE 
				WHEN SUBSTRING(customerLocationUuid,1,1) = '[' AND SUBSTRING(customerLocationUuid,LEN(TRIM(customerLocationUuid)),1)   =']' THEN
					 SUBSTRING(customerLocationUuid,2,LEN(TRIM(customerLocationUuid))-2)
				ELSE 
					customerLocationUuid
				END,
				CASE 
				WHEN SUBSTRING(channelUuid,1,1) = '[' AND SUBSTRING(channelUuid,LEN(TRIM(channelUuid)),1)   =']' THEN
					 SUBSTRING(channelUuid,2,LEN(TRIM(channelUuid))-2)
				ELSE 
					channelUuid
				END,
				CASE 
				WHEN SUBSTRING(brandTypeUuid,1,1) = '[' AND SUBSTRING(brandTypeUuid,LEN(TRIM(brandTypeUuid)),1)   =']' THEN
					 SUBSTRING(brandTypeUuid,2,LEN(TRIM(brandTypeUuid))-2)
				ELSE 
					brandTypeUuid
				END,description,status,type,GETDATE()
				FROM #customerAccount

				--clean up
				DROP TABLE #customerAccount
		END 
--====================================================================================
--Validate rabbitmq message and check if its a valid xml and json string, if its not
--valid insert message into rabbitmqmessagelLog
--Get customer location from rabbitMQ message in xml format
--Call a function to convert xml to json 
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if task customerlocation uuid exists and if it does overwrite it 
--and insert new customer location data
--==================================================================================== 	
		ELSE IF (@routingKey = 'customer-location')
				BEGIN
					BEGIN TRY
						SET @xml = CAST(@masterData_Msg AS XML)
						IF ISJSON(([dbo].[qfn_XmlToJson] (@xml))) = 0
							BEGIN
								INSERT INTO rabbitMQMessageLog
								SELECT @masterData_Msg,@routingKey,'Invalid JSON', GETDATE()
							END
					END TRY
					BEGIN CATCH
						INSERT INTO rabbitMQMessageLog
						SELECT @masterData_Msg,@routingKey,'Invalid XML', GETDATE()
					END CATCH
--///////////////////////////////////////////////////////////////////////////////////
				CREATE TABLE #CustomerLocation
						([report] [nvarchar](max) NULL,
						[item] [nvarchar](max) NULL,
						[UserName] [varchar](100) NULL,
						[Source] [varchar](100) NULL,
						[TimeInMillis] [bigint] NULL,
						[OperationType] [varchar](100) NULL,
						[DataCluster] [varchar](100) NULL,
						[DataModel] [varchar](100) NULL,
						[Concept] [varchar](100) NULL,
						[Key] [varchar](100) NULL,
						[uuid] [varchar](100) NULL,
						[tradeEntityUuid] [varchar](100) NULL,
						[locationUuid] [varchar](100) NULL,
						[description] [varchar](100) NULL,
						[deliveryLocationUuid] [varchar](100) NULL,
						[status] [varchar](100) NULL,
						[type] [varchar](100) NULL)
				INSERT INTO #CustomerLocation
				SELECT * FROM OPENJSON ([dbo].[qfn_XmlToJson] (@xml))
							  WITH ( 									
										report nvarchar(max) '$.report' AS JSON,
										item nvarchar (max) '$.item' AS JSON
								    )
							 CROSS APPLY
							 OPENJSON (report)
							 WITH (
										UserName varchar (100) '$.UserName',
										Source varchar (100) '$.Source',
										TimeInMillis bigint '$.TimeInMillis',
										OperationType varchar (100) '$.OperationType',
										DataCluster varchar (100) '$.DataCluster',
										DataModel varchar (100) '$.DataModel',
										Concept varchar (100) '$.Concept',
										[Key] varchar (100) '$.Key'
								 )
							CROSS APPLY
							OPENJSON (item)
							WITH (
									 uuid varchar (100) '$.uuid'
									,tradeEntityUuid varchar (100) '$.tradeEntityUuid'
									,locationUuid  varchar (100) '$.locationUuid'
									,description varchar (100) '$.description'
									,deliveryLocationUuid varchar (100) '$.deliveryLocationUuid'
									,status varchar (100) '$.status'
									,type varchar (100) '$.type'
								)
--//////////////////////////////////////////////////////////////////////////////////////////////
				DELETE operationsLog
				FROM   operationsLog
				INNER JOIN #CustomerLocation ON operationsLog.[key] = #CustomerLocation.[Key]

				INSERT INTO operationsLog
				SELECT Source,TimeInMillis,Concept,OperationType,[Key],GETDATE()
				FROM #customerLocation
--////////////////////////////////////////////////////////////////////////////////////////////////
				DELETE customerLocation
				FROM   customerLocation
				INNER JOIN #CustomerLocation ON CustomerLocation.Uuid = #customerLocation.uuid

				INSERT INTO customerLocation
				SELECT uuid,
				CASE 
				WHEN SUBSTRING(tradeEntityUuid,1,1) = '[' AND SUBSTRING(tradeEntityUuid,LEN(TRIM(tradeEntityUuid)),1)   =']' THEN
					 SUBSTRING(tradeEntityUuid,2,LEN(TRIM(tradeEntityUuid))-2)
				ELSE 
					tradeEntityUuid
				END,
				CASE 
				WHEN SUBSTRING(locationUuid,1,1) = '[' AND SUBSTRING(locationUuid,LEN(TRIM(locationUuid)),1)  =']' THEN
					 SUBSTRING(locationUuid,2,LEN(TRIM(locationUuid))-2)
				ELSE 
					locationUuid
				END,description,
				CASE 
				WHEN SUBSTRING(deliveryLocationUuid,1,1) = '[' AND SUBSTRING(deliveryLocationUuid,LEN(TRIM(deliveryLocationUuid)),1) =']' THEN
					 SUBSTRING(deliveryLocationUuid,2,LEN(TRIM(deliveryLocationUuid))-2)
				ELSE 
					deliveryLocationUuid
				END,status,type,GETDATE()
				FROM #customerLocation
				--Clean up
				DROP TABLE #customerLocation
		END
--====================================================================================
--Validate rabbitmq message and check if its a valid json string, if its not
--valid, insert message into rabbitmqmessagelLog
--Get company user from rabbitMQ message in json format
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if company user uuid exists and if it does overwrite it 
--and insert new company user data
--====================================================================================
		ELSE IF ( @routingKey = 'company-user')
				BEGIN
					IF ISJSON(@masterData_Msg) = 0
					BEGIN
						INSERT INTO rabbitMQMessageLog
						SELECT @masterData_Msg,@routingKey,'Invalid JSON', GETDATE()
					END
					SET @taskInstanceUuid = (SELECT *  FROM OPENJSON (@masterData_Msg)
															WITH ( taskInstanceUuid VARCHAR (100) '$.companyUser.uuid' ))
					DELETE 
					FROM operationsLog
					WHERE [key] = @taskInstanceUuid

					INSERT INTO operationsLog
					SELECT *  FROM OPENJSON (@masterData_Msg)
								   WITH ( 
										  source VARCHAR (100),
										  [timestamp] VARCHAR(100),
										  [type] VARCHAR(100) '$.type',
										  action VARCHAR(100),
										  [key] VARCHAR (100) '$.companyUser.uuid',
										  loadDate DATETIME 
										)
				UPDATE operationsLog
				SET source = 'genericUI',
					[timestamp] = '',
					action = '',
					loadDate = GETDATE()
				FROM operationsLog
				WHERE [key] = @taskInstanceUuid
--///////////////////////////////////////////////////////////////////////////////////
				DELETE
				FROM companyUser
				WHERE uuid = @taskInstanceUuid

				INSERT INTO companyUser
				SELECT *  FROM OPENJSON (@masterData_Msg)
								WITH (
										uuid VARCHAR (100) '$.companyUser.uuid',
										status VARCHAR (10) '$.companyUser.status',
										contractedHours INT '$.companyUser.contractedHours',
										effectiveFromDate DATETIME '$.companyUser.effectiveFromDate',
										effectiveToDate DATETIME '$.companyUser.effectiveToDate',
										userUuid VARCHAR (100) '$.companyUser.userUuid',
										companyUuid VARCHAR (100) '$.companyUser.companyUuid',
										accessLevels VARCHAR (100) '$.companyUser.accessLevels',
										username VARCHAR (100) '$.companyUser.username',
										firstName VARCHAR(100) '$.companyUser.firstName',
										lastName VARCHAR(100) '$.companyUser.lastName',
										emailAddress VARCHAR(100)'$.companyUser.emailAddress',
										identityNumber VARCHAR (50) '$.companyUser.identityNumber',
										passportNumber VARCHAR(100) '$.companyUser.passportNumber',
										admin VARCHAR(100) '$.companyUser.admin',
										availableForSelection VARCHAR(100) '$.companyUser.availableForSelection',
										reason VARCHAR(500) '$.companyUser.reason',
										type VARCHAR (100) '$.type',
										loadDate DATETIME '$.companyUser.effectiveToDate'
									)
			UPDATE companyUser
			SET loadDate = GETDATE()
			WHERE uuid = @taskInstanceUuid
		END
--====================================================================================
--Validate rabbitmq message and check if its a valid json string, if its not
--valid, insert message into rabbitmqmessagelLog
--Get appointment types from rabbitMQ message in json format
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if task appointment type uuid exists and if it does overwrite it 
--and insert new appointment types data
--====================================================================================
		ELSE IF ( @routingKey = 'appointment-type')
			BEGIN
			IF ISJSON(@masterData_Msg) = 0
			BEGIN
				INSERT INTO rabbitMQMessageLog
				SELECT @masterData_Msg,@routingKey,'Invalid JSON', GETDATE()
			END
--/////////////////////////////////////////////////////////////////////////////////////
			SET @taskInstanceUuid = (SELECT *  FROM OPENJSON (@masterData_Msg)
													WITH ( taskInstanceUuid VARCHAR (100) '$.payload.uuid' ))
			DELETE 
			FROM operationsLog
			WHERE [key] = @taskInstanceUuid

			INSERT INTO operationsLog
			SELECT * FROM  OPENJSON ( @masterData_Msg)
						   WITH ( 
								source VARCHAR (100),
								timestamp VARCHAR (100),
								type VARCHAR (100),
								action VARCHAR (100),
								[key] VARCHAR (100),
								loadDate DATETIME 
								)
			UPDATE operationsLog
			SET loadDate = GETDATE()
			WHERE [key] = @taskInstanceUuid
--/////////////////////////////////////////////////////////////////////////////
			DELETE 
			FROM appointmentTypes
			WHERE uuid = @taskInstanceUuid

			INSERT INTO appointmentTypes
			SELECT * FROM  OPENJSON ( @masterData_Msg)
								WITH (
										uuid VARCHAR (100) '$.payload.uuid',
										status VARCHAR (100) '$.payload.status',
										name VARCHAR (255) '$.payload.name',
										tasksRequired VARCHAR (100) '$.payload.tasksRequired',
										loadDate VARCHAR (20) 
										)
			UPDATE appointmentTypes--update load date 
			SET loadDate = CONVERT(VARCHAR (20),GETDATE(),120 )
			WHERE uuid = @taskInstanceUuid
		END
--====================================================================================
--Validate rabbitmq message and check if its a valid json string, if its not
--valid, insert message into rabbitmqmessagelLog
--Get company from rabbitMQ message in json format
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if task task type uuid exists and if it does overwrite it 
--and insert new task types data
--====================================================================================
		ELSE IF ( @routingKey = 'task-type')
				BEGIN
				IF ISJSON(@masterData_Msg) = 0
				BEGIN
					INSERT INTO rabbitMQMessageLog
					SELECT @masterData_Msg,@routingKey,'Invalid JSON', GETDATE()
				END
--///////////////////////////////////////////////////////////////////////////////////////////
				SET @taskInstanceUuid = (SELECT *  FROM OPENJSON (@masterData_Msg)
														WITH ( taskInstanceUuid VARCHAR (100) '$.payload.uuid' ))
				DELETE 
				FROM operationsLog
				WHERE [key] = @taskInstanceUuid

				INSERT INTO operationsLog
				SELECT * FROM  OPENJSON ( @masterData_Msg)
								WITH ( 
									source VARCHAR (100),
									timestamp VARCHAR (100),
									type VARCHAR (100),
									action VARCHAR (100),
									[key] VARCHAR (100),
									loadDate DATETIME  
									)
				UPDATE operationsLog
				SET loadDate = GETDATE()
				WHERE [key] = @taskInstanceUuid
--////////////////////////////////////////////////////////////////////////////////////////
				DELETE 
				FROM taskTypes
				WHERE uuid = @taskInstanceUuid

				INSERT INTO taskTypes
				SELECT * FROM  OPENJSON ( @masterData_Msg)
							   WITH (
										uuid VARCHAR (100) '$.payload.uuid',
										status VARCHAR (100) '$.payload.status',
										name VARCHAR (255) '$.payload.name',
										description  VARCHAR (255) '$.payload.description',
										applicationKey  VARCHAR (100) '$.payload.applicationKey',
										daysToExpiry INT '$.payload.daysToExpiry',
										photoRequired VARCHAR (100) '$.payload.photoRequired',
										loadDate VARCHAR (20) 
									)
				UPDATE taskTypes--update load date 
				SET loadDate = CONVERT(VARCHAR (20),GETDATE(),120 )
				WHERE uuid = @taskInstanceUuid
		END
--====================================================================================
--Validate rabbitmq message and check if its a valid json string, if its not
--valid, insert message into rabbitmqmessagelLog
--Get sales agency cost centre from rabbitMQ message in json format
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if task sales agency cost centre uuid exists and if it does overwrite it 
--and insert new sales agency cost centre data
--====================================================================================
		ELSE IF (@routingKey = 'sales-agency-cost-centre')
			 INSERT INTO rabbitMQMessageLog
			 SELECT @masterData_Msg,@routingKey,'Live Data', GETDATE()
			 BEGIN
			 IF ISJSON(@masterData_Msg) = 0
			BEGIN
				INSERT INTO rabbitMQMessageLog
				SELECT @masterData_Msg,@routingKey,'Invalid JSON', GETDATE()
			END
--///////////////////////////////////////////////////////////////////////////////////////////
			SET @taskInstanceUuid = (SELECT *  FROM OPENJSON (@masterData_Msg)
											   WITH ( taskInstanceUuid VARCHAR (100) '$.salesagencycostcentre.uuid'))
			DELETE 
			FROM operationsLog
			WHERE [key] = @taskInstanceUuid

			INSERT INTO operationsLog
			SELECT * FROM  OPENJSON ( @masterData_Msg)
						   WITH ( 
								source VARCHAR (100) ,
								[timestamp] VARCHAR (100),
								type VARCHAR (100)'$.type',
								action VARCHAR (100) ,
								[key] VARCHAR (100) '$.salesagencycostcentre.uuid',
								loadDate DATETIME  
								)
			UPDATE operationsLog
			SET source = 'genericUI',
				[timestamp] = '',
				action ='',
				loadDate = GETDATE()
			FROM operationsLog
			WHERE [key] = @taskInstanceUuid
--/////////////////////////////////////////////////////////////////////////////////////////////
				DELETE 
				FROM salesAgencyCostCentre
				WHERE salesAgencyCostCentreUuid = @taskInstanceUuid 															

				SELECT * INTO #salesAgencyCostCentre FROM OPENJSON (@masterData_Msg)
							WITH (
								salesAgencyCostCentreUuid  VARCHAR(100) '$.salesagencycostcentre.uuid',
								code VARCHAR(100) '$.salesagencycostcentre.code',
								name VARCHAR(100) '$.salesagencycostcentre.name',
								description VARCHAR(100) '$.salesagencycostcentre.description',
								companyUuid VARCHAR(100) '$.salesagencycostcentre.companyUuid',
								startDate DATETIME '$.salesagencycostcentre.startDate', 
								endDate DATETIME '$.salesagencycostcentre.endDate',
								status VARCHAR(100) '$.salesagencycostcentre.status',
								currentCustodianFirstName VARCHAR(100) '$.salesagencycostcentre.currentCustodianFirstName',
								currentCustodianLastName VARCHAR(100) '$.salesagencycostcentre.currentCustodianLastName',
								currentCustodianUuid VARCHAR(100) '$.salesagencycostcentre.currentCustodianUuid',
								detailedDescription VARCHAR(100) '$.salesagencycostcentre.detailedDescription',
								reason VARCHAR(100) '$.salesagencycostcentre.reason',
								omsMappingValidationMessage VARCHAR(100) '$.salesagencycostcentre.omsMappingValidationMessage',
								custodianLinkEndDate DATETIME '$.salesagencycostcentre.custodianLinkEndDate',
								costCentreCustodianLinks NVARCHAR(MAX) '$.salesagencycostcentre.costCentreCustodianLinks' AS JSON 
								)
								CROSS APPLY
								OPENJSON (costCentreCustodianLinks)
								WITH (
										costCentreCustodianLinksUuid VARCHAR(100)'$.uuid', 
										companyUserUuid VARCHAR (100) '$.salesAgencyCostCentreCustodian.uuid',
										costCentreCustodianLinksStatus VARCHAR (10) '$.salesAgencyCostCentreCustodian.status',
										contractedHours INT '$.salesAgencyCostCentreCustodian.contractedHours',
										effectiveFromDate DATETIME '$.companyUser.effectiveFromDate',
										effectiveToDate DATETIME '$.salesAgencyCostCentreCustodian.effectiveToDate',
										userUuid VARCHAR (100) '$.salesAgencyCostCentreCustodian.userUuid',
										username VARCHAR (100) '$.salesAgencyCostCentreCustodian.username',
										firstName VARCHAR(100) '$.salesAgencyCostCentreCustodian.firstName',
										lastName VARCHAR(100) '$.salesAgencyCostCentreCustodian.lastName',
										emailAddress VARCHAR(100)'$.salesAgencyCostCentreCustodian.emailAddress',
										identityNumber bigint '$.salesAgencyCostCentreCustodian.identityNumber',
										admin VARCHAR(100) '$.salesAgencyCostCentreCustodian.admin',
										availableForSelection VARCHAR(100) '$.salesAgencyCostCentreCustodian.availableForSelection',
										costCentreCustodianLinksReason VARCHAR(100)'$.salesAgencyCostCentreCustodian.reason',
										costCentreCustodianLinksStartDate DATETIME'$.startDate',costCentreCustodianLinksEndDate DATETIME'$.endDate'
									)
			INSERT INTO salesAgencyCostCentre
			SELECT salesAgencyCostCentreUuid, code, name, description, companyUuid, startDate, endDate, status, currentCustodianFirstName, currentCustodianLastName, currentCustodianUuid,
				   detailedDescription, reason, omsMappingValidationMessage, custodianLinkEndDate, costCentreCustodianLinksUuid, companyUserUuid, costCentreCustodianLinksStatus,
				   contractedHours,effectiveFromDate, effectiveToDate, userUuid, username, firstName, lastName, emailAddress, identityNumber,admin, availableForSelection,
				   costCentreCustodianLinksReason, costCentreCustodianLinksStartDate, costCentreCustodianLinksEndDate, GETDATE()
			FROM #salesAgencyCostCentre	
			
			--Clean Up
			EXEC usp_purgeLogData		
		END
	END
END
