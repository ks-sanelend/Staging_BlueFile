CREATE TABLE [dbo].[company] (
    [uuid]            VARCHAR (100) NULL,
    [legalEntityUuid] VARCHAR (100) NULL,
    [name]            VARCHAR (100) NULL,
    [status]          VARCHAR (8)   NULL,
    [loadDate]        DATETIME      NOT NULL
);


GO
-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-07-28
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_company info to be inserted
--				in the company table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_company]     
ON [dbo].[company]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_company
END
