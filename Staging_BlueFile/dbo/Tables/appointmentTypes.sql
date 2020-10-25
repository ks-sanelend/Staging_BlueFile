CREATE TABLE [dbo].[appointmentTypes] (
    [uuid]          VARCHAR (100) NULL,
    [status]        VARCHAR (100) NULL,
    [name]          VARCHAR (255) NULL,
    [tasksRequired] VARCHAR (100) NULL,
    [loadDate]      VARCHAR (20)  NULL
);


GO



-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_appointmentTypes info to be inserted
--				in the appointmentTypes table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_appointmentTypes]     
ON [dbo].[appointmentTypes]  
AFTER INSERT,UPDATE
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_appointmentTypes
END
