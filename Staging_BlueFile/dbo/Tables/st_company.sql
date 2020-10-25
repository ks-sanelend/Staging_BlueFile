CREATE TABLE [dbo].[st_company] (
    [companyUuid]     VARCHAR (100) NOT NULL,
    [legalEntityUuid] VARCHAR (100) NOT NULL,
    [name]            VARCHAR (100) NULL,
    [status]          VARCHAR (8)   NULL,
    [loadDate]        DATETIME      NOT NULL
);

