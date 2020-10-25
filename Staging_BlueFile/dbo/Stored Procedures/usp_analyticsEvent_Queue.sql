


-- =============================================
-- Author:		<Sanele Ndlela>
-- Create date: <30-04-2020>
-- Description:	<Insert Image and PDF Data from a RabbitMQ Queue>
-- =============================================
CREATE PROCEDURE [dbo].[usp_analyticsEvent_Queue]
		@analyticsEvent_Msg nvarchar (max), @routing_Key nvarchar (100)
AS
BEGIN TRY
	SET NOCOUNT ON;
	DECLARE @taskInstanceUuid VARCHAR (100)
	DECLARE @routingKey AS NVARCHAR (100) 

	SET @routingKey = LOWER(@routing_Key)
--====================================================================================
--Validate rabbitmq message and check if its a valid  json string, if its not a
--valid json string, insert message into rabbitmqmessagelLog
--Check if operationsLog uuid exists and if it does overwrite it 
--and insert new operationsLog data
--Check if task tracker/instance uuid exists and if it does overwrite it 
--and insert new task tracker/instance data
--Check if image uuid exists and if it does overwrite it 
--and insert new image data
--Check if task pdf uuid exists and if it does overwrite it 
--and insert new pdf data
--==================================================================================== 
	IF ( @routingKey = 'analytics-event')
		BEGIN

		INSERT INTO rabbitMQMessageLog
		SELECT @analyticsEvent_Msg,@routingKey,'Live Data', GETDATE()

		IF ISJSON(@analyticsEvent_Msg) = 0
			BEGIN
				INSERT INTO rabbitMQMessageLog
				SELECT @analyticsEvent_Msg,@routingKey,'Invalid JSON', GETDATE()
			END
--//////////////////////////////////////////////////////////////////////////////////////////
		SET @taskInstanceUuid = (SELECT *  FROM OPENJSON (@analyticsEvent_Msg)
									 WITH ( taskInstanceUuid VARCHAR (100) '$.payload.uuid' )
								 )
		DELETE 
		FROM operationsLog
		WHERE [key] = @taskInstanceUuid

		INSERT INTO operationsLog
		SELECT * FROM  OPENJSON ( @analyticsEvent_Msg)
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
--////////////////////////////////////////////////////////////////////////////////////////////
		DELETE taskTracker
		FROM taskTracker
		WHERE taskInstanceUuid = @taskInstanceUuid
		AND status <> 'COMPLETED'
		
		INSERT INTO taskTracker
		SELECT * FROM  OPENJSON (@analyticsEvent_Msg)
					   WITH (
								taskInstanceUuid varchar (100) '$.payload.uuid',
								appointmentTypeUuid varchar (100) '$.payload.appointmentTypeUuid',
								scheduleType varchar(50)'$.payload.scheduleType',
								[date] datetime '$.payload.date',
								[startTime] time(0) '$.payload.startTime',
								[endTime] time(0) '$.payload.endTime',
								UserUuid varchar (100) '$.payload.userUuid',
								companyUserUuid varchar (100) '$.payload.companyUserUuid',
								customerLocationUuid varchar (100)'$.payload.customerLocationUuid',
								customerAccountUuid varchar (100)'$.payload.customerAccountUuid',
								tradeChannelUuid varchar (100)'$.payload.tradeChannelUuid',
								principalUuid varchar (100)'$.payload.principalUuid',
								serviceProviderUuid varchar (100) '$.payload.serviceProviderUuid',
								salesAgencyCostCenterUuid varchar (100) '$.payload.salesAgencyCostCentreUuid',
								taskUuid varchar (100)'$.payload.taskUuid',
								[status] varchar (100)'$.payload.status',
								completedDateTime datetime'$.payload.completedDateTime',
								externalSystemDataKey varchar (100)'$.payload.externalSystemDataKey',
								taskTypeUuid varchar (100)'$.payload.taskTypeUuid',
								loadDate datetime '$.payload.date'
							) 
		WHERE @taskInstanceUuid NOT IN 
									  (SELECT taskInstanceUuid 
									   FROM taskTracker 
									   WHERE taskInstanceUuid = @taskInstanceUuid 
									   AND status = 'COMPLETED')
		UPDATE taskTracker
		SET loadDate = GETDATE()
		WHERE taskInstanceUuid = @taskInstanceUuid
