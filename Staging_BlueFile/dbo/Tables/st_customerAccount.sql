CREATE TABLE [dbo].[st_customerAccount] (
    [customerAccountUuid]  VARCHAR (100) NOT NULL,
    [masterdataNumber]     VARCHAR (100) NOT NULL,
    [tradeChannelNodeUuid] VARCHAR (100) NOT NULL,
    [customerLocationUuid] VARCHAR (100) NOT NULL,
    [channelUuid]          VARCHAR (100) NOT NULL,
    [brandTypeUuid]        VARCHAR (100) NOT NULL,
    [description]          VARCHAR (100) NULL,
    [status]               VARCHAR (100) NULL,
    [type]                 VARCHAR (100) NULL,
    [loadDate]             DATETIME      NOT NULL,
    CONSTRAINT [PK_st_customerAccount] PRIMARY KEY CLUSTERED ([customerAccountUuid] ASC)
);

