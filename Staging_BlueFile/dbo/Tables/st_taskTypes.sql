CREATE TABLE [dbo].[st_taskTypes] (
    [taskTypeUuid]   VARCHAR (100) NOT NULL,
    [status]         VARCHAR (100) NULL,
    [name]           VARCHAR (255) NULL,
    [description]    VARCHAR (500) NULL,
    [applicationKey] VARCHAR (100) NULL,
    [daysToExpiry]   INT           NULL,
    [photoRequired]  VARCHAR (100) NULL,
    [loadDate]       DATETIME      NULL,
    CONSTRAINT [PK_st_taskTypes] PRIMARY KEY CLUSTERED ([taskTypeUuid] ASC)
);

