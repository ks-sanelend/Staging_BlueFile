CREATE TABLE [dbo].[taskTracker] (
    [taskInstanceUuid]          VARCHAR (100) NULL,
    [appointmentTypeUuid]       VARCHAR (100) NULL,
    [scheduleType]              VARCHAR (50)  NULL,
    [date]                      DATETIME      NULL,
    [startTime]                 TIME (0)      NULL,
    [endTime]                   TIME (0)      NULL,
    [UserUuid]                  VARCHAR (100) NULL,
    [companyUserUuid]           VARCHAR (100) NULL,
    [customerLocationUuid]      VARCHAR (100) NULL,
    [customerAccountUuid]       VARCHAR (100) NULL,
    [tradeChannelUuid]          VARCHAR (100) NULL,
    [principalUuid]             VARCHAR (100) NULL,
    [serviceProviderUuid]       VARCHAR (100) NULL,
    [salesAgencyCostCentreUuid] VARCHAR (100) NULL,
    [taskUuid]                  VARCHAR (100) NULL,
    [status]                    VARCHAR (100) NULL,
    [completedDateTime]         DATETIME      NULL,
    [externalSystemDataKey]     VARCHAR (100) NULL,
    [taskTypeUuid]              VARCHAR (100) NULL,
    [loadDate]                  DATETIME      NULL
);


GO


-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_taskTracker info to be inserted
--				in the taskTracker table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_taskTracker]     
ON [dbo].[taskTracker]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_taskTracker
END