--///////////////////////////////////////////////////////////////////////////////////////
		CREATE TABLE #Image (
			[taskInstanceUuid] VARCHAR(100) NULL,
			[attachment] NVARCHAR(MAX) NULL,
			[type] VARCHAR(10) NULL,
			[uuid] VARCHAR(100) NULL,
			[created] VARCHAR(100) NULL,
			[batch] VARCHAR(100) NULL,
			[reference] VARCHAR(100) NULL,
			[uri] VARCHAR(500) NULL,
			[store] VARCHAR(100) NULL,
			[height] INT NULL,
			[width] INT NULL
		) 
		INSERT INTO #Image
		SELECT * FROM OPENJSON ( @analyticsEvent_Msg)
					  WITH (
								taskInstanceUuid VARCHAR (100) '$.payload.uuid',
								attachment NVARCHAR(MAX) '$.payload.attachment' AS JSON
							) 
					 CROSS APPLY
					 OPENJSON (attachment)
					 WITH (
								[type]  VARCHAR(10) '$.type',uuid VARCHAR(100),created VARCHAR(100),batch VARCHAR(100), reference VARCHAR(100),
								uri VARCHAR (500),store VARCHAR(100),height INT '$.metadata.properties.height',width INT '$.metadata.properties.width'
						  )
		WHERE [type]  ='image'

		DELETE imageData
		FROM imageData
		INNER JOIN #Image ON imageData.TaskInstanceUuid = #Image.taskInstanceUuid

		INSERT INTO imageData
		SELECT taskInstanceUuid,uuid,created,batch,reference,uri,store,height, width, GETDATE()
		FROM #Image
--/////////////////////////////////////////////////////////////////////////////////////////////////
		CREATE TABLE #pdf (
			[taskInstanceUuid] VARCHAR(100) NULL,
			[attachment] NVARCHAR(MAX) NULL,
			[type] VARCHAR(10) NULL,
			[uuid] VARCHAR(100) NULL,
			created VARCHAR(100) NULL,
			batch VARCHAR(100) NULL,
			reference VARCHAR(100) NULL,
			[filename] VARCHAR(100) NULL,
			[author] VARCHAR(100) NULL,
			[creationDate] VARCHAR(100) NULL,
			[creator] VARCHAR(100) NULL,
			[keywords] VARCHAR(200) NULL,
			[modificationDate] VARCHAR(100) NULL,
			[subject] VARCHAR(100) NULL,
			[title] VARCHAR(100) NULL,
			[fields] VARCHAR(MAX) NULL,
			[name] VARCHAR(500) NULL,
			[value] VARCHAR(100) NULL
		)
		INSERT INTO #pdf
		SELECT * FROM OPENJSON (@analyticsEvent_Msg)
					  WITH (
								taskInstanceUuid VARCHAR (100) '$.payload.uuid',
								attachment NVARCHAR(MAX) '$.payload.attachment' AS JSON
							) 
					 CROSS APPLY
					 OPENJSON (attachment)
					 WITH (
								 [type]  VARCHAR(10) '$.type',uuid VARCHAR(100),created VARCHAR(100),batch VARCHAR(100), reference VARCHAR(100), [filename] VARCHAR(100),
								 author VARCHAR(100) '$.payload.metadata.author',creationDate VARCHAR(100) '$.payload.metadata.creationDate', 
								 creator VARCHAR(100) '$.payload.metadata.creator', keywords VARCHAR(500) '$.payload.metadata.keywords',
								 modificationDate VARCHAR(100) '$.payload.metadata.modificationDate',[subject] VARCHAR(100) '$.payload.metadata.subject',
								 title VARCHAR(100) '$.payload.metadata.title', fields NVARCHAR(MAX) '$.payload.fields' AS JSON
						 )
					CROSS APPLY
					OPENJSON (fields)
					WITH (
								 [name] VARCHAR(500) ,[value] VARCHAR(100)
						 )

	WHERE [type]  ='pdf'

	DELETE pdFData
	FROM pdFData
	INNER JOIN #PDF ON pdFData.TaskInstanceUuid = #PDF.TaskInstanceUuid

	INSERT INTO pdFData
	SELECT TaskInstanceUuid,uuid,created,batch,reference,[filename],author, creationDate,creator,keywords,modificationDate,[subject],title,[name],[value], GETDATE() 
	FROM #PDF

	--Update subject for pack shelves
	UPDATE pdFData
	SET subject = title
	WHERE title = 'Pack Shelves'

	--Clean up
	EXEC usp_purgeLogData
	DROP TABLE #Image
	DROP TABLE #pdf
	END
END TRY
BEGIN CATCH
 --EXEC usp_RabbitmqMessageQueueErrorLog @analyticsEvent_Msg,@routing_Key,ERROR_MESSAGE
END CATCH
