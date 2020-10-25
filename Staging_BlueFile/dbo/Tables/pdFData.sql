CREATE TABLE [dbo].[pdFData] (
    [taskInstanceUuid] VARCHAR (100) NULL,
    [uuid]             VARCHAR (100) NULL,
    [created]          VARCHAR (100) NULL,
    [batch]            VARCHAR (100) NULL,
    [reference]        VARCHAR (100) NULL,
    [filename]         VARCHAR (100) NULL,
    [author]           VARCHAR (100) NULL,
    [creationDate]     VARCHAR (100) NULL,
    [creator]          VARCHAR (100) NULL,
    [keywords]         VARCHAR (500) NULL,
    [modificationDate] VARCHAR (100) NULL,
    [subject]          VARCHAR (100) NULL,
    [title]            VARCHAR (100) NULL,
    [name]             VARCHAR (500) NULL,
    [value]            VARCHAR (100) NULL,
    [loadDate]         DATETIME      NULL
);


GO


-- =============================================
-- Author:		Sanele Ndlela
-- Create date: 2020-10-02
-- Description:	After a record has been inserted
--				the trigger gets fired to execute
--				usp_merchandisingSurveyData info to be inserted
--				in the merchandisingSurveyData table  
-- =============================================
CREATE TRIGGER [dbo].[trgInsert_merchandasingData]     
ON [dbo].[pdFData]  
AFTER INSERT
AS  BEGIN
    SET NOCOUNT ON;
	--/////////////////////////////
    EXEC dbo.usp_merchandisingSurveyData
END
