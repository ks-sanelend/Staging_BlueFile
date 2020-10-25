CREATE TABLE [dbo].[taskTypes] (
    [uuid]           VARCHAR (100) NULL,
    [status]         VARCHAR (100) NULL,
    [name]           VARCHAR (255) NULL,
    [description]    VARCHAR (500) NULL,
    [applicationKey] VARCHAR (100) NULL,
    [daysToExpiry]   INT           NULL,
    [photoRequired]  VARCHAR (100) NULL,
    [loadDate]       VARCHAR (20)  NULL
);


GO


-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_taskTypes info to be inserted
--				in the taskTypes table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_taskTypes]     
ON [dbo].[taskTypes]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_taskTypes
END
